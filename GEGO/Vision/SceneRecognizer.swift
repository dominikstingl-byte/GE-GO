import CoreImage
import CoreVideo
import Foundation
import Vision

/// Ein erkannter Gegenstand im Kamerabild – schon auf ein Thema verdichtet.
struct Sighting {
    let theme: Theme
    /// Der konkreteste Begriff im Gewinnerthema. Nie ein Oberbegriff.
    let label: String
    /// Summe der Konfidenz aller Begriffe, die auf dieses Thema zeigen.
    let score: Float
    /// Wie klar das Thema vor dem zweitbesten liegt.
    let margin: Float
    /// Normalisiert, in Vision-Koordinaten – Ursprung unten links.
    let boundingBox: CGRect
}

/// Ein roher Vorschlag der Klassifikation. Nur für die Diagnose am Gerät.
struct RawCandidate: Identifiable {
    let label: String
    let confidence: Float
    let known: Bool
    let generic: Bool
    var id: String { label }
}

/// Wie ein Thema in einem Bereich abgeschnitten hat. Für die Diagnose.
struct ThemeScore: Identifiable {
    let theme: Theme
    let score: Float
    var id: String { theme.rawValue }
}

struct RecognitionReport {
    var sightings: [Sighting] = []
    var raw: [RawCandidate] = []
    var themeScores: [ThemeScore] = []
    var regionCount: Int = 0
    /// Warum ein Bereich nichts ergeben hat. Für die Diagnose.
    var rejections: [String] = []
}

/// Erkennt Gegenstände allein mit den Modellen, die auf dem iPhone schon
/// vorhanden sind. Kein eigenes Training, keine Trainingsdaten.
///
/// ## Warum nicht einfach der beste Begriff
///
/// Die eingebaute Klassifikation kennt 1303 Begriffe und verteilt ihre
/// Sicherheit darauf. In einem Innenraum kommt deshalb selten ein klarer
/// Sieger heraus, sondern eine flache Wolke aus Vermutungen – und ganz oben
/// stehen dabei zuverlässig die Oberbegriffe: `material`, `structure`,
/// `interior_room`, `textile`. Sie sind nicht einmal falsch. Sie sind nur
/// wertlos als Fund, weil sie auf jede Wand und jeden Boden passen.
///
/// Deshalb wird hier nicht der beste Begriff genommen, sondern **über das
/// Thema abgestimmt**: Alle Vorschläge zahlen auf ihr Thema ein, das Thema mit
/// der höchsten Summe gewinnt, und benannt wird der Fund nach dem
/// konkretesten Begriff darin. Ein Stuhl, der als Hocker durchgeht, ist immer
/// noch Möbel – und das Spiel handelt ohnehin von Themen.
final class SceneRecognizer {

    // MARK: Stellschrauben
    //
    // Alle vier sind am Gerät über das Diagnoseblatt einstellbar. Die
    // Startwerte sind Vermutungen; belastbar wird das erst im Innenraum.

    /// Wie viel Summe ein Thema mindestens auf sich vereinen muss.
    var minimumThemeScore: Float = 0.30

    /// Wie deutlich das Gewinnerthema vor dem zweiten liegen muss. Unter
    /// diesem Verhältnis ist die Szene mehrdeutig, und dann ist Schweigen
    /// besser als Raten.
    var minimumMargin: Float = 1.6

    /// Wie sicher der konkreteste Begriff mindestens sein muss, damit er den
    /// Fund benennen darf.
    var minimumLabelConfidence: Float = 0.05

    /// Wie viele Bereiche pro Bild überhaupt betrachtet werden.
    var maximumRegions = 3

    /// Zu kleine Bereiche liefern unbrauchbare Zuschnitte. Bewusst großzügig:
    /// Lieber wenige große Gegenstände als viele Fetzen.
    var minimumRegionSize: CGFloat = 0.10

    /// Wie viele Vorschläge je Bereich in die Abstimmung eingehen.
    private let votingDepth = 12

    var collectsDiagnostics = false

    // MARK: Auswerten

