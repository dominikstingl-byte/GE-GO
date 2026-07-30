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

/// Erkennt Gegenstände allein mit den Modellen, die auf dem iPhone schon
/// vorhanden sind. Kein eigenes Training, keine Trainingsdaten.
///
/// Der Haken dabei: die eingebaute Klassifikation sagt, *was* im Bild ist,
/// nicht *wo*. Deshalb der Umweg in zwei Schritten – erst auffällige Bereiche
/// finden, dann jeden Bereich einzeln benennen.
final class SceneRecognizer {

    /// Unterhalb davon ist die Vermutung zu dünn, um einen Punkt zu setzen.
    /// Bewusst niedrig: die Klassifikation verteilt ihre Sicherheit auf über
    /// 1300 Begriffe, hohe Werte kommen selten vor. Beim Feintuning auf dem
    /// Gerät ist das die erste Schraube, an der zu drehen ist.
    var minimumConfidence: Float = 0.12

    /// Mehr als eine Handvoll Bereiche pro Bild lohnt sich nicht – es kostet
    /// nur Rechenzeit und der Bildschirm wird unruhig.
    private let maximumRegions = 4

    /// Zu kleine Bereiche liefern unbrauchbare Zuschnitte.
    private let minimumRegionSize: CGFloat = 0.06

    func sightings(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> [Sighting] {
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)

        guard let regions = salientRegions(in: image), !regions.isEmpty else {
            // Nichts sticht hervor: das ganze Bild als ein Bereich behandeln.
            // Der Punkt landet dann in der Bildmitte. Grob, aber besser als
            // gar keine Rückmeldung.
            if let label = classify(image) {
                return [Sighting(label: label.0, confidence: label.1,
                                 boundingBox: CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3))]
            }
            return []
        }

        var found: [Sighting] = []
        for box in regions {
            let rect = VNImageRectForNormalizedRect(box,
                                                    Int(image.extent.width),
                                                    Int(image.extent.height))
            let crop = image
                .cropped(to: rect)
                .transformed(by: CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y))
            guard !crop.extent.isEmpty else { continue }
            guard let label = classify(crop) else { continue }
            found.append(Sighting(label: label.0, confidence: label.1, boundingBox: box))
        }
        return found
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

    /// Liefert nur Begriffe, zu denen das Spiel auch etwas zu sagen hat.
    /// Alles andere ist für uns dasselbe wie „nichts erkannt“.
    private func classify(_ image: CIImage) -> (String, Float)? {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        guard let candidates = request.results else { return nil }

        let best = candidates
            .filter { ObjectCatalog.knownLabels.contains($0.identifier) }
            .filter { $0.confidence >= minimumConfidence }
            .max { $0.confidence < $1.confidence }

        guard let best else { return nil }
        return (best.identifier, best.confidence)
    }
}
