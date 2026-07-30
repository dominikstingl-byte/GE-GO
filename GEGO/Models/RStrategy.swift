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

    /// Von kräftigem Grün oben nach gedämpftem Rotbraun unten. Bleibt
    /// innerhalb der Farbwelt der App, nur weiter aufgefächert.
    var color: Color {
        switch self {
        case .refuse: return Color(UIColor(hex: 0x3F6B4C))
        case .rethink: return Color(UIColor(hex: 0x4F7C5A))
        case .reduce: return Color(UIColor(hex: 0x5F7F66))
        case .reuse: return Color(UIColor(hex: 0x6E8A63))
        case .repair: return Color(UIColor(hex: 0x83905B))
        case .refurbish: return Color(UIColor(hex: 0x9A9455))
        case .remanufacture: return Color(UIColor(hex: 0xAE8F4E))
        case .repurpose: return Color(UIColor(hex: 0xB58146))
        case .recycle: return Color(UIColor(hex: 0xA96C40))
        case .recover: return Color(UIColor(hex: 0x91473D))
        }
    }

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
