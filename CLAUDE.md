# GE-GO

AR-Lernspiel zu Nachhaltigkeit für iPhone. Kamera hoch, die App erkennt
Gegenstände, setzt Fundpunkte darauf, dahinter steckt Wissen.

**Eigenständiges Projekt.** Hat nichts mit dem Trauerfall-Navigator („Danach",
`movingape-de/trauerfall-navigator`) zu tun. Einzige Gemeinsamkeit: das
Designsystem in `GEGO/DesignSystem/Theme.swift` wurde von dort kopiert. Nichts
davon zurückportieren, nichts von dort übernehmen.

## Die Vision

Ein unterhaltsames Spiel, kein Quiz mit Kamera. Vorbild sind Vsauce und
Veritasium: eine harmlose Frage, die kippt. Fun Facts, kleine Geschichten,
Minispiele, Tipps, Videohinweise, SDG-Bezug – abwechselnd, nie zweimal
dasselbe hintereinander. Spannend soll es sein, und es soll zum Lernen
verführen statt zu belehren.

## Entschiedene Rahmenbedingungen

Aus der Konzeptrunde, nicht neu aufrollen:

- **Punkte auf erkannten Gegenständen**, nicht an GPS-Orten. Keine Karte.
- **Nur Bordmittel zur Erkennung.** Kein eigenes Modell, keine Trainingsdaten.
  Die 1303 verfügbaren Begriffe stehen in `Tools/begriffe.txt`.
- **Drinnen wie draußen spielbar.** Innenraum ist in der Begriffsliste sogar
  besser abgedeckt.
- **R-Strategien (R0–R9) sind die Mechanik**, die SDGs der Rahmen darüber.
- **Sammlung als Langzeitmotivation** – zehn Stufen, die sich füllen. Keine
  Streaks, keine Level.
- **Einzelspieler, alles auf dem Gerät.** Kein Konto, kein Server, keine
  Bilder verlassen das iPhone.
- **Zielgruppe ab 16.** Erspart die DSGVO-Sonderregeln für Minderjährige.
- **Streifzüge von 20–30 Minuten.**
- **Inhalte:** Claude entwirft, Dominik prüft fachlich.
- **Erste Version:** Prototyp auf dem eigenen iPhone über Xcode. Kein Store.

## Arbeitsweise

Schnell und rumpelig schlägt langsam und perfekt. Lieber eine fehlerhafte
Fassung zum Anfassen als stundenlange Vorarbeit.

Code: englische Bezeichner, deutsche Kommentare und Oberflächentexte.

## Keine erfundenen Belege

Wichtigste Regel bei den Inhalten. Wo eine Zahl oder eine belastbare Aussage
im Text steht, gehört ein `sourceHint` daran – das ist ein **Merkzettel, wo zu
prüfen ist**, keine Quellenangabe. Die App zeigt ihn dem Spieler sichtbar an
(„Noch zu prüfen: …"), solange die Aussage unbelegt ist.

Aus demselben Grund sind Video-Tipps **Suchbegriffe, keine Links**: Adressen
veralten und lassen sich nicht prüfen.

Niemals eine Quelle, ein Video, eine Studie oder eine Zahl erfinden, um eine
Lücke zu füllen. Lieber die Aussage weglassen.

## Aufbau

```
GEGO/
  App/            GEGOApp, RootView (Kameraerlaubnis, HUD, Blätter)
  AR/             ARGameView – Kamerabild, Fundpunkte setzen, Antippen
  Vision/         SceneRecognizer – Erkennung in zwei Schritten
  Models/         RStrategy, SDG, Encounter, ObjectCatalog
  Game/           GameState – Fortschritt, Sammlung, UserDefaults
  Views/          EncounterView, CollectionView
  DesignSystem/   Theme (kopiert aus Danach)
Tools/            begriffe.txt + taxonomie.swift
```

**Erkennung in drei Schritten**, weil die eingebaute Klassifikation nur sagt,
*was* im Bild ist, nicht *wo*: auffällige Bereiche finden (Saliency) →
Zuschnitt einzeln klassifizieren → per Strahl im Raum verankern. Ausgewertet
wird zweimal pro Sekunde, nicht in jedem Bild.

**Neue Gegenstände** nur mit Begriffen aus `Tools/begriffe.txt`. Erfundene
Bezeichner werfen keinen Fehler – sie tauchen im Spiel einfach nie auf.

## Bauen

```bash
xcodegen generate && open GEGO.xcodeproj
```

Die `.xcodeproj` ist bewusst nicht eingecheckt, sie wird aus `project.yml`
erzeugt. **Läuft nicht im Simulator** – ARKit braucht echte Kamera und
Sensoren. Prüfen ohne Gerät:

```bash
xcodebuild -project GEGO.xcodeproj -scheme GEGO -destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO
```

## Offene Punkte

Stand: erste Fassung baut, aber noch nie auf einem Gerät gelaufen.

1. **Erster Gerätetest steht aus.** Kommen überhaupt Punkte? Sitzen sie am
   richtigen Fleck?
2. **Koordinatenumrechnung Vision → Bildschirm** ist die wahrscheinlichste
   Fehlerquelle. Stelle ist in `ARGameView.swift` kommentiert
   (`screenPoint(for:transform:viewport:)`).
3. **Erkennungsschwelle geraten** – `SceneRecognizer.minimumConfidence` = 0,12.
   Nur am Gerät einstellbar.
4. **Minispiele fehlen** bis auf die Schätzfrage am Schieberegler.
5. **Alle Inhalte unbelegt.** Jeder `sourceHint` muss abgearbeitet werden.
6. **Fundpunkte sind schlichte Kugeln.** Keine Beschriftung, keine Animation,
   kein Hinweis, was einen erwartet.
