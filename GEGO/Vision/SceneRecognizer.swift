import CoreImage
import CoreVideo
import Foundation
import Vision

/// Ein erkannter Gegenstand im Kamerabild.
struct Sighting {
    let label: String
    let confidence: Float
    /// Normalisiert, in Vision-Koordinaten – Ursprung unten links.
    let boundingBox: CGRect
}

/// Ein roher Vorschlag der Klassifikation, unabhängig davon, ob das Spiel
/// etwas dazu zu sagen hat. Nur für die Diagnose am Gerät.
struct RawCandidate: Identifiable {
    let label: String
    let confidence: Float
    let known: Bool
    var id: String { label }
}

/// Was ein Durchlauf ergeben hat. Die Trennung zwischen `sightings` und `raw`
/// ist der Unterschied zwischen „das Spiel hat etwas gefunden“ und „die
/// Erkennung hat überhaupt etwas gesehen“ – beim Einstellen am Gerät ist das
/// die entscheidende Unterscheidung.
struct RecognitionReport {
    var sightings: [Sighting] = []
    var raw: [RawCandidate] = []
    var regionCount: Int = 0
    /// Wurde auf das ganze Bild zurückgefallen, weil nichts hervorstach?
    var usedWholeImage: Bool = false
}

/// Erkennt Gegenstände allein mit den Modellen, die auf dem iPhone schon
/// vorhanden sind. Kein eigenes Training, keine Trainingsdaten.
///
/// Der Haken dabei: die eingebaute Klassifikation sagt, *was* im Bild ist,
/// nicht *wo*. Deshalb der Umweg in zwei Schritten – erst auffällige Bereiche
/// finden, dann jeden Bereich einzeln benennen.
final class SceneRecognizer {

    /// Unterhalb davon ist die Vermutung zu dünn, um einen Punkt zu setzen.
    /// Bewusst niedrig: die Klassifikation verteilt ihre Sicherheit auf über
    /// 1300 Begriffe, hohe Werte kommen selten vor. Am Gerät über das
    /// Diagnoseblatt einstellbar – geraten war der Startwert, nicht das Ziel.
    var minimumConfidence: Float = 0.12

    /// Mehr als eine Handvoll Bereiche pro Bild lohnt sich nicht – es kostet
    /// nur Rechenzeit und der Bildschirm wird unruhig.
    private let maximumRegions = 4

    /// Zu kleine Bereiche liefern unbrauchbare Zuschnitte.
    private let minimumRegionSize: CGFloat = 0.06

    /// Wie viele rohe Vorschläge die Diagnose je Bereich mitschneidet.
    private let diagnosticDepth = 5

    /// Das Mitschneiden der rohen Vorschläge kostet etwas – im Spielbetrieb
    /// bleibt es aus.
    var collectsDiagnostics = false

    func analyze(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> RecognitionReport {
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)
        var report = RecognitionReport()

        guard let regions = salientRegions(in: image), !regions.isEmpty else {
            // Nichts sticht hervor: das ganze Bild als ein Bereich behandeln.
            // Der Punkt landet dann in der Bildmitte. Grob, aber besser als
            // gar keine Rückmeldung.
            report.usedWholeImage = true
            let box = CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3)
            let result = classify(image)
            report.raw = result.candidates
            if let best = result.best {
                report.sightings = [Sighting(label: best.0, confidence: best.1, boundingBox: box)]
            }
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
            let result = classify(crop)
            report.raw.append(contentsOf: result.candidates)
            guard let best = result.best else { continue }
            report.sightings.append(Sighting(label: best.0, confidence: best.1, boundingBox: box))
        }

        // Für die Diagnose reicht die beste Nennung je Begriff.
        report.raw = Dictionary(grouping: report.raw, by: \.label)
            .compactMap { $0.value.max { $0.confidence < $1.confidence } }
            .sorted { $0.confidence > $1.confidence }
            .prefix(8)
            .map { $0 }

        return report
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

    /// `best` liefert nur Begriffe, zu denen das Spiel etwas zu sagen hat – seit
    /// dem Themennetz ist das praktisch die ganze Taxonomie, ausgenommen
    /// Menschen und Ähnliches.
    /// `candidates` liefert, was die Klassifikation wirklich vorgeschlagen hat –
    /// ohne das lässt sich am Gerät nicht unterscheiden, ob die Erkennung
    /// nichts sieht oder nur nichts Katalogisiertes.
    private func classify(_ image: CIImage) -> (best: (String, Float)?, candidates: [RawCandidate]) {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return (nil, [])
        }
        guard let candidates = request.results else { return (nil, []) }

        var diagnostics: [RawCandidate] = []
        if collectsDiagnostics {
            diagnostics = candidates
                .sorted { $0.confidence > $1.confidence }
                .prefix(diagnosticDepth)
                .map { RawCandidate(label: $0.identifier,
                                    confidence: $0.confidence,
                                    known: FindResolver.playableLabels.contains($0.identifier)) }
        }

        let best = candidates
            .filter { FindResolver.playableLabels.contains($0.identifier) }
            .filter { $0.confidence >= minimumConfidence }
            .max { $0.confidence < $1.confidence }

        guard let best else { return (nil, diagnostics) }
        return ((best.identifier, best.confidence), diagnostics)
    }
}
