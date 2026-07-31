import SwiftUI
import UIKit

/// Die Blüte aus dem Gut-Einern-Logo: neun Blätter im Ring, dazu die große
/// graue Klinge, die den Ring schließt.
///
/// Die Konturen sind **nicht nachgezeichnet**, sondern aus der Logodatei
/// ausgelesen (`Tools/kontur.swift`). Koordinaten sind auf den Logoradius
/// normalisiert, Ursprung ist die Blütenmitte, y wächst nach unten wie in
/// SwiftUI. In der Ruhelage zeigt eine Form nach oben; alle Positionen im Ring
/// entstehen durch Drehung um die Mitte.
///
/// Zehn Formen, zehn R-Stufen – das passt so genau, dass es die Sammlung
/// tragen kann: Jeder Fundpunkt ist das Blatt seiner Stufe, und die Sammlung
/// ist die Blüte, die sich schließt.
enum Bloom {

    /// Ein Blütenblatt in Ruhelage, Spitze oben.
    static let petal: [CGPoint] = [
        CGPoint(x: 0.1227, y: -1.0126), CGPoint(x: 0.1437, y: -0.9956),
        CGPoint(x: 0.1493, y: -0.9615), CGPoint(x: 0.1449, y: -0.7414),
        CGPoint(x: 0.1366, y: -0.6964), CGPoint(x: 0.1195, y: -0.6510),
        CGPoint(x: 0.0745, y: -0.5848), CGPoint(x: 0.0095, y: -0.5349),
        CGPoint(x: -0.0563, y: -0.5098), CGPoint(x: -0.0952, y: -0.5035),
        CGPoint(x: -0.1227, y: -0.5052), CGPoint(x: -0.1419, y: -0.5187),
        CGPoint(x: -0.1483, y: -0.5475), CGPoint(x: -0.1441, y: -0.7758),
        CGPoint(x: -0.1351, y: -0.8245), CGPoint(x: -0.1206, y: -0.8629),
        CGPoint(x: -0.0844, y: -0.9207), CGPoint(x: -0.0291, y: -0.9705),
        CGPoint(x: 0.0426, y: -1.0042), CGPoint(x: 0.0868, y: -1.0134),
        CGPoint(x: 0.1191, y: -1.0136)
    ]

    /// Die graue Klinge – länger, breiter, reicht bis in die Mitte. Sie ist im
    /// Logo die Form, die aus der Reihe fällt, und trägt deshalb R9.
    static let blade: [CGPoint] = [
        CGPoint(x: -0.1687, y: -0.4774), CGPoint(x: -0.0630, y: -0.9585),
        CGPoint(x: -0.0457, y: -0.9967), CGPoint(x: -0.0119, y: -1.0156),
        CGPoint(x: 0.0246, y: -1.0080), CGPoint(x: 0.0702, y: -0.9728),
        CGPoint(x: 0.1116, y: -0.9194), CGPoint(x: 0.1391, y: -0.8636),
        CGPoint(x: 0.1615, y: -0.7859), CGPoint(x: 0.1723, y: -0.7109),
        CGPoint(x: 0.1746, y: -0.6186), CGPoint(x: 0.1671, y: -0.5247),
        CGPoint(x: 0.1537, y: -0.4397), CGPoint(x: 0.1094, y: -0.2585),
        CGPoint(x: 0.0937, y: -0.1473), CGPoint(x: 0.0880, y: -0.0147),
        CGPoint(x: 0.0745, y: 0.0195), CGPoint(x: 0.0470, y: 0.0355),
        CGPoint(x: 0.0003, y: 0.0245), CGPoint(x: -0.0635, y: -0.0155),
        CGPoint(x: -0.1156, y: -0.0728), CGPoint(x: -0.1432, y: -0.1238),
        CGPoint(x: -0.1647, y: -0.1897), CGPoint(x: -0.1789, y: -0.2847),
        CGPoint(x: -0.1797, y: -0.3690), CGPoint(x: -0.1693, y: -0.4737)
    ]

    // MARK: Pfade

    /// Die Kontur als weich geschlossener Pfad. Die ausgelesenen Punkte sind
    /// ein Streckenzug; ohne Glättung sähe das Blatt facettiert aus.
    static func outline(_ points: [CGPoint], transform: CGAffineTransform) -> Path {
        let pts = points.map { $0.applying(transform) }
        return smoothClosedPath(pts)
    }

    /// Eine Form an ihrem Platz im Ring, eingepasst in ein Quadrat.
    static func inBloom(_ strategy: RStrategy, in rect: CGRect) -> Path {
        let side = min(rect.width, rect.height)
        let radius = side / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let transform = CGAffineTransform.identity
            .translatedBy(x: center.x, y: center.y)
            .rotated(by: strategy.bloomAngle * .pi / 180)
            .scaledBy(x: radius, y: radius)
        return outline(strategy.bloomOutline, transform: transform)
    }

