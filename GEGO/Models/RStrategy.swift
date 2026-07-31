import SwiftUI

/// Die zehn R-Strategien der Kreislaufwirtschaft, von der wirksamsten zur
/// schwächsten. Die Reihenfolge ist das Rückgrat des Spiels: Ein Fund auf
/// Stufe 0 wiegt schwerer als einer auf Stufe 9, und die Sammlung ist erst
/// voll, wenn alle zehn Stufen mindestens einmal begriffen wurden.
enum RStrategy: Int, CaseIterable, Identifiable, Codable, Sendable {
    case refuse = 0
    case rethink = 1
    case reduce = 2
    case reuse = 3
    case repair = 4
    case refurbish = 5
    case remanufacture = 6
    case repurpose = 7
    case recycle = 8
    case recover = 9

    var id: Int { rawValue }

    /// Kurzzeichen für die Anzeige am Fundpunkt.
    var code: String { "R\(rawValue)" }

    /// Der englische Fachbegriff – so steht er in der Literatur.
    var term: String {
        switch self {
        case .refuse: return "Refuse"
        case .rethink: return "Rethink"
        case .reduce: return "Reduce"
        case .reuse: return "Reuse"
        case .repair: return "Repair"
        case .refurbish: return "Refurbish"
        case .remanufacture: return "Remanufacture"
        case .repurpose: return "Repurpose"
        case .recycle: return "Recycle"
        case .recover: return "Recover"
        }
    }

    var title: String {
        switch self {
        case .refuse: return "Verweigern"
        case .rethink: return "Umdenken"
        case .reduce: return "Verringern"
        case .reuse: return "Weiternutzen"
        case .repair: return "Reparieren"
        case .refurbish: return "Aufarbeiten"
        case .remanufacture: return "Neu fertigen"
        case .repurpose: return "Umwidmen"
        case .recycle: return "Verwerten"
        case .recover: return "Energie zurückholen"
        }
    }

    var summary: String {
        switch self {
        case .refuse:
            return "Das Ding gar nicht erst in Umlauf bringen. Die wirksamste Stufe – und die unbequemste."
        case .rethink:
            return "Denselben Zweck anders erfüllen: teilen, leihen, gemeinsam nutzen statt jeder für sich."
        case .reduce:
            return "Weniger Material, weniger Energie, längere Haltbarkeit für dieselbe Leistung."
        case .reuse:
            return "Ein noch brauchbares Ding wandert weiter, statt ersetzt zu werden."
        case .repair:
            return "Der Defekt wird behoben, das Ding bleibt dasselbe."
        case .refurbish:
            return "Ein altes Ding wird als Ganzes überholt und wieder auf Stand gebracht."
        case .remanufacture:
            return "Teile aus Altgeräten wandern in ein neues Produkt mit voller Garantie."
        case .repurpose:
            return "Das Ding bekommt eine völlig neue Aufgabe, für die es nie gedacht war."
        case .recycle:
            return "Nur noch das Material bleibt erhalten, die Gestalt geht verloren."
        case .recover:
            return "Am Ende bleibt Verbrennen mit Energiegewinn. Besser als Deponie, sonst nichts."
        }
    }

    /// Wie viel ein Fund auf dieser Stufe zählt. Vermeiden schlägt Verwerten –
    /// das soll sich auch in der Punktzahl zeigen.
    var value: Int { (10 - rawValue) * 5 }

    // MARK: Farbe und Form aus dem Logo

    /// Die Farbe des zugehörigen Blütenblatts, exakt aus der Logodatei
    /// ausgelesen.
    ///
    /// Die Zuordnung ist nicht frei gewählt: Die neun bunten Blätter laufen im
    /// Logo gegen den Uhrzeigersinn durch das Spektrum, von Violett über Grün
    /// bis Dunkelrot. Genau in dieser Reihenfolge nehmen sie R0 bis R8 auf. Die
    /// graue Klinge schließt den Ring und trägt R9 – die Stufe, auf der nur
    /// noch Verbrennen übrig bleibt. Asche am Ende der Kette.
    var brandHex: UInt32 {
        switch self {
        case .refuse: return 0x6F2B90
        case .rethink: return 0x0071BC
        case .reduce: return 0x0088B9
        case .reuse: return 0x008E83
        case .repair: return 0x1EAA4A
        case .refurbish: return 0xDEC023
        case .remanufacture: return 0xF99D1B
        case .repurpose: return 0xB82837
        case .recycle: return 0x8D2F45
        case .recover: return 0x3A3A3A
        }
    }

    /// Der unveränderte Markenton – für Blätter und Fundpunkte, wo die Farbe
    /// Fläche ist und nicht gelesen werden muss.
    var brandColor: Color { Color(UIColor(hex: brandHex)) }

    /// Derselbe Ton, aber auf Lesbarkeit gezogen. Reines Logogelb auf hellem
    /// Grund ist Schrift, die niemand entziffert.
    var color: Color {
        Color(UIColor { traits in
            let base = UIColor(hex: brandHex)
            return traits.userInterfaceStyle == .dark
                ? base.withBrightness(atLeast: 0.62)
                : base.withBrightness(atMost: 0.58)
        })
    }

    /// Wo das Blatt im Ring steht, in Grad im Uhrzeigersinn von oben.
    /// Gemessen an den Schwerpunkten im Logo, nicht gerundet – die Blüte ist
    /// minimal unregelmäßig, und das soll sie bleiben.
    var bloomAngle: Double {
        switch self {
        case .refuse: return 7.3
        case .rethink: return 337.6
        case .reduce: return 308.2
        case .reuse: return 278.8
        case .repair: return 249.4
        case .refurbish: return 219.7
        case .remanufacture: return 189.6
        case .repurpose: return 159.4
        case .recycle: return 128.7
        case .recover: return 77.4
        }
    }

    /// R9 bekommt die große Klinge, alle anderen das schlanke Blatt.
    var bloomOutline: [CGPoint] { self == .recover ? Bloom.blade : Bloom.petal }

    var symbolName: String {
        switch self {
        case .refuse: return "hand.raised"
        case .rethink: return "lightbulb"
        case .reduce: return "arrow.down.right.circle"
        case .reuse: return "arrow.triangle.2.circlepath"
        case .repair: return "wrench.and.screwdriver"
        case .refurbish: return "sparkles"
        case .remanufacture: return "shippingbox"
        case .repurpose: return "arrow.triangle.branch"
        case .recycle: return "arrow.3.trianglepath"
        case .recover: return "flame"
        }
    }
}
