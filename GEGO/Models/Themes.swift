import Foundation

/// Eine Begegnung samt ihrer Einordnung.
///
/// Anders als beim Handkatalog hängt die R-Stufe hier **an der einzelnen
/// Begegnung**, nicht am Gegenstand. Das ist der Unterschied, der einen
/// Holzboden erträglich macht: Beim ersten Mal geht es ums Reparieren (R4),
/// beim zweiten ums Umwidmen (R7), beim dritten ums Verwerten (R8). Derselbe
/// Boden zahlt nacheinander auf verschiedene Blätter ein.
struct ThemedEncounter {
    let strategy: RStrategy
    let sdgs: [SDG]
    let encounter: Encounter
}

/// Das Auffangnetz unter dem Handkatalog.
///
/// Die Erkennung kennt 1303 Begriffe, der Handkatalog beschreibt 40 davon
/// einzeln. Ohne Netz wäre alles andere ein Fundpunkt, der nie erscheint –
/// man liefe durch die Wohnung und die App bliebe stumm. Das Thema ist gröber
/// als ein Handeintrag, aber es ist nie leer.
///
/// Welcher Begriff zu welchem Thema gehört, steht in `ThemeMapping.swift` und
/// wird von `Tools/themen.swift` erzeugt.
enum Theme: String, CaseIterable, Identifiable {

    // Werkstoffe
    case wood, metal, glass, paper, textile, plastic

    // Dinge im Haus
    case tool, electronics, appliance, furniture, tableware, hygiene

    // Systeme
    case energy, water, waste, building, vehicle

    // Essen und Trinken
    case plantFood, animalFood, processedFood, drink

    // Lebendiges und Draußen
    case animal, plant, landscape

    // Der Rest
    case sport, instrument, stuff

    var id: String { rawValue }

    /// Was als Überschrift über dem Fund steht. Bewusst der Werkstoff oder die
    /// Gattung und nicht der erkannte Begriff: „Holz“ ist ehrlicher als
    /// „wood_processed“, und für 1303 Begriffe deutsche Namen zu pflegen wäre
    /// Arbeit ohne Ertrag – wer den Gegenstand vor sich sieht, weiß, was es ist.
    var name: String {
        switch self {
        case .wood: return "Holz"
        case .metal: return "Metall"
        case .glass: return "Glas"
        case .paper: return "Papier"
        case .textile: return "Textil"
        case .plastic: return "Kunststoff"
        case .tool: return "Werkzeug"
        case .electronics: return "Elektronik"
        case .appliance: return "Haushaltsgerät"
        case .furniture: return "Möbel"
        case .tableware: return "Geschirr"
        case .hygiene: return "Körperpflege"
        case .energy: return "Energie"
        case .water: return "Wasser"
        case .waste: return "Abfall"
        case .building: return "Gebautes"
        case .vehicle: return "Verkehr"
        case .plantFood: return "Pflanzliches"
        case .animalFood: return "Tierisches"
        case .processedFood: return "Verarbeitetes"
        case .drink: return "Getränk"
        case .animal: return "Tier"
        case .plant: return "Pflanze"
        case .landscape: return "Landschaft"
        case .sport: return "Sport"
        case .instrument: return "Instrument"
        case .stuff: return "Gegenstand"
        }
    }

    /// Wonach man suchen kann, wenn ein Blatt noch fehlt. Steht in der Sammlung.
    var searchHint: String {
        switch self {
        case .wood: return "Tisch, Boden, Baum"
        case .metal: return "Besteck, Zaun, Rohr"
        case .glass: return "Fenster, Glas, Flasche"
        case .paper: return "Buch, Karton, Zeitung"
        case .textile: return "Jacke, Vorhang, Schuh"
        case .plastic: return "Flasche, Eimer, Spielzeug"
        case .tool: return "Hammer, Schere, Besen"
        case .electronics: return "Laptop, Handy, Lampe"
        case .appliance: return "Kühlschrank, Herd, Wasserkocher"
        case .furniture: return "Stuhl, Regal, Bett"
        case .tableware: return "Teller, Schüssel, Gabel"
        case .hygiene: return "Brille, Seife, Zahnbürste"
        case .energy: return "Glühbirne, Kerze, Steckdose"
        case .water: return "Wasserhahn, Spüle, Dusche"
        case .waste: return "Mülleimer"
        case .building: return "Haus, Straße, Brücke"
        case .vehicle: return "Auto, Fahrrad, Bus"
        case .plantFood: return "Apfel, Kartoffel, Brot"
        case .animalFood: return "Käse, Ei, Fleisch"
        case .processedFood: return "Pizza, Keks, Schokolade"
        case .drink: return "Kaffee, Saft, Bier"
        case .animal: return "Hund, Vogel, Insekt"
        case .plant: return "Blume, Gras, Topfpflanze"
        case .landscape: return "Himmel, Berg, Strand"
        case .sport: return "Ball, Fahrrad, Turnschuh"
        case .instrument: return "Gitarre, Klavier, Trommel"
        case .stuff: return "irgendetwas"
        }
    }

