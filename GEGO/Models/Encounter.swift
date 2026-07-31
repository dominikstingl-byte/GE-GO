import Foundation

/// Was passiert, wenn man einen Fundpunkt antippt.
///
/// Bewusst viele Arten: ein Streifzug soll sich nicht wie eine Fragestunde
/// anfühlen. Die Reihenfolge je Gegenstand wechselt durch, sodass derselbe
/// Stuhl beim zweiten Mal etwas anderes erzählt.
enum Encounter {
    /// Frage mit mehreren Antworten und einer Auflösung.
    case quiz(Quiz)
    /// Schätzfrage am Schieberegler. Das kleinste Minispiel, das trotzdem
    /// eines ist – man liegt fast immer daneben, und genau das ist der Reiz.
    case estimate(Estimate)
    /// Rangfolge: Drei bis vier Dinge in die richtige Ordnung bringen. Das
    /// Format, das am meisten lehrt, weil es nicht nach einer Zahl fragt,
    /// sondern nach einem Verhältnis.
    case ordering(Ordering)
    /// Paarwahl. Zwei Möglichkeiten, eine Entscheidung, eine Wendung – schnell
    /// gespielt und trotzdem selten offensichtlich.
    case duel(Duel)
    /// Jagd: ein Auftrag an die Kamera, der im Spiel weiterläuft statt im
    /// Blatt. Das einzige Minispiel, das AR wirklich braucht.
    case hunt(Hunt)
    /// Kreislauf schließen: Stationen im Ring in die richtige Reihenfolge.
    case cycle(CycleGame)
    /// Wahr oder Falsch am Stück, mit Uhr. Bringt Tempo in ein Spiel, das
    /// sonst durchweg bedächtig ist.
    case trueFalse(TrueFalseRun)
    /// Tonne treffen: Gegenstände in die richtige Abfalltonne.
    case sorting(SortingGame)
    /// Was passt nicht dazu?
    case oddOne(OddOne)
    /// Höher oder tiefer: welche Größe ist größer?
    case higherLower(HigherLowerRun)
    /// Zeitstrahl: wie lange braucht das in der Umwelt?
    case timeline(TimelineGame)
    /// Memory mit den Blütenblättern der R-Stufen.
    case memory(MemoryGame)
    /// Fehlersuche: welche Aussagen in dieser Szene stimmen nicht?
    case spotErrors(SpotErrors)
    /// Budget verteilen: hundert Punkte auf vier Maßnahmen.
    case budget(BudgetGame)
    /// Kleine Erzählung in mehreren Absätzen. Der Vsauce-Moment: harmlose
    /// Frage, überraschende Wendung.
    case story(Story)
    /// Ein Gedanke zum Mitnehmen, ohne Gegenleistung.
    case fact(Fact)
    /// Auftrag für die echte Welt. Wird nicht geprüft – das Spiel glaubt dir.
    case mission(Mission)
    /// Hinweis auf etwas zum Weiterschauen.
    case video(VideoTip)

    /// Nur bei diesen Arten kann man etwas richtig oder falsch machen. Alles
    /// andere zählt immer als begriffen.
    var isScored: Bool {
        switch self {
        case .quiz, .estimate, .ordering, .duel, .hunt,
             .cycle, .trueFalse, .sorting, .oddOne, .higherLower,
             .timeline, .memory, .spotErrors, .budget:
            return true
        case .story, .fact, .mission, .video:
            return false
        }
    }

    var kindLabel: String {
        switch self {
        case .quiz: return "Frage"
        case .estimate: return "Schätzung"
        case .ordering: return "Reihenfolge"
        case .duel: return "Duell"
        case .hunt: return "Jagd"
        case .cycle: return "Kreislauf"
        case .trueFalse: return "Wahr oder falsch"
        case .sorting: return "Tonne treffen"
        case .oddOne: return "Ausreißer"
        case .higherLower: return "Höher oder tiefer"
        case .timeline: return "Zeitstrahl"
        case .memory: return "Memory"
        case .spotErrors: return "Fehlersuche"
        case .budget: return "Budget"
        case .story: return "Geschichte"
        case .fact: return "Gewusst"
        case .mission: return "Auftrag"
        case .video: return "Zum Weiterschauen"
        }
    }
}

