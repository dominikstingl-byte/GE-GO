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

        /// Ein gesetzter Fundpunkt samt seinem Anker.
        private struct Spot {
            let find: Find
            let position: SIMD3<Float>
            let anchor: AnchorEntity
            let petal: Entity
            var label: String { find.label }
        }

        /// Eine Vermutung, die noch reifen muss.
        ///
        /// Ein einzelner Durchlauf der Klassifikation ist wacklig: Dasselbe
        /// Regal ist einmal Möbel, einmal Papier, einmal Holz. Erst wenn
        /// dasselbe Thema mehrfach hintereinander an ungefähr derselben Stelle
        /// gewinnt, ist es eine Beobachtung und keine Zuckung.
        private struct Track {
            let theme: Theme
            var label: String
            /// Geglättet – nur zum Wiedererkennen über mehrere Durchläufe.
            var point: CGPoint
            /// Die zuletzt gesehene Stelle. Nur die zählt beim Setzen: Der
            /// geglättete Punkt hinkt einem Kameraschwenk hinterher, und ein
            /// Blatt, das an der Stelle von vor einer Sekunde verankert wird,
            /// sitzt sichtbar daneben.
            var lastPoint: CGPoint
            var hits: Int
            /// Aufsummierte Stärke aller Beobachtungen. Nicht die Anzahl:
            /// Ein eindeutiger Stuhl soll schneller erscheinen als eine
            /// zweifelhafte Ecke, und eine feste Zahl von Durchläufen kann
            /// diesen Unterschied nicht machen.
            var evidence: Float
            var lastSeen: TimeInterval
            var placed = false
        }

        private let state: GameState
        private let recognizer = SceneRecognizer()
        private let queue = DispatchQueue(label: "org.gut-einern.gego.vision", qos: .userInitiated)

        private weak var view: ARView?
        private var spots: [Spot] = []
        private var tracks: [Track] = []
        private var isBusy = false
        private var lastRun: TimeInterval = 0
        private var elapsed: Float = 0
        private var sceneUpdates: Cancellable?
        private var nonce = 0

        /// Netze werden einmal gebaut und geteilt.
        private var meshes: [RStrategy: (fill: MeshResource, rim: MeshResource)] = [:]
        private var bloomMeshes: [RStrategy: MeshResource] = [:]

        /// Wie oft ein Fundpunkt ein Minispiel trägt statt etwas zum Lesen.
        /// Selten genug, dass die Blüte etwas bedeutet.
        private let gameChance = 25

        /// Blätter, die gerade verbucht wurden, kommen kurz nicht wieder.
        private var cooldown: [String: TimeInterval] = [:]
        private let cooldownSeconds: TimeInterval = 25

        /// Knapp dreimal pro Sekunde auswerten. Jedes Bild zu analysieren würde
        /// nichts verbessern, aber Akku und Wärme deutlich verschlechtern.
        private let interval: TimeInterval = 0.35

        /// Mindestens so viele Durchläufe, egal wie stark die Beobachtung ist.
        /// Ein einzelnes Bild kann zufällig gut aussehen.
        private let minimumHits = 2

        /// Wie weit eine Beobachtung wandern darf und noch als dieselbe gilt,
        /// als Anteil der Bildschirmbreite. Großzügig, weil die Kamera wackelt.
        private let trackRadius: CGFloat = 0.18

        /// Nach so langer Pause ist eine Vermutung vergessen.
        private let trackMemory: TimeInterval = 2.5

        /// Wenige Punkte gleichzeitig. Ein zugepflasterter Bildschirm ist
        /// unbrauchbar, auch wenn jeder einzelne Punkt stimmt.
        private let maximumSpots = 6

        /// Zwei Punkte desselben Gegenstands dürfen nicht dichter beieinander
        /// stehen als das.
        private let minimumDistance: Float = 1.5

        init(state: GameState) {
            self.state = state
            super.init()

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

                // Die Blüte dreht sich langsam. Ein Minispiel soll auffallen.
                if spot.find.isMiniGame {
                    spot.petal.orientation *= simd_quatf(angle: elapsed * 0.35,
                                                         axis: SIMD3<Float>(0, 0, 1))
                }
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
            recognizer.minimumThemeScore = state.minimumThemeScore
            recognizer.minimumShare = state.minimumShare
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
                state.themeScores = report.themeScores
                state.regionCount = report.regionCount
                state.ripeningCount = tracks.filter { !$0.placed }.count
                state.lastRejection = report.rejections.first
                state.debugBoxes = report.sightings.map {
                    screenRect(for: $0.boundingBox, transform: transform, viewport: viewport)
                }
            }

            tracks.removeAll { now - $0.lastSeen > trackMemory }

            let radius = viewport.width * trackRadius

            for sighting in report.sightings {
                let point = screenPoint(for: sighting.boundingBox, transform: transform, viewport: viewport)
                guard viewport.contains(point) else { continue }

                if let index = tracks.firstIndex(where: {
                    $0.theme == sighting.theme && hypot($0.point.x - point.x, $0.point.y - point.y) < radius
                }) {
                    tracks[index].hits += 1
                    tracks[index].evidence += sighting.score
                    tracks[index].lastSeen = now
                    // Der Punkt wandert mit, damit ein langsamer Schwenk die
                    // Beobachtung nicht abreißen lässt.
                    tracks[index].point = CGPoint(x: (tracks[index].point.x + point.x) / 2,
                                                  y: (tracks[index].point.y + point.y) / 2)
                    tracks[index].lastPoint = point
                    tracks[index].label = sighting.label
                } else {
                    tracks.append(Track(theme: sighting.theme, label: sighting.label,
                                        point: point, lastPoint: point, hits: 1,
                                        evidence: sighting.score, lastSeen: now))
                }
            }

            for index in tracks.indices where !tracks[index].placed
                && tracks[index].hits >= minimumHits
                && tracks[index].evidence >= state.requiredEvidence {
                tracks[index].placed = true
                let track = tracks[index]

                // Erst jetzt zählt es für eine laufende Jagd. Eine Jagd auf
                // Zuckungen wäre keine Beobachtungsaufgabe.
                state.registerSighting(track.label)

                if let until = cooldown[track.label], now < until { continue }
                guard let world = worldPosition(at: track.lastPoint, in: view) else { continue }

                let tooClose = spots.contains {
                    $0.label == track.label && simd_distance($0.position, world) < minimumDistance
                }
                guard !tooClose else { continue }

                nonce += 1
                // Höchstens eine Blüte gleichzeitig in der Szene – sonst nutzt
                // sich das Besondere ab.
                let bloomInScene = spots.contains { $0.find.isMiniGame }
                let wantsGame = !bloomInScene && Int.random(in: 0..<100) < gameChance

                let find: Find?
                if wantsGame {
                    // Ein Minispiel hat mit dem Gegenstand davor nichts zu tun.
                    find = FindResolver.resolveGame(avoiding: state.lastEncounterKind, nonce: nonce)
                } else {
                    find = FindResolver.resolve(label: track.label,
                                                theme: track.theme,
                                                visit: state.findings[track.label] ?? 0,
                                                avoiding: state.lastEncounterKind,
                                                nonce: nonce,
                                                wantsGame: false)
                }
                guard let find else { continue }
                add(find, at: world, in: view)
            }

            state.spotCount = spots.count
            state.status = statusText(report)
        }

        /// Sagt, woran es gerade liegt. Ein stummer Bildschirm ohne Erklärung
        /// ist die schlechteste Rückmeldung, die eine Kamera-App geben kann.
        private func statusText(_ report: RecognitionReport) -> String {
            if !spots.isEmpty {
                return "\(spots.count) \(spots.count == 1 ? "Fundpunkt" : "Fundpunkte") in Sicht"
            }
            let reifend = tracks.filter { !$0.placed }.count
            if reifend > 0 { return "Halt drauf …" }
            if report.regionCount == 0 { return "Halt auf einen einzelnen Gegenstand" }
            return "Suche …"
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

        /// Sucht den Ort im Raum hinter einem Bildschirmpunkt.
        ///
        /// Vier Versuche, von genau nach grob. Der letzte – zwei Meter vor die
        /// Kamera – war lange der einzige Rückfall und ist der Grund, warum
        /// Blätter frei im Raum hingen: Steht der Baum acht Meter weg, klebt
        /// das Blatt trotzdem zwei Meter vor der Nase und wandert beim
        /// nächsten Schritt sichtbar mit.
        private func worldPosition(at point: CGPoint, in view: ARView) -> SIMD3<Float>? {
            // 1. Eine tatsächlich vermessene Fläche.
            if let query = view.makeRaycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .any),
               let hit = view.session.raycast(query).first {
                return simd_make_float3(hit.worldTransform.columns.3)
            }
            // 2. Eine geschätzte Fläche.
            if let query = view.makeRaycastQuery(from: point, allowing: .estimatedPlane, alignment: .any),
               let hit = view.session.raycast(query).first {
                return simd_make_float3(hit.worldTransform.columns.3)
            }
            // 3. Die Punktwolke, die ARKit ohnehin führt. Für alles, was keine
            //    Fläche ist – Baumkronen, Büsche, Geländer –, ist das die
            //    einzige Entfernungsangabe, die es ohne LiDAR gibt.
            if let ray = view.ray(through: point),
               let distance = featureDepth(near: point, in: view) {
                return ray.origin + ray.direction * distance
            }
            // 4. Aufgeben und schätzen.
            if let ray = view.ray(through: point) {
                return ray.origin + ray.direction * 2.5
            }
            return nil
        }

        /// Median der Entfernung aller Merkmalspunkte, die nahe genug am
        /// Bildschirmpunkt liegen.
        ///
        /// Median und nicht Mittelwert: Zwischen Blättern hindurch sieht ARKit
        /// regelmäßig die Hauswand dahinter, und ein einziger solcher Ausreißer
        /// würde den Mittelwert um Meter verschieben.
        private func featureDepth(near point: CGPoint, in view: ARView) -> Float? {
            guard let frame = view.session.currentFrame,
                  let cloud = frame.rawFeaturePoints?.points, !cloud.isEmpty else { return nil }

            let camera = frame.camera.transform.columns.3
            let origin = SIMD3<Float>(camera.x, camera.y, camera.z)
            let radius = view.bounds.width * 0.12

            var distances: [Float] = []
            for world in cloud {
                guard let projected = view.project(world) else { continue }
                guard hypot(projected.x - point.x, projected.y - point.y) < radius else { continue }
                distances.append(simd_distance(origin, world))
            }
            guard distances.count >= 4 else { return nil }
            distances.sort()
            return distances[distances.count / 2]
        }

        // MARK: Der Fundpunkt selbst

        private func mesh(for strategy: RStrategy) -> (fill: MeshResource, rim: MeshResource)? {
            if let cached = meshes[strategy] { return cached }
            guard let fill = PetalMesh.generate(for: strategy, size: 0.16),
                  let rim = PetalMesh.generate(for: strategy, size: 0.16, inflate: 0.16) else { return nil }
            meshes[strategy] = (fill, rim)
            return (fill, rim)
        }

        /// Die ganze Blüte als Marke für ein Minispiel.
        ///
        /// Zehn Teile in ihren Logofarben an ihren Ringplätzen. Man sieht schon
        /// von weitem, dass hier etwas anderes wartet als ein Fun Fact.
        private func bloomEntity() -> Entity {
            let bloom = Entity()
            for strategy in RStrategy.allCases {
                let mesh: MeshResource
                if let cached = bloomMeshes[strategy] {
                    mesh = cached
                } else if let built = PetalMesh.generateInBloom(for: strategy, radius: 0.10) {
                    bloomMeshes[strategy] = built
                    mesh = built
                } else { continue }
                bloom.addChild(ModelEntity(mesh: mesh,
                                           materials: [UnlitMaterial(color: UIColor(strategy.brandColor))]))
            }
            return bloom
        }

        private func add(_ find: Find, at position: SIMD3<Float>, in view: ARView) {
            if find.isMiniGame {
                addEntity(bloomEntity(), for: find, at: position, in: view, hitRadius: 0.12)
                return
            }
            guard let mesh = mesh(for: find.strategy) else { return }

            // Heller Umriss dahinter, minimal größer. Vor einem Kamerabild kann
            // jede Farbe auf jeder Farbe landen; ohne Kante verschwindet ein
            // dunkles Blatt vor einer dunklen Wand.
            let rim = ModelEntity(mesh: mesh.rim,
                                  materials: [UnlitMaterial(color: .white)])
            rim.position.z = -0.002

            let fill = ModelEntity(mesh: mesh.fill,
                                   materials: [UnlitMaterial(color: UIColor(find.strategy.brandColor))])

            let petal = Entity()
            petal.addChild(rim)
            petal.addChild(fill)
            addEntity(petal, for: find, at: position, in: view, hitRadius: 0.10)
        }

        private func addEntity(_ entity: Entity, for find: Find, at position: SIMD3<Float>,
                               in view: ARView, hitRadius: Float) {
            entity.name = find.id

            // Trefferfeld als Kugel: Auf eine papierdünne Fläche zielt niemand.
            let target = ModelEntity()
            target.name = find.id
            target.collision = CollisionComponent(shapes: [.generateSphere(radius: hitRadius)])
            entity.addChild(target)

            let anchor = AnchorEntity(world: position)
            anchor.addChild(entity)
            view.scene.addAnchor(anchor)

            spots.append(Spot(find: find, position: position, anchor: anchor, petal: entity))

            while spots.count > maximumSpots {
                let oldest = spots.removeFirst()
                view.scene.removeAnchor(oldest.anchor)
            }

            UIImpactFeedbackGenerator(style: find.isMiniGame ? .medium : .light).impactOccurred()
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
                  let spot = spots.first(where: { $0.find.id == entity.name }) else { return }

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
