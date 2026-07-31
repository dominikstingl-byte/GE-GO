import ARKit
import Combine
import RealityKit
import SwiftUI

/// Das Kamerabild mit den schwebenden Fundpunkten.
struct ARGameView: UIViewRepresentable {

    @ObservedObject var state: GameState

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        context.coordinator.attach(to: view)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        view.session.delegate = context.coordinator
        view.session.run(configuration)

        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(state: state) }

    // MARK: - Steuerung

    final class Coordinator: NSObject, ARSessionDelegate {

        /// Ein gesetzter Fundpunkt samt seinem Anker, damit er sich wieder
        /// entfernen lässt.
        private struct Spot {
            let find: Find
            let position: SIMD3<Float>
            let anchor: AnchorEntity
            let petal: ModelEntity
            var label: String { find.label }
        }

        private let state: GameState
        private let recognizer = SceneRecognizer()
        private let queue = DispatchQueue(label: "org.gut-einern.gego.vision", qos: .userInitiated)

        private weak var view: ARView?
        private var spots: [Spot] = []
        private var isBusy = false
        private var lastRun: TimeInterval = 0
        private var elapsed: Float = 0
        private var sceneUpdates: Cancellable?

        /// Blätter, die gerade verbucht wurden, kommen kurz nicht wieder – sonst
        /// steht der Punkt sofort erneut da und der Fund fühlt sich folgenlos an.
        private var cooldown: [String: TimeInterval] = [:]
        private let cooldownSeconds: TimeInterval = 20

        /// Die Blatttexturen werden einmal gebaut und dann geteilt.
        private var textures: [RStrategy: TextureResource] = [:]

        /// Macht die Kennung jedes Fundpunkts eindeutig, auch wenn derselbe
        /// Begriff mehrfach in der Szene steht.
        private var nonce = 0

        /// Wie oft pro Sekunde ausgewertet wird. Jedes Bild zu analysieren
        /// würde nichts verbessern, aber Akku und Wärme deutlich verschlechtern.
        private let interval: TimeInterval = 0.5

        /// Mehr Punkte gleichzeitig machen die Szene unübersichtlich.
        private let maximumSpots = 12

        /// Zwei Punkte desselben Gegenstands dürfen nicht dichter beieinander
        /// stehen als das – sonst pflastert ein einzelner Stuhl den Raum zu.
        private let minimumDistance: Float = 1.2

        init(state: GameState) {
            self.state = state
            super.init()

            // Der Punkt verschwindet erst, wenn der Fund wirklich verbucht ist.
            // Vorher entfernt hieße: „Später“ tippen und der Gegenstand ist weg.
            state.onFindingRecorded = { [weak self] label in
                guard let self, let view else { return }
                remove(label, in: view)
                cooldown[label] = CACurrentMediaTime() + cooldownSeconds
            }
        }

        func attach(to view: ARView) {
            self.view = view
            sceneUpdates = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.tick(delta: Float(event.deltaTime))
            }
        }

        // MARK: Lebendigkeit

        /// Blätter sind flach. Ohne diese Schleife stünden sie irgendwo im Raum
        /// herum und wären von der Seite unsichtbar – also drehen sie sich zur
        /// Kamera, atmen leicht und wachsen mit der Entfernung mit, damit ein
        /// Punkt in fünf Metern nicht zum Staubkorn wird.
        private func tick(delta: Float) {
            guard let view, !spots.isEmpty else { return }
            elapsed += delta
            let camera = view.cameraTransform.translation

            for (index, spot) in spots.enumerated() {
                let position = spot.anchor.position(relativeTo: nil)
                spot.petal.look(at: camera, from: spot.petal.position(relativeTo: nil), relativeTo: nil)
                spot.petal.orientation *= simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))

                let distance = simd_distance(camera, position)
                let far = min(max(distance / 2.0, 0.7), 3.0)
                let breath = 1 + 0.05 * sin(elapsed * 1.8 + Float(index) * 0.7)
                spot.petal.scale = SIMD3<Float>(repeating: far * breath)
            }
        }

        // MARK: Bildstrom

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let view, view.bounds.width > 0 else { return }
            guard !isBusy, frame.timestamp - lastRun >= interval else { return }

            isBusy = true
            lastRun = frame.timestamp

            let buffer = frame.capturedImage
            let viewport = view.bounds.size
            let transform = frame.displayTransform(for: .portrait, viewportSize: viewport)
            recognizer.minimumConfidence = state.minimumConfidence
            recognizer.collectsDiagnostics = state.diagnosticsEnabled

            queue.async { [weak self] in
                guard let self else { return }
                let report = recognizer.analyze(buffer, orientation: .right)
                DispatchQueue.main.async {
                    self.consume(report, transform: transform, viewport: viewport)
                    self.isBusy = false
                }
            }
        }

        // MARK: Punkte setzen

        private func consume(_ report: RecognitionReport, transform: CGAffineTransform, viewport: CGSize) {
            guard let view else { return }
            let now = CACurrentMediaTime()

            if state.diagnosticsEnabled {
                state.rawCandidates = report.raw
                state.debugBoxes = report.sightings.map {
                    screenRect(for: $0.boundingBox, transform: transform, viewport: viewport)
                }
            }

            var rejections: [String] = []

            for sighting in report.sightings {
                // Jede Sichtung zählt für eine laufende Jagd, auch wenn daraus
                // gerade kein Fundpunkt wird.
                state.registerSighting(sighting.label)

                if let until = cooldown[sighting.label], now < until {
                    rejections.append("\(sighting.label): eben erst gefunden")
                    continue
                }

                let point = screenPoint(for: sighting.boundingBox, transform: transform, viewport: viewport)
                guard viewport.contains(point) else {
                    rejections.append("\(sighting.label): Punkt außerhalb des Bildes – Umrechnung prüfen")
                    continue
                }
                guard let world = worldPosition(at: point, in: view) else {
                    rejections.append("\(sighting.label): kein Halt im Raum")
                    continue
                }

                let tooClose = spots.contains {
                    $0.label == sighting.label && simd_distance($0.position, world) < minimumDistance
                }
                guard !tooClose else { continue }

                nonce += 1
                guard let find = FindResolver.resolve(label: sighting.label,
                                                      visit: state.findings[sighting.label] ?? 0,
                                                      avoiding: state.lastEncounterKind,
                                                      nonce: nonce) else {
                    rejections.append("\(sighting.label): kein Inhalt hinterlegt")
                    continue
                }

                add(find, at: world, in: view)
            }

            if state.diagnosticsEnabled {
                state.lastRejection = rejections.first
            }

            state.spotCount = spots.count
            state.status = spots.isEmpty
                ? "Halt die Kamera auf deine Umgebung"
                : "\(spots.count) \(spots.count == 1 ? "Fundpunkt" : "Fundpunkte") in Sicht"
        }

        /// Rechnet einen Vision-Kasten in einen Punkt auf dem Bildschirm um.
        ///
        /// Vision zählt von unten links, der Bildschirm von oben links, und
        /// dazwischen liegt noch der Zuschnitt des Kamerabilds auf das Fenster.
        /// Falls die Punkte auf dem Gerät versetzt sitzen, ist hier die Stelle,
        /// an der nachzujustieren ist – das Diagnoseblatt zeichnet die Rahmen
        /// mit, dann sieht man den Versatz statt ihn zu erraten.
        private func screenPoint(for box: CGRect, transform: CGAffineTransform, viewport: CGSize) -> CGPoint {
            let center = CGPoint(x: box.midX, y: 1 - box.midY)
            let mapped = center.applying(transform)
            return CGPoint(x: mapped.x * viewport.width, y: mapped.y * viewport.height)
        }

        private func screenRect(for box: CGRect, transform: CGAffineTransform, viewport: CGSize) -> CGRect {
            let a = CGPoint(x: box.minX, y: 1 - box.minY).applying(transform)
            let b = CGPoint(x: box.maxX, y: 1 - box.maxY).applying(transform)
            let x1 = min(a.x, b.x) * viewport.width, x2 = max(a.x, b.x) * viewport.width
            let y1 = min(a.y, b.y) * viewport.height, y2 = max(a.y, b.y) * viewport.height
            return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
        }

        /// Sucht den Ort im Raum hinter einem Bildschirmpunkt. Trifft der Strahl
        /// keine erkannte Fläche, wird der Punkt einfach zwei Meter vor die
        /// Kamera gehängt – lieber ungenau als gar nicht.
        private func worldPosition(at point: CGPoint, in view: ARView) -> SIMD3<Float>? {
            if let query = view.makeRaycastQuery(from: point, allowing: .estimatedPlane, alignment: .any),
               let hit = view.session.raycast(query).first {
                return simd_make_float3(hit.worldTransform.columns.3)
            }
            if let ray = view.ray(through: point) {
                return ray.origin + ray.direction * 2.0
            }
            return nil
        }

        // MARK: Der Fundpunkt selbst

        private func texture(for strategy: RStrategy) -> TextureResource? {
            if let cached = textures[strategy] { return cached }
            guard let cg = Bloom.texture(for: strategy).cgImage else { return nil }
            guard let resource = try? TextureResource.generate(
                from: cg, options: .init(semantic: .color)) else { return nil }
            textures[strategy] = resource
            return resource
        }

        private func add(_ find: Find, at position: SIMD3<Float>, in view: ARView) {
            let side: Float = 0.18
            var material = UnlitMaterial()
            if let texture = texture(for: find.strategy) {
                // Der Weißton mit knapp unter voller Deckkraft ist der Schalter,
                // der in RealityKit die Transparenz der Textur überhaupt erst
                // durchlässt – sonst steht das Blatt auf einem schwarzen Quadrat.
                material.color = .init(tint: .white.withAlphaComponent(0.999), texture: .init(texture))
            } else {
                material.color = .init(tint: UIColor(find.strategy.brandColor))
            }
            // Rückseiten müssen nicht behandelt werden: Das Blatt dreht sich in
            // `tick` ohnehin jede Bildwiederholung zur Kamera.

            let petal = ModelEntity(mesh: .generatePlane(width: side, height: side),
                                    materials: [material])
            petal.name = find.id
            // Trefferfeld als Kugel: Auf eine papierdünne Fläche zielt niemand.
            petal.collision = CollisionComponent(shapes: [.generateSphere(radius: side * 0.55)])

            let anchor = AnchorEntity(world: position)
            anchor.addChild(petal)
            view.scene.addAnchor(anchor)

            spots.append(Spot(find: find, position: position, anchor: anchor, petal: petal))

            while spots.count > maximumSpots {
                let oldest = spots.removeFirst()
                view.scene.removeAnchor(oldest.anchor)
            }

            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        private func remove(_ label: String, in view: ARView) {
            guard let index = spots.firstIndex(where: { $0.label == label }) else { return }
            view.scene.removeAnchor(spots[index].anchor)
            spots.remove(at: index)
            state.spotCount = spots.count
        }

        // MARK: Antippen

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let view else { return }
            let point = sender.location(in: view)
            guard let entity = view.entity(at: point),
                  let spot = spots.first(where: { $0.petal.name == entity.name }) else { return }

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            state.activeFind = spot.find
        }
    }
}

private extension CGSize {
    func contains(_ point: CGPoint) -> Bool {
        point.x >= 0 && point.y >= 0 && point.x <= width && point.y <= height
    }
}