// MARK: - Bausteine

struct Quiz {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    var sourceHint: String?
}

/// Schätzfrage: Der Spieler zieht einen Regler, die App zeigt, wie nah er lag.
struct Estimate {
    let question: String
    let range: ClosedRange<Double>
    let answer: Double
    let unit: String
    /// Wie weit man danebenliegen darf und trotzdem als richtig gilt,
    /// als Anteil des Wertebereichs.
    var tolerance: Double = 0.12
    let explanation: String
    var sourceHint: String?
}

/// Rangfolge: Der Spieler bringt drei bis vier Dinge in die richtige Ordnung.
///
/// Das lehrreichste der Minispiele, weil es nach einem Verhältnis fragt und
/// nicht nach einer Zahl. Wer nicht weiß, wie viel ein Kilo Rindfleisch
/// verursacht, weiß trotzdem oft, dass es mehr ist als bei Linsen – und die
/// Fälle, in denen genau diese Intuition danebenliegt, sind die interessanten.
struct Ordering {
    let question: String
    /// In der richtigen Reihenfolge notiert. Die App mischt beim Anzeigen.
    let itemsInOrder: [String]
    /// Was oben und was unten steht, etwa „am wenigsten“ → „am meisten“.
    let lowLabel: String
    let highLabel: String
    let explanation: String
    var sourceHint: String?
}

/// Paarwahl: zwei Möglichkeiten, eine Entscheidung, eine Wendung.
///
/// Bewusst ohne dritte Option – die Enge ist der Reiz. Die guten Duelle sind
/// die, bei denen die naheliegende Antwort falsch ist.
struct Duel {
    let question: String
    let optionA: String
    let optionB: String
    /// Ob A die bessere Wahl ist. Es gibt immer eine – „kommt drauf an“ wäre
    /// als Spiel wertlos, gehört aber oft in die Auflösung.
    let betterIsA: Bool
    let explanation: String
    var sourceHint: String?
}

/// Jagd: ein Auftrag an die Kamera, der im Spiel weiterläuft.
///
/// Das einzige Minispiel, das AR wirklich braucht: Es schickt den Spieler los,
/// statt ihn auf ein Blatt schauen zu lassen. Erfüllt wird es, indem die
/// Erkennung die geforderte Anzahl passender Gegenstände sieht – nicht durch
/// Antippen, sonst wäre es eine Fleißaufgabe.
struct Hunt {
    let prompt: String
    /// Woraus die gesuchten Dinge sein sollen.
    let theme: Theme?
    /// Alternativ: eine R-Stufe. Gesucht ist dann alles, zu dem das Spiel auf
    /// dieser Stufe etwas zu sagen hätte – „finde etwas, das man reparieren
    /// kann“ ist eine ganz andere Suchaufgabe als „finde etwas aus Holz“.
    var strategy: RStrategy? = nil
    /// Wie viele **verschiedene** Begriffe gefunden werden müssen.
    let count: Int
    let seconds: Int
    let reward: String
}

// MARK: - Minispiele
//
// Alle mit derselben Regel wie der Rest: Wo eine Zahl steht, hängt ein
// `sourceHint` daran. Bei Serienformaten ist das je Aussage einer – das
// vervielfacht die Prüfarbeit gegenüber einem Fun Fact, und das ist der Preis
// für das Tempo.

/// Kreislauf schließen: Stationen im Ring in die richtige Reihenfolge tippen.
struct CycleGame {
    let question: String
    /// In der richtigen Reihenfolge. Die App mischt und legt sie in den Ring.
    let stationsInOrder: [String]
    let explanation: String
    var sourceHint: String?
}

/// Eine Serie aus Aussagen mit Uhr. Ein Fehler beendet den Lauf.
struct TrueFalseRun {
    let intro: String
    let statements: [TrueFalseItem]
    /// Sekunden je Aussage.
    var seconds: Int = 8
}

struct TrueFalseItem {
    let text: String
    let isTrue: Bool
    let explanation: String
    var sourceHint: String?
}

