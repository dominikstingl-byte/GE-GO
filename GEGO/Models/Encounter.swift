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
        case .quiz, .estimate, .ordering, .duel, .hunt: return true
        case .story, .fact, .mission, .video: return false
        }
    }

    var kindLabel: String {
        switch self {
        case .quiz: return "Frage"
        case .estimate: return "Schätzung"
        case .ordering: return "Reihenfolge"
        case .duel: return "Duell"
        case .hunt: return "Jagd"
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
    let theme: Theme
    /// Wie viele **verschiedene** Begriffe dieses Themas gefunden werden müssen.
    let count: Int
    let seconds: Int
    let reward: String
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
