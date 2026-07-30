import ARKit
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
            let label: String
            let position: SIMD3<Float>
            let anchor: AnchorEntity
        }

        private let state: GameState
        private let recognizer = SceneRecognizer()
        private let queue = DispatchQueue(label: "org.gut-einern.gego.vision", qos: .userInitiated)

        private weak var view: ARView?
        private var spots: [Spot] = []
        private var isBusy = false
        private var lastRun: TimeInterval = 0

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
        }

        func attach(to view: ARView) {
            self.view = view
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

            queue.async { [weak self] in
                guard let self else { return }
                let sightings = recognizer.sightings(in: buffer, orientation: .right)
                DispatchQueue.main.async {
                    self.place(sightings, transform: transform, viewport: viewport)
                    self.isBusy = false
                }
            }
        }

        // MARK: Punkte setzen

        private func place(_ sightings: [Sighting], transform: CGAffineTransform, viewport: CGSize) {
            guard let view else { return }

            for sighting in sightings {
                guard let entry = ObjectCatalog.entry(for: sighting.label) else { continue }

                let point = screenPoint(for: sighting.boundingBox, transform: transform, viewport: viewport)
                guard viewport.contains(point) else { continue }
                guard let world = worldPosition(at: point, in: view) else { continue }

                let tooClose = spots.contains {
                    $0.label == sighting.label && simd_distance($0.position, world) < minimumDistance
                }
                guard !tooClose else { continue }

                add(entry, at: world, in: view)
            }

            state.spotCount = spots.count
            state.status = spots.isEmpty
                ? "Halt die Kamera auf deine Umgebung"
                : "\(spots.count) Fundpunkte in Sicht"
        }

        /// Rechnet einen Vision-Kasten in einen Punkt auf dem Bildschirm um.
        ///
        /// Vision zählt von unten links, der Bildschirm von oben links, und
        /// dazwischen liegt noch der Zuschnitt des Kamerabilds auf das Fenster.
        /// Falls die Punkte auf dem Gerät versetzt sitzen, ist hier die Stelle,
        /// an der nachzujustieren ist.
        private func screenPoint(for box: CGRect, transform: CGAffineTransform, viewport: CGSize) -> CGPoint {
            let center = CGPoint(x: box.midX, y: 1 - box.midY)
            let mapped = center.applying(transform)
            return CGPoint(x: mapped.x * viewport.width, y: mapped.y * viewport.height)
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

        private func add(_ entry: CatalogEntry, at position: SIMD3<Float>, in view: ARView) {
            let color = UIColor(entry.strategy.color)
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.07),
                                     materials: [UnlitMaterial(color: color)])
            sphere.name = entry.label
            sphere.generateCollisionShapes(recursive: false)

            let anchor = AnchorEntity(world: position)
            anchor.addChild(sphere)
            view.scene.addAnchor(anchor)

            spots.append(Spot(label: entry.label, position: position, anchor: anchor))

            while spots.count > maximumSpots {
                let oldest = spots.removeFirst()
                view.scene.removeAnchor(oldest.anchor)
            }
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
                  let entry = ObjectCatalog.entry(for: entity.name) else { return }

            remove(entry.label, in: view)
            state.activeEntry = entry
        }
    }
}

private extension CGSize {
    func contains(_ point: CGPoint) -> Bool {
        point.x >= 0 && point.y >= 0 && point.x <= width && point.y <= height
    }
}
