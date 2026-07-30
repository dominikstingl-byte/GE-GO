# GE-GO

Ein AR-Lernspiel zu Nachhaltigkeit. Kamera hoch, die App erkennt Gegenstände
in der Umgebung und setzt leuchtende Fundpunkte darauf. Antippen, und es
passiert etwas: eine Frage, eine Schätzung, eine kleine Geschichte, ein
Auftrag für die echte Welt, ein Video-Tipp.

Darunter liegen die zehn R-Strategien der Kreislaufwirtschaft, von *Refuse*
bis *Recover*. Sie sind Spielmechanik und Sammlung zugleich: Zehn Stufen, die
sich füllen. Die SDGs bilden den Rahmen darüber – jeder Fund zeigt, auf
welches Ziel er einzahlt.

Gedacht für Streifzüge von zwanzig bis dreißig Minuten, drinnen wie draußen,
ab etwa 16 Jahren. Alles läuft auf dem Gerät: kein Konto, kein Server, keine
Bilder verlassen das iPhone.

## Bauen und starten

```bash
brew install xcodegen   # einmalig
xcodegen generate
open GEGO.xcodeproj
```

Dann in Xcode das eigene Gerät auswählen und starten.

**Das Spiel läuft nicht im Simulator.** ARKit braucht eine echte Kamera und
echte Bewegungssensoren. Ohne iPhone gibt es nichts zu sehen.

## Wie die Erkennung funktioniert

Ohne eigenes Modell, ohne Trainingsdaten – nur mit dem, was auf jedem iPhone
schon vorhanden ist. Der Haken: Die eingebaute Klassifikation sagt, *was* im
Bild ist, nicht *wo*. Deshalb zwei Schritte:

1. **Auffälligkeit** – Vision findet Bereiche, die nach Gegenstand aussehen.
   Rahmen ohne Namen.
2. **Zuschnitt klassifizieren** – jeder Bereich wird einzeln benannt. Jetzt
   hat der Rahmen einen Begriff.
3. **Im Raum verankern** – ARKit schießt einen Strahl durch die Bildmitte und
   setzt dort einen Anker. Der Punkt klebt am Gegenstand.

Ausgewertet wird zweimal pro Sekunde, nicht in jedem Einzelbild. Alles andere
würde Akku und Gerätetemperatur ruinieren, ohne etwas zu verbessern.

## Begriffe ergänzen

Das System kennt 1303 Begriffe. Sie stehen in `Tools/begriffe.txt` und lassen
sich jederzeit neu erzeugen:

```bash
swift Tools/taxonomie.swift > Tools/begriffe.txt
```

Nur Begriffe aus dieser Liste dürfen in `ObjectCatalog.swift` stehen.
Erfundene Bezeichner werfen keinen Fehler – sie tauchen im Spiel einfach nie
auf, und das fällt niemandem auf.

## Stand der Dinge

Erste rumpelige Fassung. Was noch offen ist:

- **Alle Inhalte sind Entwürfe.** Wo im Text eine Zahl oder eine belastbare
  Aussage steht, ist im Code ein `sourceHint` gesetzt und die App zeigt in der
  Begegnung sichtbar „Noch zu prüfen“ an. Das bleibt bewusst sichtbar, bis die
  Aussagen belegt sind. Vor jedem echten Einsatz muss das abgearbeitet werden.
- **Video-Tipps sind Suchbegriffe, keine Links.** Absicht: Adressen veralten
  und lassen sich nicht prüfen, Suchbegriffe führen zuverlässiger ans Ziel.
- **Die Punkte sitzen möglicherweise versetzt.** Die Umrechnung zwischen
  Vision-Koordinaten und Bildschirm ist die wahrscheinlichste Fehlerquelle beim
  ersten Start. Die Stelle ist in `ARGameView.swift` kommentiert.
- **Die Erkennungsschwelle ist geraten.** `SceneRecognizer.minimumConfidence`
  steht auf 0,12. Zu hoch heißt: nichts wird gefunden. Zu niedrig heißt: alles
  ist alles. Das lässt sich nur am Gerät einstellen.
- **Minispiele fehlen bis auf die Schätzfrage.**

## Aufbau

```
GEGO/
  App/            Einstieg und Hauptansicht
  AR/             Kamerabild, Fundpunkte, Antippen
  Vision/         Erkennung in zwei Schritten
  Models/         R-Strategien, SDGs, Begegnungen, Gegenstandskatalog
  Game/           Fortschritt und Sammlung
  Views/          Begegnungsblatt und Sammlung
  DesignSystem/   Farben, Abstände, Bausteine
Tools/            Begriffsliste und das Werkzeug, sie zu erzeugen
```

Das Designsystem stammt aus dem Danach-Projekt und wurde kopiert, nicht
verlinkt. Die beiden Projekte haben sonst nichts miteinander zu tun.
