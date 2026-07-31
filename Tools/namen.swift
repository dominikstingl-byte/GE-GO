// Meldet, welche zugeordneten Begriffe noch keinen deutschen Namen haben:
//
//   swift Tools/namen.swift
//
// Ohne Namen fällt ein Fund auf den Gattungsnamen zurück – „Geschirr" statt
// „Gabel". Das ist kein Fehler, aber es fühlt sich für den Spieler an, als
// hätte die App nur ungefähr hingeschaut.
//
// Liest beide Tabellen aus dem Quelltext, damit es keine dritte Liste gibt,
// die veralten kann.

import Foundation

func begriffe(aus datei: String, muster: String) -> [String] {
    guard let text = try? String(contentsOfFile: datei, encoding: .utf8) else { return [] }
    let regex = try! NSRegularExpression(pattern: muster)
    let bereich = NSRange(text.startIndex..., in: text)
    return regex.matches(in: text, range: bereich).compactMap {
        Range($0.range(at: 1), in: text).map { String(text[$0]) }
    }
}

let zugeordnet = begriffe(aus: "GEGO/Models/ThemeMapping.swift",
                          muster: "\"([a-z_0-9]+)\": \\.")
let benannt = Set(begriffe(aus: "GEGO/Models/LabelNames.swift",
                           muster: "\"([a-z_0-9]+)\": \""))

let offen = zugeordnet.filter { !benannt.contains($0) }.sorted()
print("\(zugeordnet.count) zugeordnet, \(zugeordnet.count - offen.count) benannt, \(offen.count) offen\n")
if !offen.isEmpty {
    print(offen.joined(separator: " "))
}
