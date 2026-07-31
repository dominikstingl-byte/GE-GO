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
    /// Anteil des Gewinners an der gesamten Stimmensumme. Misst, ob überhaupt
    /// ein Signal da ist – nicht, ob der Zweite knapp dahinterliegt.
    let share: Float
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
    var minimumThemeScore: Float = 0.20

    /// Welchen Anteil an der gesamten Stimmensumme der Gewinner halten muss.
    ///
    /// Früher stand hier ein Abstand zum zweiten Thema – das war ein
    /// Denkfehler. Ein Holztisch ist gleichzeitig `wood` und `furniture`, und
    /// **beide sind richtig**. Sie teilen sich die Stimmen, keiner kommt auf
    /// den geforderten Vorsprung, und die App schweigt, obwohl sie den Tisch
    /// erkannt hat. Der Anteil an der Gesamtsumme misst dagegen das, worum es
    /// wirklich geht: ob überhaupt ein Signal da ist oder nur eine flache
    /// Wolke aus zwölf Vermutungen.
    var minimumShare: Float = 0.30

    /// Wie sicher der konkreteste Begriff mindestens sein muss, damit er den
    /// Fund benennen darf.
    var minimumLabelConfidence: Float = 0.05

    /// Wie viele Bereiche pro Bild überhaupt betrachtet werden.
    var maximumRegions = 4

    /// Zu kleine Bereiche liefern unbrauchbare Zuschnitte.
    var minimumRegionSize: CGFloat = 0.07

    /// Wie viele Vorschläge je Bereich in die Abstimmung eingehen.
    private let votingDepth = 12

    var collectsDiagnostics = false

    // MARK: Auswerten

    func analyze(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> RecognitionReport {
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)
        var report = RecognitionReport()

        let regions = candidateRegions(in: image)
        guard !regions.isEmpty else {
            report.rejections.append("Nichts hebt sich ab – näher an einen einzelnen Gegenstand")
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
            // Raumbegriffe stimmen gar nicht mit: Sie beschreiben, wo man
            // steht, nicht worauf man hält.
            guard Theme.votesForTheme(candidate.label) else { continue }
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

        let total = ranked.reduce(Float(0)) { $0 + $1.score }
        let share = total > 0 ? winner.score / total : 0
        guard share >= minimumShare else {
            return .failure(String(format: "%@ nur %.0f%% der Stimmen – zu zerstreut",
                                   winner.theme.name, share * 100), ranked)
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
                                 share: share,
                                 boundingBox: box),
                        ranked)
    }

    // MARK: Schritt 1 – wo ist überhaupt etwas?

    /// Die Mitte des Bildes, wenn sonst nichts taugt.
    ///
    /// Es gab diesen Rückfall schon einmal und er war die ergiebigste
    /// Unsinnsquelle – damals aber ohne jede Prüfung: kein Themenvotum, keine
    /// Bestätigung über die Zeit, und vor allem durften Oberbegriffe einen Fund
    /// benennen. Eine Wand wurde so zu `material` und hieß „Gegenstand".
    ///
    /// Jetzt läuft er durch dieselben Prüfungen wie jeder andere Bereich. Eine
    /// Wand liefert weiterhin nur `material`, `structure`, `interior_room` –
    /// alles Oberbegriffe – und fällt damit durch. Ein Kühlschrank oder ein
    /// Baum liefern etwas Konkretes und kommen durch.
    private let centerRegion = CGRect(x: 0.20, y: 0.20, width: 0.6, height: 0.6)

    /// Sammelt Bereiche aus zwei Quellen und wirft Doppelungen weg.
    ///
    /// Zwei Quellen, weil sie unterschiedlich blind sind: Die Objektsuche
    /// findet abgegrenzte Dinge auf ruhigem Grund, versagt aber bei allem, was
    /// das Bild füllt oder gleichmäßig texturiert ist – eine Kühlschranktür,
    /// eine Baumkrone, ein Busch. Die Aufmerksamkeitssuche fragt stattdessen,
    /// wohin ein Mensch schauen würde, und trifft genau dort.
    private func candidateRegions(in image: CIImage) -> [CGRect] {
        var found: [(box: CGRect, confidence: Float)] = []
        found.append(contentsOf: salientRegions(VNGenerateObjectnessBasedSaliencyImageRequest(), in: image))
        found.append(contentsOf: salientRegions(VNGenerateAttentionBasedSaliencyImageRequest(), in: image))

        var kept: [CGRect] = []
        for candidate in found.sorted(by: { $0.confidence > $1.confidence }) {
            guard candidate.box.width >= minimumRegionSize,
                  candidate.box.height >= minimumRegionSize else { continue }
            guard !kept.contains(where: { overlap($0, candidate.box) > 0.55 }) else { continue }
            kept.append(candidate.box)
            // Ein Platz bleibt für die Bildmitte frei – sie ist das
            // verlässlichste Signal dafür, worauf jemand überhaupt hält.
            if kept.count >= maximumRegions - 1 { break }
        }

        // Die Bildmitte kommt dazu, solange noch Platz ist. Sie kostet einen
        // Zuschnitt mehr und fängt alles ab, was zu groß ist, um aufzufallen.
        if kept.count < maximumRegions,
           !kept.contains(where: { overlap($0, centerRegion) > 0.55 }) {
            kept.append(centerRegion)
        }
        return kept
    }

    private func salientRegions(_ request: VNImageBasedRequest, in image: CIImage) -> [(CGRect, Float)] {
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return []
        }
        guard let observation = request.results?.first as? VNSaliencyImageObservation,
              let objects = observation.salientObjects else { return [] }
        return objects.map { ($0.boundingBox, $0.confidence) }
    }

    /// Anteil der Überschneidung an der kleineren der beiden Flächen.
    private func overlap(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let intersection = a.intersection(b)
        guard !intersection.isNull else { return 0 }
        let area = intersection.width * intersection.height
        let smaller = min(a.width * a.height, b.width * b.height)
        return smaller > 0 ? area / smaller : 0
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

        // Erst filtern, dann kürzen. Andersherum – und so stand es hier –
        // gingen Stimmen verloren: Stehen unter den besten zwölf Vorschlägen
        // sechs ausgeschlossene, bleiben nur sechs für die Abstimmung übrig.
        // Genau das drückt die Themensummen unter die Schwelle.
        return results
            .sorted { $0.confidence > $1.confidence }
            .filter { FindResolver.playableLabels.contains($0.identifier) }
            .prefix(votingDepth)
            .map { (label: $0.identifier, confidence: $0.confidence) }
    }
}
