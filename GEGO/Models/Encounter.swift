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
        case .quiz, .estimate: return true
        case .story, .fact, .mission, .video: return false
        }
    }

    var kindLabel: String {
        switch self {
        case .quiz: return "Frage"
        case .estimate: return "Schätzung"
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