/// Gegenstände in die richtige Tonne. Das Minispiel mit dem unmittelbarsten
/// Alltagsnutzen – wer es einmal gespielt hat, steht anders vor dem Mülleimer.
struct SortingGame {
    let question: String
    let bins: [String]
    let items: [SortingItem]
    let explanation: String
    var sourceHint: String?
}

struct SortingItem {
    let name: String
    let binIndex: Int
    /// Warum ausgerechnet dorthin – wird bei der Auflösung gezeigt.
    let note: String
}

/// Vier Begriffe, einer gehört nicht dazu.
struct OddOne {
    let question: String
    let options: [String]
    let oddIndex: Int
    let explanation: String
    var sourceHint: String?
}

/// Zwei Größen, welche ist größer. Als Kette gespielt.
struct HigherLowerRun {
    let intro: String
    let pairs: [HigherLowerPair]
}

struct HigherLowerPair {
    let question: String
    let optionA: String
    let optionB: String
    /// Ob A den größeren Wert hat.
    let aIsLarger: Bool
    let explanation: String
    var sourceHint: String?
}

/// Zeitstrahl: einen Gegenstand auf einer logarithmischen Skala einordnen.
///
/// Logarithmisch, weil die Spanne von Tagen bis Jahrhunderten reicht. Auf
/// einem linearen Regler läge alles unter fünfzig Jahren im ersten Millimeter.
struct TimelineGame {
    let question: String
    let item: String
    /// In Tagen.
    let answerDays: Double
    /// Obergrenze des Reglers in Jahren. Muss über der Antwort liegen – sonst
    /// erreicht der Regler sie nie und das Spiel ist unlösbar.
    var maxYears: Double = 500
    /// Wie weit man danebenliegen darf, als Faktor. 3 heißt: ein Drittel bis
    /// das Dreifache gilt als getroffen.
    var tolerance: Double = 3
    let explanation: String
    var sourceHint: String?
}

/// Memory mit den Blütenblättern. Marke und Mechanik fallen hier zusammen:
/// Die zehn Stufen prägen sich beim Spielen ein, ohne dass jemand sie lernt.
struct MemoryGame {
    let intro: String
    /// Welche Stufen mitspielen. Vier Paare sind ein gutes Maß.
    let strategies: [RStrategy]
    let explanation: String
}

/// Eine Alltagsszene und mehrere Aussagen dazu – manche stimmen nicht.
struct SpotErrors {
    let scene: String
    let question: String
    let statements: [ErrorStatement]
    let explanation: String
    var sourceHint: String?
}

struct ErrorStatement {
    let text: String
    /// Ob die Aussage falsch ist – die falschen sind die gesuchten.
    let isWrong: Bool
}

/// Hundert Punkte auf mehrere Maßnahmen verteilen.
///
/// Das inhaltlich stärkste Format: Es transportiert genau die Botschaft, um
/// die es geht – dass Mülltrennen und Flugverzicht nicht dasselbe Gewicht
/// haben. Und es ist das einzige, bei dem die Auflösung eine Rangfolge
/// **beziffert**, was die Prüfarbeit entsprechend erhöht.
struct BudgetGame {
    let question: String
    let options: [BudgetOption]
    let explanation: String
    var sourceHint: String?
}

struct BudgetOption {
    let name: String
    /// Wirksamkeit als Anteil, alle zusammen 1,0.
    let weight: Double
    let note: String
}

/// Mehrere kurze Absätze, die aufeinander aufbauen. Der letzte soll sitzen.
struct Story {
    let title: String
    let paragraphs: [String]
    var sourceHint: String?
}

struct Fact {
    let text: String
    var sourceHint: String?
}

struct Mission {
    let prompt: String
    let hint: String
}

/// Hinweis auf ein Video – bewusst als Suchbegriff, nicht als Link.
///
/// Links veralten, Kanäle löschen Videos, und ich kann eine Adresse nicht
/// prüfen. Ein Suchbegriff führt zuverlässiger ans Ziel und lügt nicht.
struct VideoTip {
    let searchTerm: String
    let why: String
}
