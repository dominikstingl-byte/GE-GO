import Foundation
import SwiftUI
import UIKit

/// Fortschritt und laufende Runde in einem. Alles liegt auf dem Gerät, es gibt
/// kein Konto und keinen Server.
final class GameState: ObservableObject {

    // MARK: Dauerhafter Fortschritt

    /// Wie oft welcher Begriff schon gefunden wurde. Steuert, welche Begegnung
    /// als nächste dran ist.
    @Published private(set) var findings: [String: Int] = [:]

    /// Je R-Stufe: welche Gegenstände dafür begriffen wurden.
    ///
    /// Nach Stufe getrennt, weil derselbe Gegenstand nacheinander auf
    /// verschiedene Stufen einzahlen kann – ein Holzboden erzählt beim ersten
    /// Mal vom Reparieren und beim zweiten vom Umwidmen. Gezählt werden
    /// **verschiedene** Gegenstände, sonst würde dreimal dieselbe Flasche ein
    /// Blatt öffnen.
    @Published private(set) var masteredByStrategy: [Int: Set<String>] = [:]

    /// Wie viele Funde insgesamt auf eine Stufe eingezahlt haben – auch die
    /// misslungenen. Getrennt gezählt, weil eine Stufe seit dem Themennetz aus
    /// sehr vielen Gegenständen kommen kann und sich nicht mehr aus dem
    /// Katalog zurückrechnen lässt.
    @Published private(set) var findsByStrategy: [Int: Int] = [:]

    @Published private(set) var points: Int = 0

    /// Wie viele verschiedene Gegenstände eine Stufe braucht, bis ihr Blatt
    /// aufgeht. Ein einziger Fund je Stufe wäre nach einer halben Sitzung
    /// erledigt – das trägt keine Sammlung über Wochen.
    static let petalRequirement = 3

    // MARK: Laufende Runde

    /// Der Fundpunkt, den man gerade angetippt hat. Steuert das Blatt.
    @Published var activeFind: Find?

    /// Wie viele Punkte gerade in der Szene schweben.
    @Published var spotCount: Int = 0

    /// Kurze Rückmeldung am oberen Rand.
    @Published var status: String = "Halt die Kamera auf deine Umgebung"

    /// Welche Art zuletzt dran war. Damit nicht zweimal hintereinander
    /// dasselbe Format kommt.
    @Published private(set) var lastEncounterKind: String?

    /// Wird gerufen, sobald ein Fund verbucht ist. Die AR-Ansicht nimmt dann
    /// den Punkt aus der Szene – vorher nicht, sonst geht ein mit „Später“
    /// geschlossener Fund verloren.
    var onFindingRecorded: ((String) -> Void)?

    // MARK: Jagd

    /// Die laufende Jagd, falls eine angenommen wurde.
    @Published var hunt: HuntRun?

    /// Was zuletzt an Jagdmeldung anzustehen ist – geschafft oder abgelaufen.
    @Published var huntResult: String?

    func startHunt(_ hunt: Hunt, credit: Find) {
        self.hunt = HuntRun(hunt: hunt,
                            credit: credit,
                            endsAt: Date().addingTimeInterval(TimeInterval(hunt.seconds)))
        huntResult = nil
    }

