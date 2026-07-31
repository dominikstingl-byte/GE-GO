import Foundation

/// Ein Fund, wie ihn der Spieler erlebt: ein Gegenstand, eine Begegnung, eine
/// R-Stufe.
///
/// Aufgelöst wird schon beim **Setzen** des Fundpunkts, nicht erst beim
/// Antippen. Das hat einen sichtbaren Grund: Der Fundpunkt ist das Blatt seiner
/// R-Stufe, und die Farbe muss stimmen, bevor jemand tippt. Wer noch R4
/// braucht, soll im Raum nach einem grünen Blatt suchen können.
struct Find: Identifiable {
    let label: String
    /// Was über dem Fund steht – beim Handeintrag der Gegenstand („Flasche“),
    /// beim Thema der Werkstoff („Holz“).
    let name: String
    let strategy: RStrategy
    let sdgs: [SDG]
    let encounter: Encounter
    /// Ob der Inhalt aus dem Handkatalog stammt oder aus dem Themennetz.
    let isHandwritten: Bool

    /// Zwei Fundpunkte desselben Gegenstands sollen sich unterscheiden lassen.
    let id: String

    var kindLabel: String { encounter.kindLabel }
}

/// Übersetzt einen erkannten Begriff in einen Fund.
///
/// Zwei Ebenen: Erst der Handkatalog mit seinen ausgearbeiteten Gegenständen,
/// darunter das Themennetz für alles andere. Die Erkennung kennt 1303 Begriffe;
/// ohne die zweite Ebene bliebe die App bei fast allem stumm.
enum FindResolver {

    /// Alle Begriffe, aus denen ein Fundpunkt werden kann. Das ist praktisch
    /// die ganze Taxonomie – abzüglich dessen, was bewusst ausgeschlossen ist.
    static let playableLabels: Set<String> = {
        var labels = Set(ThemeMapping.byLabel.keys)
        labels.formUnion(ObjectCatalog.knownLabels)
        labels.subtract(ThemeMapping.excluded)
        return labels
    }()

    /// `visit` ist die Anzahl bisheriger Funde dieses Begriffs, `lastKind` die
    /// zuletzt gezeigte Art. Beides zusammen sorgt dafür, dass ein Holzboden
    /// beim zweiten Antippen etwas anderes erzählt als beim ersten – und nicht
    /// zweimal hintereinander dasselbe Format bringt.
    static func resolve(label: String, theme knownTheme: Theme? = nil,
                        visit: Int, avoiding lastKind: String?, nonce: Int = 0) -> Find? {
        if let entry = ObjectCatalog.entry(for: label) {
            let encounter = entry.encounter(forVisit: visit, avoiding: lastKind)
            return Find(label: label,
                        name: entry.name,
                        strategy: entry.strategy,
                        sdgs: entry.sdgs,
                        encounter: encounter,
                        isHandwritten: true,
                        id: "\(label)#\(nonce)")
        }

        // Das Thema kommt aus der Abstimmung über alle Vorschläge und ist
        // belastbarer als eine Ableitung aus dem einen Begriff.
        guard let theme = knownTheme ?? Theme.forLabel(label) else { return nil }
        let pool = theme.encounters
        guard !pool.isEmpty else { return nil }

        let start = visit % pool.count
        var chosen = pool[start]
        for offset in 0..<pool.count {
            let candidate = pool[(start + offset) % pool.count]
            if candidate.encounter.kindLabel != lastKind { chosen = candidate; break }
        }

        return Find(label: label,
                    name: theme.name,
                    strategy: chosen.strategy,
                    sdgs: chosen.sdgs,
                    encounter: chosen.encounter,
                    isHandwritten: false,
                    id: "\(label)#\(nonce)")
    }
}

/// Eine laufende Jagd.
///
/// Das einzige Minispiel, das das Blatt verlässt: Es schickt den Spieler los
/// und wird von der Kamera abgenommen, nicht von einer Schaltfläche.
struct HuntRun {
    let hunt: Hunt
    /// Wofür die Jagd verbucht wird, wenn sie gelingt.
    let credit: Find
    var found: Set<String> = []
    let endsAt: Date

    var isComplete: Bool { found.count >= hunt.count }
    var remaining: Int { max(0, Int(endsAt.timeIntervalSinceNow.rounded(.up))) }
    var isExpired: Bool { endsAt < Date() }
}
