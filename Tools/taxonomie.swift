// Gibt alle Begriffe aus, die die eingebaute Bilderkennung des Systems kennt.
// Läuft auf dem Mac, ohne iPhone:
//
//   swift Tools/taxonomie.swift > Tools/begriffe.txt
//
// Nur Begriffe aus dieser Liste dürfen in ObjectCatalog.swift stehen.
// Alles andere wird im Spiel nie erkannt und fällt niemandem auf.

import Vision

let revision = VNClassifyImageRequest.currentRevision
let labels = try VNClassifyImageRequest.knownClassifications(forRevision: revision)

FileHandle.standardError.write("Revision \(revision), \(labels.count) Begriffe\n".data(using: .utf8)!)
for label in labels {
    print(label.identifier)
}
