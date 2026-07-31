// Liest die Blattkonturen aus dem Gut-Einern-Logo aus und gibt sie als
// Swift-Punktlisten aus – die Vorlage für `Bloom.petal` und `Bloom.blade`.
//
//   swift Tools/kontur.swift [pfad/zum/logo.png]
//
// Ergebnis von Hand nach GEGO/DesignSystem/Bloom.swift übertragen. Das läuft
// selten genug, dass eine Automatik mehr kostet als sie spart.
//
// Der Weg: Farbmaske je Blatt -> Randverfolgung (Moore) -> gleitendes Mittel
// gegen die Treppenstufen der Rasterung -> Douglas-Peucker. Ohne die Glättung
// wellt anschließend jede gerade Kante, weil die Stufen als Formverlauf
// missverstanden werden.

import Foundation
import CoreGraphics
import ImageIO

let path = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Tools/GutEinern_Logo.png"
guard FileManager.default.fileExists(atPath: path) else {
    FileHandle.standardError.write("Logo nicht gefunden: \(path)\n".data(using: .utf8)!)
    exit(1)
}
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = img.width, h = img.height
var data = [UInt8](repeating: 0, count: w*h*4)
let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))

func mask(_ target: (Int,Int,Int), tol: Int = 40) -> [Bool] {
    var m = [Bool](repeating: false, count: w*h)
    for i in 0..<(w*h) {
        let a = Int(data[i*4+3]); if a < 250 { continue }
        let r = Int(data[i*4]), g = Int(data[i*4+1]), b = Int(data[i*4+2])
        if abs(r-target.0) < tol && abs(g-target.1) < tol && abs(b-target.2) < tol { m[i] = true }
    }
    return m
}

// Moore-Nachbarschaft, aeussere Kontur
func trace(_ m: [Bool]) -> [CGPoint] {
    var start = -1
    for i in 0..<(w*h) where m[i] { start = i; break }
    guard start >= 0 else { return [] }
    let dirs = [(1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1),(0,-1),(1,-1)]
    var pts: [CGPoint] = []
    var cur = (start % w, start / w)
    let first = cur
    var d = 0
    var guardCount = 0
    repeat {
        pts.append(CGPoint(x: cur.0, y: cur.1))
        var found = false
        for k in 0..<8 {
            let nd = (d + 6 + k) % 8
            let nx = cur.0 + dirs[nd].0, ny = cur.1 + dirs[nd].1
            if nx >= 0, ny >= 0, nx < w, ny < h, m[ny*w + nx] {
                cur = (nx, ny); d = nd; found = true; break
            }
        }
        if !found { break }
        guardCount += 1
    } while (cur != first && guardCount < 40000)
    return pts
}


// Gleitendes Mittel entlang der Kontur: Die Treppenstufen der Rasterung sind
// Rauschen, kein Formverlauf. Ohne diesen Schritt wellt jede gerade Kante.
func denoise(_ pts: [CGPoint], window: Int) -> [CGPoint] {
    guard pts.count > window * 2 else { return pts }
    let n = pts.count
    var out: [CGPoint] = []
    for i in 0..<n {
        var sx = 0.0, sy = 0.0
        for k in -window...window {
            let p = pts[((i + k) % n + n) % n]
            sx += Double(p.x); sy += Double(p.y)
        }
        let m = Double(window * 2 + 1)
        out.append(CGPoint(x: sx/m, y: sy/m))
    }
    return out
}

// Douglas-Peucker
func simplify(_ pts: [CGPoint], _ eps: Double) -> [CGPoint] {
    guard pts.count > 2 else { return pts }
    func dist(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = b.x-a.x, dy = b.y-a.y
        let n = abs(dy*(p.x-a.x) - dx*(p.y-a.y))
        let d = (dx*dx+dy*dy).squareRoot()
        return d == 0 ? 0 : n/d
    }
    var maxD = 0.0, idx = 0
    for i in 1..<(pts.count-1) {
        let d = dist(pts[i], pts[0], pts[pts.count-1])
        if d > maxD { maxD = d; idx = i }
    }
    if maxD > eps {
        let a = simplify(Array(pts[0...idx]), eps)
        let b = simplify(Array(pts[idx...]), eps)
        return a.dropLast() + b
    }
    return [pts[0], pts[pts.count-1]]
}

let cx = Double(w)/2, cy = Double(h)/2

func dump(_ name: String, _ color: (Int,Int,Int), _ angleDeg: Double, _ eps: Double) {
    let m = mask(color)
    let raw = trace(m)
    let simp = simplify(denoise(raw, window: 7), eps)
    // in lokale Lage drehen: Blattachse zeigt nach oben (+Y in Bildschirmkoordinaten = nach unten,
    // deshalb hier bewusst mathematisch und spaeter in SwiftUI gespiegelt)
    let a = -angleDeg * .pi / 180
    var local: [CGPoint] = []
    for p in simp {
        let dx = Double(p.x) - cx, dy = Double(p.y) - cy
        let rx = dx*cos(a) - dy*sin(a)
        let ry = dx*sin(a) + dy*cos(a)
        local.append(CGPoint(x: rx, y: ry))
    }
    let radius = Double(w)/2
    print("\n// \(name) – \(local.count) Punkte, Kontur aus dem Logo")
    print("// normalisiert auf Logoradius \(Int(radius))px, Ursprung = Blütenmitte")
    var out = "["
    for (i, p) in local.enumerated() {
        if i % 4 == 0 { out += "\n    " }
        out += String(format: "(%.4f, %.4f), ", p.x/radius, p.y/radius)
    }
    print(out + "\n]")
}

dump("Blatt", (0x00,0x71,0xBC), 337.6, 0.9)
dump("Klinge", (0x3A,0x3A,0x3A), 77.4, 1.1)
