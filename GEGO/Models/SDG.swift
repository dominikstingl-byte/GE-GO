import SwiftUI

/// Die 17 Nachhaltigkeitsziele der Vereinten Nationen.
///
/// Im Spiel sind sie nicht die Mechanik – das sind die R-Strategien –, sondern
/// der Rahmen darüber: Jeder Fund zeigt, auf welches große Ziel er einzahlt.
/// So lernt man die Leiter beim Spielen und die Ziele nebenbei.
enum SDG: Int, CaseIterable, Identifiable, Codable, Sendable {
    case noPoverty = 1
    case zeroHunger = 2
    case goodHealth = 3
    case qualityEducation = 4
    case genderEquality = 5
    case cleanWater = 6
    case affordableEnergy = 7
    case decentWork = 8
    case industryInnovation = 9
    case reducedInequalities = 10
    case sustainableCities = 11
    case responsibleConsumption = 12
    case climateAction = 13
    case lifeBelowWater = 14
    case lifeOnLand = 15
    case peaceJustice = 16
    case partnerships = 17

    var id: Int { rawValue }

    var code: String { "SDG \(rawValue)" }

    var title: String {
        switch self {
        case .noPoverty: return "Keine Armut"
        case .zeroHunger: return "Kein Hunger"
        case .goodHealth: return "Gesundheit und Wohlergehen"
        case .qualityEducation: return "Hochwertige Bildung"
        case .genderEquality: return "Geschlechtergleichheit"
        case .cleanWater: return "Sauberes Wasser und Sanitäreinrichtungen"
        case .affordableEnergy: return "Bezahlbare und saubere Energie"
        case .decentWork: return "Menschenwürdige Arbeit und Wirtschaftswachstum"
        case .industryInnovation: return "Industrie, Innovation und Infrastruktur"
        case .reducedInequalities: return "Weniger Ungleichheiten"
        case .sustainableCities: return "Nachhaltige Städte und Gemeinden"
        case .responsibleConsumption: return "Nachhaltiger Konsum und Produktion"
        case .climateAction: return "Maßnahmen zum Klimaschutz"
        case .lifeBelowWater: return "Leben unter Wasser"
        case .lifeOnLand: return "Leben an Land"
        case .peaceJustice: return "Frieden, Gerechtigkeit und starke Institutionen"
        case .partnerships: return "Partnerschaften zur Erreichung der Ziele"
        }
    }

    var symbolName: String {
        switch self {
        case .noPoverty: return "house"
        case .zeroHunger: return "carrot"
        case .goodHealth: return "heart"
        case .qualityEducation: return "book"
        case .genderEquality: return "equal.circle"
        case .cleanWater: return "drop"
        case .affordableEnergy: return "bolt"
        case .decentWork: return "hammer"
        case .industryInnovation: return "gearshape.2"
        case .reducedInequalities: return "arrow.left.and.right"
        case .sustainableCities: return "building.2"
        case .responsibleConsumption: return "arrow.3.trianglepath"
        case .climateAction: return "thermometer.sun"
        case .lifeBelowWater: return "fish"
        case .lifeOnLand: return "leaf"
        case .peaceJustice: return "scalemass"
        case .partnerships: return "hands.sparkles"
        }
    }
}
