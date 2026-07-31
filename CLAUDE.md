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
- **Alles, was das iPhone erkennt, ist auch spielbar.** Zwei Ebenen: der
  Handkatalog (`ObjectCatalog`) für ausgearbeitete Einzelgegenstände, darunter
  das Themennetz (`Themes` + `ThemeMapping`) als Auffang für den Rest. Jeder
  der 1303 Begriffe ist zugeordnet, unbekannte Begriffe künftiger iOS-Fassungen
  landen in `.stuff`. Ausgenommen sind bewusst 95 Begriffe – Menschen vor
  allem. Ein Spiel, das einen Nachhaltigkeitstipp auf einen Menschen klebt,
  ist übergriffig, egal wie gut der Tipp ist.
- **Die R-Stufe hängt an der Begegnung, nicht am Gegenstand.** Deshalb erzählt
  ein Holzboden beim ersten Antippen vom Reparieren, beim zweiten vom
  Umwidmen, beim dritten vom Verwerten – und zahlt nacheinander auf
  verschiedene Blätter ein. Jedes Thema hat 6–8 Begegnungen mit durchweg
  verschiedenen R-Stufen und ohne zwei gleiche Formate hintereinander.
- **Drinnen wie draußen spielbar.** Innenraum ist in der Begriffsliste sogar
  besser abgedeckt.
- **R-Strategien (R0–R9) sind die Mechanik**, die SDGs der Rahmen darüber.
- **Sammlung als Langzeitmotivation** – zehn Stufen, die sich füllen. Keine
  Streaks, keine Level. Eine Stufe geht auf, wenn **drei verschiedene**
  Gegenstände dieser Stufe begriffen wurden. Ein Fund je Stufe wäre nach einer
  halben Sitzung erledigt.
- **Die Sammlung ist die Blüte aus dem Gut-Einern-Logo.** Das Logo hat genau
  zehn Formen – neun bunte Blätter im Ring plus die graue Klinge – und damit
  eine je R-Stufe. Die Zuordnung ist nicht frei gewählt: Die Blätter laufen im
  Logo gegen den Uhrzeigersinn durch das Spektrum, von Violett über Grün bis
  Dunkelrot; in dieser Reihenfolge tragen sie R0 bis R8. Die graue Klinge
  fällt aus der Reihe und schließt den Ring – sie trägt R9 „Energie
  zurückholen“, die Stufe, auf der nur noch Verbrennen übrig bleibt.
  Fundpunkte in AR sind das Blatt ihrer Stufe, die Sammlung ist die Blüte,
  die sich schließt. Nicht umfärben, nicht umsortieren.
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
  App/            GEGOApp, RootView (Kameraerlaubnis, HUD, Jagdleiste, Blätter)
  AR/             ARGameView – Kamerabild, Fundpunkte setzen, Antippen
  Vision/         SceneRecognizer – Erkennung und Themenabstimmung
  Models/         RStrategy, SDG, Encounter, ObjectCatalog (Handkatalog),
                  Themes + ThemeContent+… (Themennetz), ThemeMapping
                  (erzeugt), Find (löst Begriff → Fund auf)
  Game/           GameState – Fortschritt, Sammlung, Jagd, UserDefaults
  Views/          EncounterView, CollectionView, DiagnosticsView
  DesignSystem/   Theme (kopiert aus Danach), Bloom (Blätter aus dem Logo)
Tools/            begriffe.txt + taxonomie.swift
                  GutEinern_Logo.png + kontur.swift
                  themen.swift (erzeugt ThemeMapping.swift)
