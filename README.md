# GE-GO

Ein AR-Lernspiel zu Nachhaltigkeit. Kamera hoch, die App erkennt Gegenstände
in der Umgebung und setzt leuchtende Fundpunkte darauf. Antippen, und es
passiert etwas: eine Frage, eine Schätzung, eine kleine Geschichte, ein
Auftrag für die echte Welt, ein Video-Tipp.

Darunter liegen die zehn R-Strategien der Kreislaufwirtschaft, von *Refuse*
bis *Recover*. Sie sind Spielmechanik und Sammlung zugleich: Zehn Stufen, die
sich füllen. Die SDGs bilden den Rahmen darüber – jeder Fund zeigt, auf
welches Ziel er einzahlt.

Die zehn Stufen sind die zehn Formen des Gut-Einern-Logos. Neun Blätter im
Ring tragen R0 bis R8 in der Reihenfolge, in der sie im Logo durch das
Spektrum laufen; die graue Klinge, die aus der Reihe fällt, trägt R9 – die
Stufe, auf der nur noch Verbrennen übrig bleibt. Jeder Fundpunkt in der Luft
ist das Blatt seiner Stufe. Wer alle zehn begreift, hat die Blüte
zusammengesetzt.

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

## Was passiert, wenn man tippt

Neun Formate wechseln sich ab: Frage, Schätzung am Regler, Rangfolge, Duell,
Jagd, Geschichte, Fun Fact, Auftrag für die echte Welt, Video-Suchbegriff. Die
**Jagd** verlässt als einzige das Blatt – sie schickt dich los („Finde noch
zwei Dinge aus Holz“) und wird von der Kamera abgenommen, nicht durch Antippen.

Die R-Stufe hängt an der einzelnen Begegnung, nicht am Gegenstand. Ein
Holzboden erzählt deshalb beim ersten Antippen vom Reparieren, beim zweiten
vom Umwidmen, beim dritten vom Verwerten – acht verschiedene Themen und acht
verschiedene Blätter, bevor sich etwas wiederholt.

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

**Alle 1303 sind spielbar.** Darunter liegen zwei Ebenen: der Handkatalog mit
ausgearbeiteten Einzelgegenständen und ein Themennetz, das alles andere
auffängt – Holz, Metall, Textil, Elektronik, Essen, Tiere und zwanzig weitere.
Welcher Begriff zu welchem Thema gehört, erzeugt ein Werkzeug:

```bash
swift Tools/themen.swift > GEGO/Models/ThemeMapping.swift
```

Es meldet, was ohne Thema durchfällt. Bewusst ausgenommen sind 95 Begriffe,
Menschen vor allem: Ein Fundpunkt auf einem Menschen wäre übergriffig.

Nur Begriffe aus der Liste dürfen in `ObjectCatalog.swift` stehen. Erfundene
Bezeichner werfen keinen Fehler – sie tauchen im Spiel einfach nie auf, und
das fällt niemandem auf.

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
  ersten Start. Die Stelle ist in `ARGameView.swift` kommentiert. Das
  Diagnoseblatt zeichnet die Rahmen mit, damit man den Versatz sieht statt ihn
  zu erraten.
- **Die Erkennungsschwelle ist geraten.** Startwert 0,12. Zu hoch heißt: nichts
  wird gefunden. Zu niedrig heißt: alles ist alles. Am Gerät über das
  Diagnoseblatt einstellbar – langer Druck auf die Anzeige oben links.
- **Die Jagd ist ungetestet.** Ob sich in einem normalen Zimmer in neunzig
  Sekunden zwei weitere Gegenstände desselben Themas erkennen lassen, weiß
  erst der Gerätetest.
- **Themennamen sind grob.** Ein Fund heißt „Holz“, nicht „Dielenboden“. Wer
  einzelne Gegenstände hervorheben will, schreibt sie in den Handkatalog.

## Aufbau

```
GEGO/
  App/            Einstieg, Hauptansicht, HUD, Jagdleiste
  AR/             Kamerabild, Fundpunkte, Antippen
  Vision/         Erkennung, Diagnosewerte
  Models/         R-Strategien, SDGs, Begegnungen, Handkatalog,
                  Themennetz und Zuordnungstabelle
  Game/           Fortschritt, Sammlung, laufende Jagd
  Views/          Begegnungsblatt, Sammlung, Diagnoseblatt
  DesignSystem/   Farben, Abstände, Bausteine, Blütenblätter
Tools/            Begriffsliste, Logo und die Werkzeuge, die daraus
                  Begriffe, Themen und Blattkonturen erzeugen
```

Die Blattkonturen sind **aus der Logodatei ausgelesen**, nicht nachgezeichnet.
Wer die Formen ändern will, ändert das Logo und lässt `Tools/kontur.swift`
neu laufen – nicht die Zahlen im Code.

Das Designsystem stammt aus dem Danach-Projekt und wurde kopiert, nicht
verlinkt. Die beiden Projekte haben sonst nichts miteinander zu tun.