    /// Die Begegnungen dieses Themas. Inhalte stehen in den beiden
    /// `ThemeContent+…`-Dateien, damit diese hier lesbar bleibt.
    var encounters: [ThemedEncounter] {
        switch self {
        case .wood: return Self.woodEncounters
        case .metal: return Self.metalEncounters
        case .glass: return Self.glassEncounters
        case .paper: return Self.paperEncounters
        case .textile: return Self.textileEncounters
        case .plastic: return Self.plasticEncounters
        case .tool: return Self.toolEncounters
        case .electronics: return Self.electronicsEncounters
        case .appliance: return Self.applianceEncounters
        case .furniture: return Self.furnitureEncounters
        case .tableware: return Self.tablewareEncounters
        case .hygiene: return Self.hygieneEncounters
        case .energy: return Self.energyEncounters
        case .water: return Self.waterEncounters
        case .waste: return Self.wasteEncounters
        case .building: return Self.buildingEncounters
        case .vehicle: return Self.vehicleEncounters
        case .plantFood: return Self.plantFoodEncounters
        case .animalFood: return Self.animalFoodEncounters
        case .processedFood: return Self.processedFoodEncounters
        case .drink: return Self.drinkEncounters
        case .animal: return Self.animalEncounters
        case .plant: return Self.plantEncounters
        case .landscape: return Self.landscapeEncounters
        case .sport: return Self.sportEncounters
        case .instrument: return Self.instrumentEncounters
        case .stuff: return Self.stuffEncounters
        }
    }

    /// Welche Themen überhaupt eine Begegnung zu dieser R-Stufe haben.
    /// Grundlage für die Suchhinweise in der Sammlung – eine Stufe, zu der man
    /// nichts findet, ist ein Konstruktionsfehler und kein Rätsel.
    static func offering(_ strategy: RStrategy) -> [Theme] {
        allCases.filter { theme in
            theme.encounters.contains { $0.strategy == strategy }
        }
    }

    /// Welches Thema hinter einem erkannten Begriff steckt.
    ///
    /// `nil` heißt: bewusst ausgeschlossen (Menschen vor allem). Unbekannte
    /// Begriffe – etwa aus einer künftigen iOS-Fassung – landen in `.stuff`
    /// statt im Nichts.
    static func forLabel(_ label: String) -> Theme? {
        if ThemeMapping.excluded.contains(label) { return nil }
        return ThemeMapping.byLabel[label] ?? .stuff
    }

    /// Begriffe, die eine Szene beschreiben statt eines Gegenstands.
    ///
    /// Die Taxonomie ist hierarchisch, und die Wurzeln passen auf alles: Eine
    /// Wand ist `material`, ein Zimmer ist `interior_room`, jede Fläche ist
    /// `structure`. Drinnen gewinnen genau diese Begriffe fast immer, weil das
    /// Bild überwiegend aus Wand, Boden und Möbelrücken besteht.
    ///
    /// Sie dürfen für ein Thema stimmen – ein `furniture` unter fünf
    /// Stuhlvarianten ist ein gutes Argument. Aber sie dürfen einen Fund nicht
    /// **benennen**, sonst heißt gefühlt jeder zweite Fund „Gegenstand“.
    static let genericLabels: Set<String> = [
        "material", "structure", "object", "thing", "pattern", "texture",
        "interior_room", "interior_shop", "domicile", "outdoor", "land",
        "landscape", "liquid", "light", "decoration", "machine", "housewares",
        "conveyance", "container", "art", "media", "recreation", "sport",
        "games", "music", "performance", "celebration", "daytime", "frozen"
    ]

    static func isGeneric(_ label: String) -> Bool { genericLabels.contains(label) }

    /// Begriffe, die den **Raum** beschreiben, in dem man steht – nicht den
    /// Gegenstand, auf den man hält.
    ///
    /// Diese stimmen gar nicht erst mit, auch nicht für ihr eigenes Thema.
    /// Grund: Wer in der Küche auf den Kühlschrank hält, bekommt von der
    /// Klassifikation `kitchen`, `kitchen_room` und `interior_room` gratis dazu.
    /// Drei Stimmen für „Gebautes" gegen eine für „Haushaltsgerät" – der
    /// Kühlschrank verliert gegen den Raum, in dem er steht.
    ///
    /// Bewusst nur Innenräume. `forest`, `park` oder `garden` sind draußen
    /// sehr wohl das, worauf man schaut.
    static let sceneLabels: Set<String> = [
        "interior_room", "interior_shop", "domicile", "apartment",
        "kitchen", "kitchen_room", "bathroom", "bathroom_room",
        "living_room", "dining_room", "bedroom", "classroom", "cellar",
        "garage", "cubicle", "restaurant", "bar", "library", "museum",
        "hospital", "health_club", "airport", "train_station", "arena",
        "stadium", "zoo", "auditorium"
    ]

    static func votesForTheme(_ label: String) -> Bool { !sceneLabels.contains(label) }
}