```

Zwei Dateien sind erzeugt und werden nicht von Hand geändert:

```bash
swift Tools/taxonomie.swift > Tools/begriffe.txt      # nur mit Xcode/macOS
swift Tools/themen.swift    > GEGO/Models/ThemeMapping.swift
```

`themen.swift` meldet auf stderr, was ohne Thema durchfällt. Diese Liste
gehört abgearbeitet, nicht ignoriert – aktuell ist sie leer.

**Die Blattkonturen sind ausgelesen, nicht nachgezeichnet.** `Tools/kontur.swift`
zieht sie aus `Tools/GutEinern_Logo.png` und gibt sie als Punktlisten aus, die
von Hand nach `Bloom.swift` wandern. Wer die Formen ändern will, ändert das
Logo und lässt das Werkzeug neu laufen – nicht die Zahlen im Code.

**Erkennung in fünf Schritten**, weil die eingebaute Klassifikation nur sagt,
*was* im Bild ist, nicht *wo*: auffällige Bereiche finden (Saliency) →
Zuschnitt einzeln klassifizieren → **über das Thema abstimmen** → **über
mehrere Durchläufe bestätigen** → per Strahl im Raum verankern. Ausgewertet
wird zweimal pro Sekunde, nicht in jedem Bild.

Die beiden mittleren Schritte sind aus dem ersten Innenraumtest entstanden, in
dem zu viele Punkte kamen und fast alle falsch waren:

- **Abstimmung statt bester Begriff.** Die Taxonomie ist hierarchisch, und
  drinnen gewinnen fast immer die Wurzeln: `material`, `structure`,
  `interior_room`, `textile`. Sie sind nicht falsch, nur wertlos – sie passen
  auf jede Wand. Deshalb zahlen alle Vorschläge auf ihr **Thema** ein, und das
  Thema mit der höchsten Summe gewinnt – sofern es einen Mindestanteil an
  allen Stimmen hält. Benannt wird der Fund nach dem konkretesten Begriff darin;
  Oberbegriffe (`Theme.genericLabels`) dürfen mitstimmen, aber nie benennen.
  Sonst hieß gefühlt jeder zweite Fund „Gegenstand“.
  **Kein Abstandstest zum zweiten Thema.** Das war der erste Versuch und ein
  Denkfehler: Ein Holztisch ist gleichzeitig `wood` und `furniture`, beide
  sind richtig, sie teilen sich die Stimmen – und die App schwieg, obwohl sie
  den Tisch erkannt hatte. Der Anteil an der Gesamtsumme misst stattdessen,
  ob überhaupt ein Signal da ist oder nur eine flache Wolke.
- **Bestätigung über die Zeit.** Ein einzelner Durchlauf ist wacklig – dasselbe
  Regal ist einmal Möbel, einmal Papier, einmal Holz. Ein Punkt erscheint erst,
  wenn dasselbe Thema an ungefähr derselben Bildschirmstelle genug
  **Beobachtungsstärke** gesammelt hat: die Themensummen mehrerer Durchläufe
  addiert, mindestens zwei. Nicht eine feste Anzahl Durchläufe – ein
  eindeutiger Stuhl soll schneller erscheinen als eine zweifelhafte Ecke, und
  das kann eine feste Zahl nicht unterscheiden.

**Zwei Quellen für Bildbereiche**, weil sie unterschiedlich blind sind: Die
Objektsuche (`Objectness`) findet abgegrenzte Dinge auf ruhigem Grund und
versagt bei allem, was das Bild füllt oder gleichmäßig texturiert ist –
Kühlschranktür, Baumkrone, Busch. Die Aufmerksamkeitssuche (`Attention`) fragt
stattdessen, wohin ein Mensch schauen würde. Dazu kommt immer die Bildmitte
als reservierter Bereich; sie ist das verlässlichste Signal dafür, worauf
jemand überhaupt hält.

Die Bildmitte gab es schon einmal als Rückfall und sie war die ergiebigste
Unsinnsquelle – damals aber ohne jede Prüfung. Jetzt läuft sie durch dasselbe
Themenvotum und dieselbe Bestätigung über die Zeit wie jeder andere Bereich.
Eine weiße Wand liefert nur `material`, `structure`, `interior_room` – alles
Oberbegriffe – und fällt durch.

**Raumbegriffe stimmen nicht mit** (`Theme.sceneLabels`). Wer in der Küche auf
den Kühlschrank hält, bekommt `kitchen`, `kitchen_room` und `interior_room`
gratis dazu: drei Stimmen für „Gebautes" gegen eine für „Haushaltsgerät". Der
Kühlschrank verlor gegen den Raum, in dem er steht. Bewusst nur Innenräume –
`forest`, `park` und `garden` sind draußen sehr wohl das, worauf man schaut.

**Fundpunkte sind Geometrie, keine Textur.** Der erste Versuch legte ein Blatt
mit Alphakanal auf eine quadratische Fläche – am Gerät stand ein schwarzes
Rechteck drumherum, weil Transparenz in RealityKit an Material, Blending und
Texturerzeugung gleichzeitig hängt. `PetalMesh` trianguliert stattdessen die
Kontur (Ohrenschneiden). Da gibt es kein Drumherum, das sichtbar werden
könnte.

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

## Begegnungsarten

Neun Formate, damit ein Streifzug sich nicht wie eine Fragestunde anfühlt.
Gewertet („begriffen“) werden nur die, bei denen man etwas falsch machen kann.

| Art | Gewertet | Was es ist |
|---|---|---|
| `quiz` | ja | Frage mit Auflösung |
| `estimate` | ja | Schätzung am Schieberegler |
| `ordering` | ja | Rangfolge durch Antippen in Reihenfolge |
| `duel` | ja | Zwei Möglichkeiten, eine Entscheidung |
| `hunt` | ja | Auftrag an die Kamera, nach Thema **oder** R-Stufe |
| `cycle` | ja | Stationen im Ring in die richtige Reihenfolge |
| `trueFalse` | ja | Serie mit Uhr, ein Fehler beendet den Lauf |
| `sorting` | ja | Gegenstände in die richtige Abfalltonne |
| `oddOne` | ja | Vier Begriffe, einer gehört nicht dazu |
| `higherLower` | ja | Kette von Größenvergleichen |
| `timeline` | ja | Zerfallszeit auf logarithmischer Skala |
| `memory` | ja | Kartenpaare aus Blatt und Bedeutung |
| `spotErrors` | ja | Alltagsszene, welche Aussagen stimmen nicht |
| `budget` | ja | Hundert Punkte auf mehrere Maßnahmen verteilen |
| `story` | nein | Mehrere Absätze, der letzte soll sitzen |
| `fact` | nein | Ein Gedanke zum Mitnehmen |
| `mission` | nein* | Auftrag für die echte Welt |
| `video` | nein | Suchbegriff zum Weiterschauen |

\* `mission` zählt als begriffen, wenn man den Auftrag annimmt. Geprüft wird
nichts – das Spiel glaubt dir.

**Die Jagd** ist das einzige Minispiel, das AR wirklich braucht: Sie schickt
den Spieler los („Finde noch zwei Dinge aus Holz“) und wird von der Erkennung
abgenommen, nicht durch Antippen. Sie läuft als Leiste im HUD weiter, während
das Blatt schon zu ist. Der Ausgangsgegenstand zählt nicht mit.

**Zwei Vorräte.** Themeninhalte hängen am Gegenstand und stehen in
`ThemeContent+…`. Minispiele hängen an nichts und stehen in
`MiniGameCatalog` – eine Blüte kann überall auftauchen, und was darin steckt,
hat mit dem Stuhl davor nichts zu tun. Das ist Absicht: Ein Minispiel ist ein
Zwischenspiel, kein Steckbrief.

**Sichtbar unterschieden:** einzelnes Blatt für Wissen, ganze Blüte fürs
Minispiel. Die Blüte dreht sich langsam, und es gibt immer nur eine
gleichzeitig in der Szene – sonst nutzt sich das Besondere ab. Etwa jeder
vierte Fundpunkt wird eine.

**Beim Zeitstrahl** muss `maxYears` über der Antwort liegen, sonst erreicht
der Regler sie nie und das Spiel ist unlösbar. Ist einmal passiert.

## Diagnoseblatt

Langer Druck auf die Anzeige oben links öffnet ein Werkzeugblatt. Es ist kein
Teil des Spiels, sondern beantwortet die Frage, die sich am Gerät sonst nicht
beantworten lässt: Wenn kein Fundpunkt erscheint – sieht die Erkennung nichts,
sieht sie etwas unterhalb der Schwelle, oder sieht sie etwas, zu dem der
Katalog nichts sagt? Drei Ursachen, von außen ein Symptom.

Es zeigt die rohen Vorschläge der Klassifikation mit Konfidenz (Haken heißt:
steht im Katalog), stellt `minimumConfidence` am Regler ein und zeichnet die
Vision-Kästen als gelbe Rahmen ins Kamerabild. Liegen die Rahmen neben den
Gegenständen, ist die Koordinatenumrechnung schuld und nicht die Erkennung.

## Offene Punkte

Stand: baut, aber noch nie auf einem Gerät gelaufen.

1. **Erster Gerätetest steht aus.** Kommen überhaupt Punkte? Sitzen sie am
   richtigen Fleck? Das Diagnoseblatt ist dafür gebaut.
2. **Koordinatenumrechnung Vision → Bildschirm** bleibt die wahrscheinlichste
   Fehlerquelle. Stelle ist in `ARGameView.swift` kommentiert
   (`screenPoint(for:transform:viewport:)`). Verdacht: Die Vision-Kästen liegen
   im bereits nach `.right` gedrehten Raum, `displayTransform` erwartet aber
   den ungedrehten. Erst am Rahmen-Overlay ansehen, dann ändern.
3. **Annahmeschwellen geraten** – Mindestsumme je Thema 0,30 und Abstand zum
   zweiten Thema 1,6×, beide am Gerät über das Diagnoseblatt einstellbar. Die
   gefundenen Werte gehören zurück in den Code (`SceneRecognizer`). Ebenso die
   Zahl der nötigen Bestätigungen (`requiredHits`, aktuell 3) – die ist noch
   nicht am Regler, weil erst die Schwellen sitzen sollten.
4. **Alle Inhalte unbelegt.** Jeder `sourceHint` muss abgearbeitet werden –
   inzwischen sind es über hundert. Das ist die größte offene Arbeit am
   Projekt und die einzige, die nicht Claude erledigen kann.
5. **Themennamen sind grob.** Ein Fund heißt „Holz“, nicht „Dielenboden“. Für
   1303 Begriffe deutsche Namen zu pflegen lohnt nicht; wer einzelne
   Gegenstände hervorheben will, schreibt sie in den Handkatalog.
6. **Die Jagd ist ungetestet.** Ob sich in einem normalen Zimmer in 90
   Sekunden zwei weitere Gegenstände eines Themas erkennen lassen, weiß erst
   der Gerätetest. Falls nicht: `Hunt.seconds` hoch, `count` runter.
7. **Zeitdruckformate fehlen** – siehe Ideen unter „Begegnungsarten“.