    /// Eine einzelne Form aufrecht, formatfüllend – für den Fundpunkt und für
    /// kleine Marken in Listen.
    static func upright(_ strategy: RStrategy, in rect: CGRect) -> Path {
        let points = strategy.bloomOutline
        let box = bounds(of: points)
        let scale = min(rect.width / box.width, rect.height / box.height)
        let transform = CGAffineTransform.identity
            .translatedBy(x: rect.midX, y: rect.midY)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -box.midX, y: -box.midY)
        return outline(points, transform: transform)
    }

    private static func bounds(of points: [CGPoint]) -> CGRect {
        let xs = points.map(\.x), ys = points.map(\.y)
        return CGRect(x: xs.min()!, y: ys.min()!,
                      width: xs.max()! - xs.min()!,
                      height: ys.max()! - ys.min()!)
    }

    /// Catmull-Rom durch alle Punkte, in Bézier übersetzt. Geschlossen, damit
    /// die Blattspitze keine Kante bekommt.
    private static func smoothClosedPath(_ pts: [CGPoint]) -> Path {
        var path = Path()
        guard pts.count > 2 else { return path }
        let n = pts.count
        path.move(to: pts[0])
        for i in 0..<n {
            let p0 = pts[(i - 1 + n) % n]
            let p1 = pts[i]
            let p2 = pts[(i + 1) % n]
            let p3 = pts[(i + 2) % n]
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Formen

/// Ein Blatt an seinem Platz im Ring.
struct BloomPetal: Shape {
    let strategy: RStrategy
    func path(in rect: CGRect) -> Path { Bloom.inBloom(strategy, in: rect) }
}

/// Ein Blatt aufrecht und formatfüllend.
struct UprightPetal: Shape {
    let strategy: RStrategy
    func path(in rect: CGRect) -> Path { Bloom.upright(strategy, in: rect) }
}

// MARK: - Die ganze Blüte

/// Die Sammlung als Bild: Was begriffen ist, leuchtet in seiner Farbe, der
/// Rest bleibt als Umriss stehen. Eine Lücke im Ring zieht stärker als jede
/// Fortschrittsleiste.
struct BloomView: View {

    let filled: (RStrategy) -> Bool
    var highlighted: RStrategy?
    var onTap: ((RStrategy) -> Void)?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(RStrategy.allCases) { strategy in
                    let isFilled = filled(strategy)
                    BloomPetal(strategy: strategy)
                        .fill(isFilled ? strategy.color : Color.clear)
                        .overlay(
                            BloomPetal(strategy: strategy)
                                .stroke(isFilled ? Color.clear : Palette.separator,
                                        style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                        )
                        .scaleEffect(highlighted == strategy ? 1.06 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isFilled)
                        .contentShape(BloomPetal(strategy: strategy))
                        .onTapGesture { onTap?(strategy) }
                        .accessibilityLabel("\(strategy.code) \(strategy.title)")
                        .accessibilityValue(isFilled ? "begriffen" : "offen")
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Blatt als Bild

extension Bloom {

    /// Zeichnet ein Blatt als Bild mit durchsichtigem Grund – so wandert es als
    /// Textur auf den Fundpunkt in der AR-Szene.
    ///
    /// Der helle Rand ist kein Zierrat: Vor einem Kamerabild kann jede Farbe
    /// auf jeder Farbe landen, und ohne Kante verschwindet ein dunkles Blatt
    /// vor einer dunklen Wand.
    static func texture(for strategy: RStrategy, side: CGFloat = 256) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side),
                                               format: format)
        return renderer.image { context in
            let cg = context.cgContext
            let inset = side * 0.12
            let rect = CGRect(x: inset, y: inset, width: side - 2 * inset, height: side - 2 * inset)
            let path = Bloom.upright(strategy, in: rect).cgPath

            // Weicher Schein nach außen, damit der Punkt auch vor unruhigem
            // Hintergrund als Objekt gelesen wird.
            cg.saveGState()
            cg.setShadow(offset: .zero, blur: side * 0.07,
                         color: UIColor.black.withAlphaComponent(0.55).cgColor)
            cg.addPath(path)
            cg.setFillColor(UIColor(strategy.brandColor).cgColor)
            cg.fillPath()
            cg.restoreGState()

            cg.addPath(path)
            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.92).cgColor)
            cg.setLineWidth(side * 0.022)
            cg.setLineJoin(.round)
            cg.strokePath()
        }
    }
}