    func analyze(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> RecognitionReport {
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)
        var report = RecognitionReport()

        // Kein Rückfall mehr auf das ganze Bild: Eine Klassifikation der
        // gesamten Szene beschreibt den Raum, nicht einen Gegenstand, und
        // setzte den Punkt blind in die Bildmitte. Drinnen war das die
        // ergiebigste Quelle für Unsinn.
        guard let regions = salientRegions(in: image), !regions.isEmpty else {
            report.rejections.append("Nichts hebt sich ab – näher rangehen oder auf einen einzelnen Gegenstand halten")
            return report
        }

        report.regionCount = regions.count
        for box in regions {
            let rect = VNImageRectForNormalizedRect(box,
                                                    Int(image.extent.width),
                                                    Int(image.extent.height))
            let crop = image
                .cropped(to: rect)
                .transformed(by: CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y))
            guard !crop.extent.isEmpty else { continue }

            let candidates = classify(crop)
            guard !candidates.isEmpty else { continue }

            if collectsDiagnostics {
                report.raw.append(contentsOf: candidates.prefix(6).map {
                    RawCandidate(label: $0.label,
                                 confidence: $0.confidence,
                                 known: FindResolver.playableLabels.contains($0.label),
                                 generic: Theme.isGeneric($0.label))
                })
            }

            switch vote(on: candidates, box: box) {
            case .success(let sighting, let scores):
                report.sightings.append(sighting)
                if collectsDiagnostics { report.themeScores = scores }
            case .failure(let reason, let scores):
                report.rejections.append(reason)
                if collectsDiagnostics && report.themeScores.isEmpty { report.themeScores = scores }
            }
        }

        if collectsDiagnostics {
            report.raw = Dictionary(grouping: report.raw, by: \.label)
                .compactMap { $0.value.max { $0.confidence < $1.confidence } }
                .sorted { $0.confidence > $1.confidence }
                .prefix(8)
                .map { $0 }
        }

        return report
    }

    // MARK: Abstimmung über das Thema

    private enum Vote {
        case success(Sighting, [ThemeScore])
        case failure(String, [ThemeScore])
    }

    private func vote(on candidates: [(label: String, confidence: Float)], box: CGRect) -> Vote {
        var scores: [Theme: Float] = [:]
        for candidate in candidates {
            guard let theme = Theme.forLabel(candidate.label) else { continue }
            scores[theme, default: 0] += candidate.confidence
        }

        let ranked = scores
            .map { ThemeScore(theme: $0.key, score: $0.value) }
            .sorted { $0.score > $1.score }

        guard let winner = ranked.first else {
            return .failure("Kein Thema erkennbar", ranked)
        }
        guard winner.score >= minimumThemeScore else {
            return .failure(String(format: "%@ zu schwach (%.2f < %.2f)",
                                   winner.theme.name, winner.score, minimumThemeScore), ranked)
        }

        let runnerUp = ranked.dropFirst().first?.score ?? 0
        let margin = runnerUp > 0 ? winner.score / runnerUp : .greatestFiniteMagnitude
        guard margin >= minimumMargin else {
            return .failure(String(format: "%@ vs. %@ zu knapp (%.1f×)",
                                   winner.theme.name,
                                   ranked.dropFirst().first?.theme.name ?? "?",
                                   margin), ranked)
        }

        // Benannt wird nach dem konkretesten Begriff. Oberbegriffe dürfen für
        // ein Thema stimmen, aber nie den Fund benennen – sonst heißt jeder
        // zweite Fund „Gegenstand“ oder „Material“.
        let named = candidates
            .filter { Theme.forLabel($0.label) == winner.theme }
            .filter { !Theme.isGeneric($0.label) }
            .filter { $0.confidence >= minimumLabelConfidence }
            .max { $0.confidence < $1.confidence }

        guard let named else {
            return .failure("\(winner.theme.name): nur Oberbegriffe, nichts Konkretes", ranked)
        }

        return .success(Sighting(theme: winner.theme,
                                 label: named.label,
                                 score: winner.score,
                                 margin: margin,
                                 boundingBox: box),
                        ranked)
    }

    // MARK: Schritt 1 – wo ist überhaupt etwas?

    private func salientRegions(in image: CIImage) -> [CGRect]? {
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        guard let observation = request.results?.first as? VNSaliencyImageObservation,
              let objects = observation.salientObjects else { return nil }

        return objects
            .sorted { $0.confidence > $1.confidence }
            .map(\.boundingBox)
            .filter { $0.width >= minimumRegionSize && $0.height >= minimumRegionSize }
            .prefix(maximumRegions)
            .map { $0 }
    }

    // MARK: Schritt 2 – was ist es?

    private func classify(_ image: CIImage) -> [(label: String, confidence: Float)] {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return []
        }
        guard let results = request.results else { return [] }

        return results
            .sorted { $0.confidence > $1.confidence }
            .prefix(votingDepth)
            .filter { FindResolver.playableLabels.contains($0.identifier) }
            .map { (label: $0.identifier, confidence: $0.confidence) }
    }
}