    /// Wird von der Erkennung gefüttert, nicht vom Antippen. Eine Jagd soll
    /// den Blick durch den Raum belohnen, keine Tipparbeit.
    func registerSighting(_ label: String) {
        guard var run = hunt, !run.isExpired else { return }
        guard Theme.forLabel(label) == run.hunt.theme else { return }
        guard label != run.credit.label else { return }   // der Ausgangspunkt zählt nicht mit
        guard !run.found.contains(label) else { return }
        run.found.insert(label)
        hunt = run

        if run.isComplete {
            finishHunt(succeeded: true)
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    /// Prüft, ob die Zeit abgelaufen ist. Wird im Sekundentakt aus der
    /// Hauptansicht gerufen.
    func tickHunt() {
        guard let run = hunt else { return }
        if run.isExpired && !run.isComplete { finishHunt(succeeded: false) }
    }

    func finishHunt(succeeded: Bool) {
        guard let run = hunt else { return }
        hunt = nil
        if succeeded {
            record(run.credit, mastered: true)
            huntResult = run.hunt.reward
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            record(run.credit, mastered: false)
            huntResult = "Zeit vorbei – \(run.found.count) von \(run.hunt.count) gefunden."
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    // MARK: Diagnose

    /// Das Diagnoseblatt am Gerät. Im normalen Spiel aus.
    @Published var diagnosticsEnabled = false {
        didSet { if !diagnosticsEnabled { rawCandidates = []; themeScores = []; debugBoxes = [] } }
    }

    @Published var rawCandidates: [RawCandidate] = []
    @Published var themeScores: [ThemeScore] = []
    @Published var debugBoxes: [CGRect] = []
    @Published var lastRejection: String?

    /// Die beiden Schrauben, an denen im Innenraum wirklich gedreht wird.
    /// Beides Vermutungen – belastbar wird das erst am Gerät.
    @Published var minimumThemeScore: Float = 0.30
    @Published var minimumMargin: Float = 1.6

    // MARK: Sammlung

    func masteredCount(for strategy: RStrategy) -> Int {
        masteredByStrategy[strategy.rawValue]?.count ?? 0
    }

    func requirement(for strategy: RStrategy) -> Int { Self.petalRequirement }

    /// Ist das Blatt dieser Stufe offen?
    func has(_ strategy: RStrategy) -> Bool {
        masteredCount(for: strategy) >= requirement(for: strategy)
    }

    var openPetals: Int { RStrategy.allCases.filter { has($0) }.count }

    /// Zählt angebrochene Stufen anteilig mit – sonst steht der Balken lange
    /// still, obwohl etwas passiert.
    var collectionProgress: Double {
        let total = RStrategy.allCases.reduce(0.0) { sum, strategy in
            sum + min(1.0, Double(masteredCount(for: strategy)) / Double(requirement(for: strategy)))
        }
        return total / Double(RStrategy.allCases.count)
    }

    /// Wie viele Funde insgesamt auf diese Stufe eingezahlt haben.
    func findingCount(for strategy: RStrategy) -> Int {
        findsByStrategy[strategy.rawValue] ?? 0
    }

    /// Welche Stufe am dringendsten fehlt. Steht als Hinweis im HUD, damit man
    /// weiß, wonach die Augen suchen sollen.
    var mostWantedStrategy: RStrategy? {
        RStrategy.allCases
            .filter { !has($0) }
            .min { masteredCount(for: $0) > masteredCount(for: $1) }
    }

    // MARK: Verbuchen

    /// Ein Fund wurde abgeschlossen. `mastered` heißt: richtig beantwortet,
    /// Auftrag angenommen oder Jagd geschafft.
    func record(_ find: Find, mastered: Bool) {
        findings[find.label, default: 0] += 1
        findsByStrategy[find.strategy.rawValue, default: 0] += 1
        points += mastered ? find.strategy.value : find.strategy.value / 5
        if mastered {
            masteredByStrategy[find.strategy.rawValue, default: []].insert(find.label)
        }
        lastEncounterKind = find.kindLabel
        save()
        onFindingRecorded?(find.label)
    }

    // MARK: Sichern

    private enum Key {
        static let findings = "gego.findings"
        static let mastered = "gego.masteredByStrategy"
        static let points = "gego.points"
        static let finds = "gego.findsByStrategy"
    }

    init() {
        let store = UserDefaults.standard
        findings = store.dictionary(forKey: Key.findings) as? [String: Int] ?? [:]
        points = store.integer(forKey: Key.points)
        if let counts = store.dictionary(forKey: Key.finds) as? [String: Int] {
            for (key, value) in counts {
                if let stufe = Int(key) { findsByStrategy[stufe] = value }
            }
        }
        if let raw = store.dictionary(forKey: Key.mastered) as? [String: [String]] {
            for (key, labels) in raw {
                if let stufe = Int(key) { masteredByStrategy[stufe] = Set(labels) }
            }
        }
    }

    private func save() {
        let store = UserDefaults.standard
        store.set(findings, forKey: Key.findings)
        store.set(points, forKey: Key.points)
        var raw: [String: [String]] = [:]
        for (stufe, labels) in masteredByStrategy { raw[String(stufe)] = Array(labels) }
        store.set(raw, forKey: Key.mastered)
        var counts: [String: Int] = [:]
        for (stufe, value) in findsByStrategy { counts[String(stufe)] = value }
        store.set(counts, forKey: Key.finds)
    }

    /// Nur für den Entwicklungsstand: alles zurücksetzen.
    func reset() {
        findings = [:]
        masteredByStrategy = [:]
        findsByStrategy = [:]
        points = 0
        lastEncounterKind = nil
        hunt = nil
        huntResult = nil
        save()
    }
}
