import CoreGraphics
import Foundation
import RealityKit

/// Baut aus einer Blattkontur ein echtes Netz.
///
/// Der erste Versuch lief über eine Textur mit durchsichtigem Grund auf einer
/// quadratischen Fläche. Das ist in RealityKit unzuverlässig: Ob der
/// Alphakanal wirklich durchkommt, hängt an Material, Blending und daran, wie
/// die Textur erzeugt wurde – und wenn etwas davon nicht passt, steht das
/// Blatt auf einem schwarzen Quadrat.
///
/// Ein Netz in Blattform hat das Problem nicht. Es gibt kein Drumherum, das
/// sichtbar werden könnte, die Kanten bleiben in jeder Entfernung scharf, und
/// die Farbe ist einfach die Farbe.
enum PetalMesh {

    /// Netzform eines Blattes, eingepasst in ein Quadrat der Kantenlänge
    /// `size`, liegend in der XY-Ebene mit Blick nach +Z.
    static func generate(for strategy: RStrategy, size: Float, inflate: CGFloat = 0) -> MeshResource? {
        var points = normalized(strategy.bloomOutline)
        if inflate != 0 { points = expanded(points, by: inflate) }

        let indices = triangulate(points)
        guard !indices.isEmpty else { return nil }

        let positions = points.map {
            SIMD3<Float>(Float($0.x) * size, Float($0.y) * size, 0)
        }

        var descriptor = MeshDescriptor(name: "petal-\(strategy.rawValue)")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(
            Array(repeating: SIMD3<Float>(0, 0, 1), count: positions.count))

        // Beide Umlaufrichtungen: Das Blatt dreht sich zwar zur Kamera, aber
        // ein Netz, das nur von einer Seite sichtbar ist, verschwindet bei
        // jedem Ausrutscher der Ausrichtung.
        var doubled = indices
        for triangle in stride(from: 0, to: indices.count, by: 3) {
            doubled.append(contentsOf: [indices[triangle + 2],
                                        indices[triangle + 1],
                                        indices[triangle]])
        }
        descriptor.primitives = .triangles(doubled)

        return try? MeshResource.generate(from: [descriptor])
    }

    /// Ein Blatt an seinem Platz im Ring – für die ganze Blüte.
    ///
    /// Anders als `generate` wird hier **nicht** zentriert: Die Kontur behält
    /// ihre Lage zur Blütenmitte, wird gedreht und auf den Radius skaliert.
    /// Nur so setzen sich die zehn Teile wieder zum Logo zusammen.
    static func generateInBloom(for strategy: RStrategy, radius: Float) -> MeshResource? {
        let angle = CGFloat(strategy.bloomAngle) * .pi / 180
        let points = strategy.bloomOutline.map { point -> CGPoint in
            // Im Uhrzeigersinn drehen, y zeigt wie in SwiftUI nach unten.
            CGPoint(x: point.x * cos(angle) - point.y * sin(angle),
                    y: point.x * sin(angle) + point.y * cos(angle))
        }

        let indices = triangulate(points)
        guard !indices.isEmpty else { return nil }

        // y umdrehen: In der AR-Szene zeigt y nach oben, in der Kontur nach unten.
        let positions = points.map {
            SIMD3<Float>(Float($0.x) * radius, Float(-$0.y) * radius, 0)
        }

        var descriptor = MeshDescriptor(name: "bloom-\(strategy.rawValue)")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(
            Array(repeating: SIMD3<Float>(0, 0, 1), count: positions.count))

        var doubled = indices
        for triangle in stride(from: 0, to: indices.count, by: 3) {
            doubled.append(contentsOf: [indices[triangle + 2],
                                        indices[triangle + 1],
                                        indices[triangle]])
        }
        descriptor.primitives = .triangles(doubled)
        return try? MeshResource.generate(from: [descriptor])
    }

    // MARK: Kontur aufbereiten

    /// Verschiebt die Kontur in ihren eigenen Mittelpunkt und skaliert sie so,
    /// dass die längere Seite genau 1 misst.
    private static func normalized(_ points: [CGPoint]) -> [CGPoint] {
        let xs = points.map(\.x), ys = points.map(\.y)
        let minX = xs.min()!, maxX = xs.max()!
        let minY = ys.min()!, maxY = ys.max()!
        let midX = (minX + maxX) / 2, midY = (minY + maxY) / 2
        let extent = max(maxX - minX, maxY - minY)
        guard extent > 0 else { return points }
        return points.map { CGPoint(x: ($0.x - midX) / extent, y: ($0.y - midY) / extent) }
    }

    /// Schiebt jeden Punkt ein Stück vom Mittelpunkt weg – so entsteht aus
    /// derselben Kontur der etwas größere heller Umriss, der dahinter liegt.
    private static func expanded(_ points: [CGPoint], by amount: CGFloat) -> [CGPoint] {
        points.map { CGPoint(x: $0.x * (1 + amount), y: $0.y * (1 + amount)) }
    }

    // MARK: Ohrenschneiden

    /// Zerlegt ein einfaches Polygon in Dreiecke.
    ///
    /// Ohrenschneiden statt Dreiecksfächer: Ein Fächer vom Schwerpunkt aus
    /// funktioniert nur bei sternförmigen Formen. Das schlanke Blatt wäre kein
    /// Problem, die lange Klinge womöglich schon – und ein Netz, das an einer
    /// Stelle nach innen klappt, fällt erst am Gerät auf.
    private static func triangulate(_ points: [CGPoint]) -> [UInt32] {
        guard points.count >= 3 else { return [] }

        // Gegen den Uhrzeigersinn ausrichten, damit die Prüfungen unten stimmen.
        var order = Array(points.indices)
        if signedArea(points) < 0 { order.reverse() }

        var indices: [UInt32] = []
        var guardCount = 0
        let limit = points.count * points.count

        while order.count > 3 && guardCount < limit {
            guardCount += 1
            var clipped = false

            for position in order.indices {
                let previous = order[(position + order.count - 1) % order.count]
                let current = order[position]
                let next = order[(position + 1) % order.count]

                let a = points[previous], b = points[current], c = points[next]
                guard cross(a, b, c) > 0 else { continue }   // nach innen geklappt

                // Ein Ohr darf keinen anderen Punkt enthalten.
                let containsOther = order.contains { index in
                    index != previous && index != current && index != next
                        && isInside(points[index], a, b, c)
                }
                guard !containsOther else { continue }

                indices.append(contentsOf: [UInt32(previous), UInt32(current), UInt32(next)])
                order.remove(at: position)
                clipped = true
                break
            }

            if !clipped { break }   // entartetes Polygon, lieber abbrechen
        }

        if order.count == 3 {
            indices.append(contentsOf: order.map { UInt32($0) })
        }
        return indices
    }

    private static func signedArea(_ points: [CGPoint]) -> CGFloat {
        var sum: CGFloat = 0
        for index in points.indices {
            let a = points[index], b = points[(index + 1) % points.count]
            sum += a.x * b.y - b.x * a.y
        }
        return sum / 2
    }

    private static func cross(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGFloat {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    private static func isInside(_ point: CGPoint, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
        let d1 = cross(a, b, point), d2 = cross(b, c, point), d3 = cross(c, a, point)
        let hasNegative = d1 < 0 || d2 < 0 || d3 < 0
        let hasPositive = d1 > 0 || d2 > 0 || d3 > 0
        return !(hasNegative && hasPositive)
    }
}
