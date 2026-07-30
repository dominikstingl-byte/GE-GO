import Foundation
import SwiftUI

/// Fortschritt und laufende Runde in einem. Alles liegt auf dem Gerät, es gibt
/// kein Konto und keinen Server.
final class GameState: ObservableObject {

    // MARK: Dauerhafter Fortschritt

    /// Wie oft welcher Gegenstand schon gefunden wurde.
    @Published private(set) var findings: [String: Int] = [:]

    /// R-Stufen, die mindestens einmal begriffen wurden. Das ist die Sammlung.
    @Published private(set) var understood: Set<Int> = []

    @Published private(set) var points: Int = 0

    // MARK: Laufende Runde

    /// Der Fundpunkt, den man gerade angetippt hat. Steuert das Blatt.
    @Published var activeEntry: CatalogEntry?

    /// Wie viele Punkte gerade in der Szene schweben.
    @Published var spotCount: Int = 0

    /// Kurze Rückmeldung am oberen Rand, etwa „Suche…“.
    @Published var status: String = "Halt die Kamera auf deine Umgebung"

    var collectionProgress: Double {
        Double(understood.count) / Double(RStrategy.allCases.count)
    }

    // MARK: Verbuchen

    /// Ein Fund wurde abgeschlossen. `mastered` heißt: Frage richtig oder
    /// Auftrag angenommen – nur dann zählt die R-Stufe als begriffen.
    func record(_ entry: CatalogEntry, mastered: Bool) {
        findings[entry.label, default: 0] += 1
        points += mastered ? entry.strategy.value : entry.strategy.value / 5
        if mastered {
            understood.insert(entry.strategy.rawValue)
        }
        save()
    }

    func has(_ strategy: RStrategy) -> Bool {
        understood.contains(strategy.rawValue)
    }

    /// Wie viele verschiedene Gegenstände zu dieser Stufe schon gefunden wurden.
    func findingCount(for strategy: RStrategy) -> Int {
        ObjectCatalog.all
            .filter { $0.strategy == strategy }
            .reduce(0) { $0 + (findings[$1.label] ?? 0) }
    }

    // MARK: Sichern

    private enum Key {
        static let findings = "gego.findings"
        static let understood = "gego.understood"
        static let points = "gego.points"
    }

    init() {
        let store = UserDefaults.standard
        findings = store.dictionary(forKey: Key.findings) as? [String: Int] ?? [:]
        understood = Set(store.array(forKey: Key.understood) as? [Int] ?? [])
        points = store.integer(forKey: Key.points)
    }

    private func save() {
        let store = UserDefaults.standard
        store.set(findings, forKey: Key.findings)
        store.set(Array(understood), forKey: Key.understood)
        store.set(points, forKey: Key.points)
    }

    /// Nur für den Entwicklungsstand: alles zurücksetzen.
    func reset() {
        findings = [:]
        understood = []
        points = 0
        save()
    }
}
