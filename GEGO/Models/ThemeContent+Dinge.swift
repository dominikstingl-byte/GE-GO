import Foundation

// Inhalte für die Themen, die man drinnen in die Hand nimmt.
//
// **Alle Texte sind Entwürfe.** Wo eine Zahl oder eine belastbare Aussage
// steht, hängt ein `sourceHint` daran – ein Merkzettel, wo nachzuschlagen ist,
// keine Quellenangabe. Die App zeigt ihn dem Spieler sichtbar als „Noch zu
// prüfen“ an, solange das nicht abgearbeitet ist.
//
// Jedes Thema hat mindestens sechs Begegnungen in wechselnden Formaten und mit
// wechselnden R-Stufen. Wer auf einem Holzboden steht und dreimal tippt, soll
// dreimal etwas anderes bekommen – und dabei auf drei verschiedene Blätter
// einzahlen.

extension Theme {

    // MARK: - Holz

    static let woodEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction, .lifeOnLand], encounter:
            .story(Story(
                title: "Der Baum, der zweimal stirbt",
                paragraphs: [
                    "Ein Baum zieht sein halbes Leben lang Kohlenstoff aus der Luft und baut sich daraus selbst. Was du hier vor dir hast, ist eingelagerte Atmosphäre.",
                    "Wird das Holz verbrannt, geht der Kohlenstoff genau dorthin zurück, wo er herkam. Verrottet es, dasselbe, nur langsamer.",
                    "Interessant wird es dazwischen: Solange das Holz Holz bleibt – als Balken, als Tisch, als Diele – bleibt der Kohlenstoff drin. Ein Dachstuhl hält ihn ein Jahrhundert fest.",
                    "Deshalb ist die entscheidende Frage bei Holz nicht, ob es nachwächst. Sondern wie lange es Ding bleibt, bevor es wieder Luft wird."
                ],
                sourceHint: "Kohlenstoffspeicherung in Holzprodukten, Thünen-Institut"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Such dir die schlimmste Macke an einer Holzfläche in deiner Nähe und finde heraus, womit man sie wegbekäme.",
                hint: "Bei geöltem Holz reicht oft Schleifpapier und Öl. Bei lackiertem wird es aufwendiger – auch das ist eine Erkenntnis."
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Altholz wird in Kategorien sortiert. Wovon hängt ab, in welche es kommt?",
                options: [
                    "Von der Holzart",
                    "Davon, wie stark es behandelt oder belastet ist",
                    "Vom Alter des Holzes"
                ],
                correctIndex: 1,
                explanation: "Unbehandeltes Holz kann zu Spanplatten werden. Lackiertes, verleimtes oder mit Holzschutzmitteln behandeltes darf das nicht mehr – für das bleibt am Ende nur die Verbrennung. Was mit einem Anstrich anfängt, endet als Wärme.",
                sourceHint: "Altholzverordnung, Kategorien A I bis A IV"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.climateAction], encounter:
            .ordering(Ordering(
                question: "Wie lange bleibt der Kohlenstoff im Holz gebunden?",
                itemsInOrder: ["Papiertaschentuch", "Verpackungskarton", "Bücherregal", "Dachstuhl"],
                lowLabel: "Tage",
                highLabel: "Jahrzehnte",
                explanation: "Dieselbe Menge Holz, vier sehr verschiedene Lebensläufe. Der Dachstuhl ist die beste Nutzung, die Holz haben kann: lange stehen, dann noch etwas anderes werden. Das Taschentuch ist die schlechteste – ein Baum, der für zehn Sekunden gewachsen ist.",
                sourceHint: "Lebensdauer von Holzprodukten, Kaskadennutzung"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.lifeOnLand, .climateAction], encounter:
            .duel(Duel(
                question: "Grillsaison. Was ist die bessere Kohle?",
                optionA: "Holzkohle ohne Herkunftsangabe aus dem Baumarkt",
                optionB: "Briketts aus Sägeresten der heimischen Holzindustrie",
                betterIsA: false,
                explanation: "Holzkohle ohne Angabe stammt oft aus Tropenholz – auch wenn „Buche“ draufsteht, wurde in Stichproben regelmäßig anderes gefunden. Reste aus der Sägerei sind Material, das ohnehin anfällt. Das eigentlich Kluge steht aber auf keiner Packung: seltener grillen ändert mehr als die Wahl der Kohle.",
                sourceHint: "Untersuchungen zu Tropenholz in Grillkohle, z. B. Thünen-Institut / WWF"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Eine Europalette ist so gebaut, dass sie hunderte Fahrten übersteht. Wer sie zum Regal umbaut, nimmt ihr genau das – sie wäre im Kreislauf besser aufgehoben als im Wohnzimmer. Umwidmen ist gut, wenn nichts Besseres mehr geht, nicht wenn es das Bessere verhindert."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy, .climateAction], encounter:
            .video(VideoTip(
                searchTerm: "Kaskadennutzung Holz erst stofflich dann energetisch",
                why: "Holz zu verbrennen ist nicht falsch – es ist nur die letzte Stufe. Der Begriff für die Reihenfolge davor lautet Kaskadennutzung, und wer ihn einmal verstanden hat, sieht jeden Holzhaufen anders an."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption, .lifeOnLand], encounter:
            .hunt(Hunt(
                prompt: "Finde noch zwei andere Dinge aus Holz in deiner Nähe.",
                theme: .wood,
                count: 2,
                seconds: 90,
                reward: "Holz ist überall, sobald man darauf achtet – und jedes Stück ist gebundene Luft."
            )))
    ]

    // MARK: - Metall

    static let metalEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption, .industryInnovation], encounter:
            .fact(Fact(
                text: "Metall ist der Sonderfall im Kreislauf: Beim Einschmelzen verliert es seine Gestalt, aber nicht seine Eigenschaften. Ein Eisenatom ist nach dem zehnten Leben so gut wie nach dem ersten. Papier kann das nicht, Kunststoff auch nicht."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.affordableEnergy, .climateAction], encounter:
            .estimate(Estimate(
                question: "Wie viel Energie spart Aluminium aus Altmetall gegenüber Aluminium aus Erz?",
                range: 0...100,
                answer: 95,
                unit: "%",
                explanation: "Aluminium aus Bauxit zu gewinnen ist einer der stromhungrigsten Vorgänge der Industrie überhaupt. Einschmelzen ist dagegen fast geschenkt. Deshalb ist eine weggeworfene Alufolie kein bisschen Müll, sondern weggeworfener Strom.",
                sourceHint: "Energiebedarf Primär- vs. Sekundäraluminium, Umweltbundesamt"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .decentWork], encounter:
            .mission(Mission(
                prompt: "Finde in deiner Nähe etwas aus Metall, das klemmt, quietscht oder wackelt – und finde heraus, ob eine Schraube reicht.",
                hint: "Quietschende Scharniere, lockere Griffe, wackelige Stuhlbeine. Metall geht selten kaputt, es geht meistens nur auseinander."
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Reste abdecken – was ist die bessere Wahl?",
                optionA: "Alufolie über die Schüssel",
                optionB: "Ein Teller obendrauf",
                betterIsA: false,
                explanation: "Der Teller ist schon da, überlebt tausend Einsätze und muss nur abgespült werden. Alufolie ist Strom in Blattform, meist für einen einzigen Abend. Die unbequeme Wahrheit dahinter: Die beste Verpackung ist fast immer die, die schon im Schrank steht.",
                sourceHint: "Ökobilanz Haushaltsfolien vs. Mehrweg"
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.industryInnovation, .decentWork], encounter:
            .story(Story(
                title: "Das Getriebe, das schon einmal gefahren ist",
                paragraphs: [
                    "Wenn in einem Auto das Getriebe stirbt, ist selten alles kaputt. Meistens sind es ein paar Teile, die zerlegen, prüfen und ersetzen könnte, wer weiß wie.",
                    "Genau das gibt es als Industrie: Austauschteile werden zerlegt, vermessen, verschlissene Stücke getauscht, der Rest wieder zusammengebaut.",
                    "Das Ergebnis bekommt volle Garantie – wie neu, nur ohne die halbe Tonne Erz.",
                    "Der Fachbegriff dafür ist Remanufacturing, im Spiel R6. Es ist die stillste der zehn Stufen: Man merkt sie nur, wenn man auf die Rechnung schaut."
                ],
                sourceHint: "Remanufacturing in der Automobilzulieferindustrie, Marktzahlen"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Warum ist Schrott sortenrein zu sammeln so wichtig?",
                options: [
                    "Weil sonst der Preis sinkt",
                    "Weil vermischte Metalle sich kaum wieder trennen lassen",
                    "Weil die Sortieranlagen sonst überlasten"
                ],
                correctIndex: 1,
                explanation: "Einschmelzen kann Formen trennen, aber keine Legierungen. Ist Kupfer erst einmal im Stahl, bleibt es drin und macht ihn spröder. Metallkreisläufe sterben nicht am Verschleiß, sie sterben an Vermischung.",
                sourceHint: "Kupferkontamination in Stahlschrott, Downcycling"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Drei verschiedene Dinge aus Metall, die keine Küche brauchen.",
                theme: .metal,
                count: 3,
                seconds: 120,
                reward: "Metall ist der unauffälligste Werkstoff – bis man anfängt, ihn zu zählen."
            )))
    ]

    // MARK: - Glas

    static let glassEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Blaues Glas – in welchen Container?",
                options: ["Weißglas", "Grünglas", "Braunglas"],
                correctIndex: 1,
                explanation: "Grünglas verträgt Fremdfarben am besten, deshalb kommt alles Bunte dorthin. Weißglas ist der empfindliche Fall: Eine einzige grüne Flasche verdirbt die Charge für neues Weißglas. Beim Glas ist Sortieren keine Ordnungsliebe, sondern Voraussetzung.",
                sourceHint: "Sortiervorgaben Altglas, Farbreinheit Weißglas"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption, .climateAction], encounter:
            .duel(Duel(
                question: "Dieselbe Limonade. Was ist besser?",
                optionA: "Mehrwegflasche aus Glas vom Abfüller 400 km entfernt",
                optionB: "Einwegflasche aus Kunststoff vom Abfüller um die Ecke",
                betterIsA: false,
                explanation: "Überraschend, aber die Entfernung kippt es. Glas ist schwer, und Mehrweg heißt: leer wieder zurückfahren. Der Vorsprung von Mehrweg ist echt, aber er hat einen Radius – jenseits davon fährt ihn der Lkw wieder ein. Regional abgefüllt schlägt Mehrweg von weit her.",
                sourceHint: "Umweltbundesamt, Ökobilanzen Getränkeverpackungen, Transportentfernung"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.affordableEnergy], encounter:
            .fact(Fact(
                text: "Eine Glasschmelze läuft rund um die Uhr, jahrelang, ohne je abzukühlen. Sie abzuschalten wäre teurer als sie durchlaufen zu lassen. Altglas hilft doppelt: Es ersetzt Sand und senkt die nötige Temperatur.",
                sourceHint: "Energieeinsparung durch Scherbeneinsatz in Glaswannen"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Finde ein Glas mit Deckel, das gerade leer wird, und gib ihm eine zweite Aufgabe, bevor es in den Container wandert.",
                hint: "Schraubgläser sind luftdicht, spülmaschinenfest und kosten nichts. Der einzige Nachteil: Man hat schnell zu viele."
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Wie oft wird das Material im Schnitt wieder zu demselben Produkt?",
                itemsInOrder: ["Papier", "Kunststoff", "Glas", "Aluminium"],
                lowLabel: "selten",
                highLabel: "praktisch endlos",
                explanation: "Papierfasern werden bei jedem Durchgang kürzer, Kunststoff verliert Eigenschaften, Glas und Metall können im Prinzip beliebig oft. Das ist der Unterschied zwischen Kreislauf und Rutschbahn – und der Grund, warum „ist ja recycelbar“ eine Aussage über den Werkstoff ist, nicht über die Verpackung.",
                sourceHint: "Recyclingfähigkeit nach Werkstoff, Faserverkürzung Papier"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .story(Story(
                title: "Warum Fensterglas nicht in den Container darf",
                paragraphs: [
                    "Altglas ist eine der besten Erfolgsgeschichten der Abfallwirtschaft. Und trotzdem gibt es Glas, das alles verdirbt.",
                    "Fensterglas, Trinkgläser, Spiegel, Glaskeramik: Die schmelzen bei anderen Temperaturen als Verpackungsglas.",
                    "Ein einziges Stück davon in der Wanne erzeugt Einschlüsse, die eine ganze Charge unbrauchbar machen – Flaschen, die später einfach zerspringen.",
                    "Der Container heißt deshalb nicht ohne Grund Altglascontainer und nicht Glascontainer. Ein Buchstabe, der über eine Tonne Material entscheidet."
                ],
                sourceHint: "Störstoffe im Altglas, Glaskeramik und Fensterglas"
            )))
    ]

    // MARK: - Papier

    static let paperEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.lifeOnLand, .cleanWater], encounter:
            .quiz(Quiz(
                question: "Recyclingpapier gegenüber Frischfaserpapier – was stimmt?",
                options: [
                    "Es spart vor allem Bäume",
                    "Es spart vor allem Wasser und Energie",
                    "Es spart bei beidem deutlich"
                ],
                correctIndex: 2,
                explanation: "Beides, und der Wasserposten überrascht die meisten: Zellstoff aus Holz zu kochen ist ein nasser, energiehungriger Vorgang. Der Blaue Engel für Recyclingpapier ist eines der wenigen Siegel, hinter dem eine klar messbare Ersparnis steht.",
                sourceHint: "Umweltbundesamt, Vergleich Frischfaser- und Recyclingpapier"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Kassenbon – was ist besser?",
                optionA: "Ausgedruckt und ins Altpapier",
                optionB: "Ausgedruckt und in den Restmüll",
                betterIsA: false,
                explanation: "Eine Fangfrage mit ernstem Kern: Thermopapier gehört nicht ins Altpapier, weil die Beschichtung den Kreislauf belastet. Beide Antworten sind aber nur die zweitbeste – die beste ist, ihn gar nicht erst zu nehmen, wo das geht.",
                sourceHint: "Thermopapier und Bisphenole, Entsorgungshinweise"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Eine Papierfaser hält etwa fünf bis sieben Durchgänge durch, dann ist sie zu kurz zum Verfilzen. Jeder Kreislauf braucht deshalb Nachschub – Papier ist kein geschlossener Kreis, sondern eine sehr lange Spirale.",
                sourceHint: "Faserverkürzung und maximale Recyclingdurchgänge Papier"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.lifeOnLand], encounter:
            .story(Story(
                title: "Die Tüte, die gut aussieht",
                paragraphs: [
                    "Papiertüte statt Plastiktüte fühlt sich richtig an. Papier ist aus Holz, Holz wächst nach, fertig.",
                    "Nur braucht die Herstellung einer Papiertüte mehr Energie und deutlich mehr Wasser als die einer Plastiktüte – und sie hält weniger aus.",
                    "Damit sie ihren Rückstand aufholt, muss sie mehrfach benutzt werden. Genau das tut fast niemand, weil sie beim ersten Regen aufgibt.",
                    "Die Papiertüte ist damit ein Lehrstück: Der Werkstoff sagt fast nichts. Wie oft ein Ding benutzt wird, sagt fast alles."
                ],
                sourceHint: "Umweltbundesamt, Tragetaschen im Vergleich"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Was stört das Altpapier am meisten?",
                itemsInOrder: ["Zeitung", "Karton mit Klebeband", "Pizzakarton mit Fett", "Kassenbon"],
                lowLabel: "harmlos",
                highLabel: "richtig störend",
                explanation: "Klebeband wird aussortiert, Fett lässt sich nicht auswaschen und macht die Fasern unbrauchbar, Thermopapier bringt Chemie in den Kreislauf. Altpapier ist der Rohstoff, den am meisten Menschen selbst mitsortieren – und deshalb der, der am leichtesten verdorben wird.",
                sourceHint: "Störstoffe im Altpapier, Anforderungen der Papierindustrie"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Nimm dir vor, den nächsten Karton, der bei dir ankommt, nicht sofort flachzutreten – sondern ihn einmal weiterzugeben oder wiederzuverwenden.",
                hint: "Umzugskisten, Versandkartons, Aufbewahrung. Ein Karton, der zweimal fährt, ist die billigste Kreislaufwirtschaft, die es gibt."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy], encounter:
            .video(VideoTip(
                searchTerm: "Altpapier Sortierung Deinking Anlage Ablauf",
                why: "Wie aus bedrucktem Papier wieder weißes wird, ist ein erstaunlich handfester Vorgang mit Seife und Luftblasen. Danach wirft man ein Blatt Papier anders weg."
            )))
    ]

    // MARK: - Textil

    static let textileEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption, .cleanWater], encounter:
            .story(Story(
                title: "Das Kleidungsstück, das nie getragen wurde",
                paragraphs: [
                    "Der größte Umweltposten eines T-Shirts entsteht, bevor es jemand anzieht: Anbau, Spinnen, Färben, Transport.",
                    "Das heißt: Der Schaden ist schon angerichtet, wenn es im Laden hängt. Was danach passiert, entscheidet nur noch, worauf sich der Schaden verteilt.",
                    "Ein Shirt, das dreihundertmal getragen wird, verteilt ihn auf dreihundert Tage. Eines, das zehnmal getragen wird, auf zehn.",
                    "Deshalb ist die wirksamste Textilentscheidung keine im Laden. Sie ist die, den Schrank zu öffnen und festzustellen, dass da schon etwas hängt."
                ],
                sourceHint: "Ökobilanz Baumwoll-T-Shirt, Anteil Herstellung vs. Nutzung"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .decentWork], encounter:
            .mission(Mission(
                prompt: "Such das eine Kleidungsstück, das du wegen einer Kleinigkeit nicht mehr anziehst – Knopf, Naht, Reißverschluss – und entscheide heute, ob du es reparierst oder weggibst.",
                hint: "Beides ist besser als der Zustand davor: ungetragen im Schrank hängen."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.lifeBelowWater, .cleanWater], encounter:
            .quiz(Quiz(
                question: "Wobei löst sich am meisten Mikroplastik aus Kleidung?",
                options: ["Beim Tragen", "Beim Waschen", "Beim Trocknen im Trockner"],
                correctIndex: 1,
                explanation: "Die Waschmaschine ist die Hauptquelle – jede Wäsche reibt Fasern aus dem Gewebe, die durch die Kläranlage ins Wasser gelangen. Voll beladen, kühl und seltener waschen hilft mehr als jedes Waschmittel.",
                sourceHint: "Mikrofaserfreisetzung beim Waschen von Synthetiktextilien"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Aussortierte Jeans – was hilft mehr?",
                optionA: "In den Altkleidercontainer",
                optionB: "Direkt an jemanden weitergeben, der sie trägt",
                betterIsA: false,
                explanation: "Der Container ist nicht schlecht, aber unterwegs geht viel verloren: sortieren, transportieren, exportieren, und ein Teil wird am Ende doch verbrannt. Weitergeben überspringt die ganze Kette. Direktheit schlägt System, wenn das System lang ist.",
                sourceHint: "Verwertungswege von Altkleidern in Deutschland, Anteile"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.industryInnovation], encounter:
            .fact(Fact(
                text: "Reine Baumwolle lässt sich recyceln, reines Polyester auch. Die Mischung aus beidem ist bis heute das Problem – und die meisten Kleidungsstücke sind genau das. Der Etikettenblick verrät, ob ein Teil je einen zweiten Kreis bekommt.",
                sourceHint: "Stand der Faser-zu-Faser-Recyclingverfahren für Mischgewebe"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption, .decentWork], encounter:
            .ordering(Ordering(
                question: "Wie lange bleibt ein Kleidungsstück im Schnitt in Gebrauch?",
                itemsInOrder: ["Fast-Fashion-Shirt", "Markenjeans", "Wollmantel", "Geerbtes Kleidungsstück"],
                lowLabel: "kurz",
                highLabel: "lang",
                explanation: "Die Reihenfolge ist wenig überraschend, die Konsequenz schon: Der Preis pro Tragen fällt mit der Tragedauer, ökologisch wie finanziell. Teuer und lange getragen schlägt billig und schnell weg – auch im Geldbeutel.",
                sourceHint: "Durchschnittliche Nutzungsdauer von Kleidung, Trageanzahl"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei Textilien, die keine Kleidung sind.",
                theme: .textile,
                count: 2,
                seconds: 90,
                reward: "Vorhänge, Kissen, Taschen, Teppiche – Textil ist viel mehr als der Schrank."
            )))
    ]

    // MARK: - Kunststoff

    static let plasticEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption, .lifeBelowWater], encounter:
            .duel(Duel(
                question: "Unterwegs Durst. Was ist ökologisch am günstigsten?",
                optionA: "Mehrwegflasche aus dem Kiosk",
                optionB: "Leitungswasser in der Flasche, die du dabei hast",
                betterIsA: false,
                explanation: "Kein Transport, keine Verpackung, keine Reinigung im Werk. Die beste Flasche ist die, die du schon hast – und Leitungswasser ist in Deutschland das am besten überwachte Lebensmittel überhaupt.",
                sourceHint: "Umweltbundesamt, Vergleich Getränkeverpackungen; Trinkwasserverordnung"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .story(Story(
                title: "Der Werkstoff, der zu gut war",
                paragraphs: [
                    "Kunststoff wurde erfunden, um Dinge haltbar zu machen: leicht, formbar, wasserfest, praktisch unzerstörbar.",
                    "Genau diese Unzerstörbarkeit war der Verkaufsgrund. Ein Material, das nicht rostet, nicht fault, nicht bricht.",
                    "Dann haben wir angefangen, ihn für Dinge zu benutzen, die zwanzig Minuten halten sollen.",
                    "Das ist der ganze Konflikt in einem Satz: Ein Werkstoff, der für Jahrhunderte gebaut ist, in einer Anwendung, die einen Nachmittag dauert. Nicht der Kunststoff ist das Problem, sondern wofür wir ihn nehmen."
                ]
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Was passiert mit dem Kunststoff aus der Gelben Tonne überwiegend?",
                options: [
                    "Er wird zu neuem Kunststoff derselben Qualität",
                    "Er wird zu minderwertigerem Kunststoff oder verbrannt",
                    "Er wird zum größten Teil exportiert"
                ],
                correctIndex: 1,
                explanation: "Sortenreine Verpackungen wie PET-Flaschen laufen gut. Der Rest ist Gemisch, und Gemisch wird bestenfalls Blumenkasten, oft aber Wärme. Das Wort „recycelbar“ auf einer Packung sagt, was möglich wäre – nicht, was passiert.",
                sourceHint: "Verwertungsquoten Leichtverpackungen, werkstofflich vs. energetisch"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.lifeBelowWater], encounter:
            .ordering(Ordering(
                question: "Wie lange braucht das in der Umwelt, bis es zerfallen ist?",
                itemsInOrder: ["Papiertaschentuch", "Zigarettenfilter", "Plastiktüte", "Kunststoffflasche"],
                lowLabel: "Wochen",
                highLabel: "Jahrhunderte",
                explanation: "Der Zigarettenfilter steht hier zu Recht so weit vorn: Er besteht aus Celluloseacetat, also Kunststoff, und ist der weltweit am häufigsten gefundene Abfall an Stränden. Der unscheinbarste Gegenstand der Liste ist der häufigste.",
                sourceHint: "Zerfallszeiten in der Umwelt; Strandmüll-Erhebungen, häufigste Fundstücke"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Zähl heute mit, wie oft dir Einwegkunststoff angeboten wird – Becher, Tüte, Besteck, Strohhalm – und wie oft du ihn wirklich brauchst.",
                hint: "Nicht ablehnen, nur zählen. Die Zahl allein verändert die nächste Woche mehr als jeder Vorsatz."
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "„Biologisch abbaubar“ heißt in aller Regel: unter Industriebedingungen, bei 60 Grad, in einer Anlage, die es in Deutschland für Verpackungen kaum gibt. Im Gartenkompost oder am Wegrand passiert dasselbe wie bei normalem Kunststoff – nämlich nichts.",
                sourceHint: "Norm EN 13432, industrielle Kompostierbarkeit vs. Heimkompost"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy, .climateAction], encounter:
            .video(VideoTip(
                searchTerm: "Was passiert wirklich mit dem Gelben Sack Sortieranlage",
                why: "Die Anlagen sind beeindruckender als erwartet und trotzdem ernüchternd. Beides zu sehen, ist ehrlicher als jede Zahl."
            )))
    ]

    // MARK: - Werkzeug

    static let toolEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .decentWork], encounter:
            .fact(Fact(
                text: "Werkzeug ist die einzige Gegenstandsgruppe, deren Zweck es ist, andere Gegenstände am Leben zu halten. Ein Schraubendreher im Haushalt verlängert im Lauf der Jahre die Lebensdauer von Dutzenden Dingen – er ist der Hebel unter allen zehn R-Stufen."
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption, .sustainableCities], encounter:
            .story(Story(
                title: "Die Bohrmaschine, die dreizehn Minuten arbeitet",
                paragraphs: [
                    "Eine Bohrmaschine im Privathaushalt läuft über ihr ganzes Leben nur wenige Minuten – die Zahl wird gern mit dreizehn angegeben.",
                    "Ob die Zahl genau stimmt, ist fast egal. Jeder weiß, dass sie klein ist.",
                    "Für diese Minuten steht in Millionen Haushalten je ein Gerät im Schrank: Motor, Kupfer, Elektronik, Kunststoff, Verpackung, Transport.",
                    "Genau hier setzt R1 an. Nicht besser bohren, nicht weniger bohren – sondern die Frage stellen, ob jeder eine eigene Maschine besitzen muss. Leihen, teilen, Werkzeugbibliothek. Der Zweck bleibt, das Ding verschwindet."
                ],
                sourceHint: "Herkunft und Belastbarkeit der Angabe „13 Minuten Nutzungsdauer Bohrmaschine“"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.sustainableCities], encounter:
            .mission(Mission(
                prompt: "Finde heraus, ob es in deiner Nähe ein Repair-Café, eine Werkzeugausleihe oder eine Leihbörse gibt.",
                hint: "Viele Städte haben eine, und fast niemand weiß davon. Suchen kostet fünf Minuten, wissen hält Jahre."
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Eine stumpfe Säge, ein stumpfes Messer, eine stumpfe Schere. Was ist meist die richtige Reaktion?",
                options: [
                    "Ersetzen, Schärfen lohnt sich selten",
                    "Schärfen, das stellt fast den Neuzustand her",
                    "Weiterbenutzen, das ist reine Gewöhnungssache"
                ],
                correctIndex: 1,
                explanation: "Schneiden ist Geometrie, und Geometrie lässt sich wiederherstellen. Ein geschärftes Messer ist funktional neu. Nebenbei: Ein stumpfes Messer ist gefährlicher als ein scharfes, weil es abrutscht.",
                sourceHint: "Standzeit und Nachschärfbarkeit von Schneidwerkzeugen"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Du brauchst ein Werkzeug für genau einen Nachmittag.",
                optionA: "Das billigste kaufen",
                optionB: "Das gute leihen",
                betterIsA: false,
                explanation: "Das billigste Werkzeug ist meist das, das genau einen Nachmittag hält – und danach ein Schrankproblem ist. Leihen löst die Aufgabe besser und hinterlässt nichts. Wenn Leihen nicht geht, ist gutes Werkzeug die zweitbeste Wahl, nicht billiges.",
                sourceHint: "Lebensdauer Billigwerkzeug vs. Markenwerkzeug"
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.industryInnovation], encounter:
            .fact(Fact(
                text: "Bei Akkuwerkzeug stirbt fast immer der Akku zuerst, nicht die Maschine. Es gibt Betriebe, die Akkupacks öffnen und die Zellen darin ersetzen – aus einem Elektronikschrottfall wird ein Werkzeug mit voller Leistung. Das Gehäuse, die Elektronik und die Kontakte bleiben, was sie waren.",
                sourceHint: "Zellentausch bei Werkzeugakkus, Anbieter und Grenzen"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Was verlängert die Lebensdauer deiner Sachen am meisten?",
                itemsInOrder: ["Ein gutes Werkzeug besitzen", "Wissen, wie man es benutzt", "Jemanden kennen, der es kann", "Ein Gerät kaufen, das sich öffnen lässt"],
                lowLabel: "hilft",
                highLabel: "hilft am meisten",
                explanation: "Ein Gerät, das sich nicht öffnen lässt, macht alles davor wertlos – da nützt das beste Werkzeug nichts. Deshalb ist Reparierbarkeit eine Eigenschaft, die beim Kauf entschieden wird, nicht beim Defekt.",
                sourceHint: "Reparierbarkeitsindex, Kriterien und Wirkung"
            )))
    ]

    // MARK: - Elektronik

    static let electronicsEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption, .climateAction], encounter:
            .estimate(Estimate(
                question: "Wie viel vom Klimafußabdruck eines Smartphones entsteht bei der Herstellung – nicht im Betrieb?",
                range: 0...100,
                answer: 80,
                unit: "%",
                explanation: "Das Gerät ist am schädlichsten, bevor es angeschaltet wird. Deshalb ändert Strom sparen beim Handy fast nichts, während ein Jahr längere Nutzung sehr viel ändert. Bei Elektronik gilt fast immer: alt behalten schlägt sparsam neu.",
                sourceHint: "Anteil Herstellung am Lebenszyklus-Fußabdruck von Smartphones"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .industryInnovation], encounter:
            .story(Story(
                title: "Der Akku, der das Gerät mitnimmt",
                paragraphs: [
                    "Fast jedes Gerät, das man wegwirft, ist nicht kaputt. Es hat nur einen müden Akku.",
                    "Ein Akku ist ein Verschleißteil, wie ein Reifen. Nach ein paar hundert Ladezyklen lässt er nach, das ist Chemie und kein Defekt.",
                    "Wenn er verklebt statt verschraubt ist, wird aus dem Verschleißteil aber das Ende des Geräts – zusammen mit Bildschirm, Kamera, Prozessor und allem Kupfer darin.",
                    "Ein Cent Kleber entscheidet so über ein Kilogramm Rohstoff. Deshalb ist Reparierbarkeit keine Bastlerfrage, sondern eine Konstruktionsentscheidung."
                ],
                sourceHint: "Ladezyklen Lithium-Ionen-Akkus; Anteil Akkudefekte an Geräteausfällen"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Neues Handy nötig. Was ist die bessere Wahl?",
                optionA: "Neugerät der sparsamsten Generation",
                optionB: "Generalüberholtes Gerät von vorletztem Jahr",
                betterIsA: false,
                explanation: "Weil der Fußabdruck fast vollständig in der Herstellung steckt, schlägt ein gebrauchtes Gerät ein neues fast immer – auch wenn das neue etwas sparsamer läuft. Der Effizienzgewinn holt die Herstellung nicht ein.",
                sourceHint: "Vergleich Fußabdruck Neugerät vs. refurbished Gerät"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption, .lifeOnLand], encounter:
            .fact(Fact(
                text: "In einer Tonne Althandys steckt mehr Gold als in einer Tonne Golderz. Der Fachbegriff dafür ist urban mining – die reichsten Lagerstätten liegen inzwischen in Schubladen.",
                sourceHint: "Goldgehalt Elektronikschrott vs. Golderz, urban mining"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Öffne die Schublade, in der die alten Kabel und Geräte liegen, und zähl, wie viele Geräte darin noch funktionieren würden.",
                hint: "Fast jeder Haushalt hat diese Schublade. Was darin liegt, ist kein Müll, sondern geparkte Rohstoffe – und meistens ein Ladekabel, das noch jemand brauchen kann."
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Was verlängert die Lebensdauer eines Laptops am meisten?",
                itemsInOrder: ["Bildschirm dunkler stellen", "Ihn sauber halten und lüften", "Mehr Speicher nachrüsten", "Ihn nicht ersetzen, wenn er langsam wirkt"],
                lowLabel: "kaum",
                highLabel: "am meisten",
                explanation: "„Langsam“ ist selten ein Hardware-Ende. Oft ist es Software, manchmal ein voller Speicher, fast nie ein Defekt. Der teuerste Fehler ist, Langsamkeit für Verschleiß zu halten.",
                sourceHint: "Ursachen für Geräteaustausch bei Notebooks, Nutzerbefragungen"
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.industryInnovation, .responsibleConsumption], encounter:
            .duel(Duel(
                question: "Die Tonerkartusche im Drucker ist leer.",
                optionA: "Neue Originalkartusche",
                optionB: "Wiederaufbereitete Kartusche mit Garantie",
                betterIsA: false,
                explanation: "Eine wiederaufbereitete Kartusche wird zerlegt, gereinigt, verschlissene Teile werden ersetzt, dann neu befüllt und geprüft. Das Gehäuse übersteht mehrere Runden. Genau das ist R6 – nicht Recycling, sondern ein Bauteil, das ein zweites Berufsleben bekommt.",
                sourceHint: "Wiederaufbereitung von Tonerkartuschen, Materialeinsparung gegenüber Neuware"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Wohin gehört ein defektes Elektrogerät?",
                options: [
                    "Restmüll, wenn es klein genug ist",
                    "Wertstoffhof oder Rücknahme im Handel",
                    "Gelbe Tonne, wenn es aus Kunststoff ist"
                ],
                correctIndex: 1,
                explanation: "Elektroschrott gehört nie in den Hausmüll – wegen der Rohstoffe darin und wegen der Akkus, die in Müllfahrzeugen und Sortieranlagen regelmäßig Brände auslösen. Größere Händler müssen Altgeräte zurücknehmen, auch ohne Neukauf.",
                sourceHint: "ElektroG, Rücknahmepflichten des Handels; Brandursache Lithiumakkus in der Entsorgung"
            )))
    ]

    // MARK: - Haushaltsgerät

    static let applianceEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.affordableEnergy, .climateAction], encounter:
            .quiz(Quiz(
                question: "Wo verbraucht ein Kühlschrank unnötig am meisten?",
                options: [
                    "Wenn er zu voll ist",
                    "Wenn seine Rückseite verstaubt oder eng an der Wand steht",
                    "Wenn er zu leer ist"
                ],
                correctIndex: 1,
                explanation: "Ein Kühlschrank arbeitet, indem er Wärme nach hinten abgibt. Kommt die Wärme nicht weg, läuft er länger. Voll ist übrigens besser als leer – die kalte Masse hält die Temperatur, wenn die Tür aufgeht.",
                sourceHint: "Einfluss von Aufstellung und Wärmetauscherreinigung auf den Kühlschrankverbrauch"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Die Waschmaschine ist acht Jahre alt und die Pumpe streikt.",
                optionA: "Reparieren lassen",
                optionB: "Neue kaufen, die ist sparsamer",
                betterIsA: true,
                explanation: "Bei Großgeräten mit langer Lebensdauer holt die bessere Energieklasse die Herstellung meist nicht ein – erst recht nicht bei einer einzelnen defekten Pumpe. Die Ausnahme ist ein sehr alter Stromfresser: Bei Kühl- und Gefriergeräten, die durchlaufen, kann Tauschen rechnerisch aufgehen.",
                sourceHint: "Amortisation Neugerät vs. Reparatur bei Waschmaschinen und Kühlgeräten"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.affordableEnergy], encounter:
            .ordering(Ordering(
                question: "Was zieht im Haushalt über das Jahr am meisten Strom?",
                itemsInOrder: ["Ladegerät im Standby", "Kaffeemaschine", "Kühlschrank", "Wäschetrockner"],
                lowLabel: "wenig",
                highLabel: "viel",
                explanation: "Der Trockner ist der heimliche Spitzenreiter, weil Wasser zu verdampfen sehr viel Energie kostet – die Wäscheleine ist das wirksamste Haushaltsgerät, das keinen Strom braucht. Standby ist real, aber im Vergleich klein: Es fühlt sich an wie das Hauptproblem, weil das Lämpchen sichtbar ist.",
                sourceHint: "Stromverbrauch Haushaltsgeräte im Jahresvergleich, Anteil Standby"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Ein Wasserkocher, der innen weiß belegt ist, braucht länger und mehr Strom für dieselbe Menge Wasser. Entkalken ist damit eine Instandsetzung – die billigste Effizienzmaßnahme im Haushalt, und sie kostet einen Löffel Essig."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Finde das Gerät in deiner Küche, das du am seltensten benutzt, und entscheide: Behalten, verleihen oder weitergeben?",
                hint: "Eismaschine, Fritteuse, Brotbackautomat, Entsafter. Fast jeder Haushalt hat mindestens eins, das nur beim Umzug getragen wird."
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.industryInnovation, .decentWork], encounter:
            .fact(Fact(
                text: "Bei Großgeräten gibt es einen Markt, den kaum jemand kennt: Alte Maschinen werden zerlegt, die guten Baugruppen geprüft und in aufgearbeitete Geräte eingebaut, die mit voller Gewährleistung verkauft werden. Für Gastronomie und Wäschereien ist das Normalität – in Privathaushalten kennt es fast niemand.",
                sourceHint: "Markt für aufgearbeitete Groß- und Gewerbegeräte, Gewährleistungspraxis"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy], encounter:
            .video(VideoTip(
                searchTerm: "Wärmepumpe Funktionsweise erklärt Kühlschrank umgekehrt",
                why: "Eine Wärmepumpe ist ein rückwärts laufender Kühlschrank. Wer das einmal begriffen hat, versteht sowohl das Gerät in der Küche als auch die halbe Energiedebatte."
            )))
    ]

    // MARK: - Möbel

    static let furnitureEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Der häufigste Grund, warum ein Möbelstück entsorgt wird, ist nicht Bruch – es ist Umzug, Geschmack oder eine ausgerissene Schraube. Zwei davon lassen sich mit einem Dübel beheben, das dritte mit Nachdenken."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption, .sustainableCities], encounter:
            .duel(Duel(
                question: "Du brauchst ein Regal.",
                optionA: "Neu gekauft, günstig, passt genau",
                optionB: "Gebraucht, kostenlos, muss abgeholt werden",
                betterIsA: false,
                explanation: "Gebrauchte Möbel sind der Bereich, in dem Kreislaufwirtschaft am unmittelbarsten funktioniert: kein Herstellungsaufwand, keine Verpackung, oft bessere Substanz als Neuware im selben Preisbereich. Der einzige Preis ist ein Transporter und ein Nachmittag.",
                sourceHint: "Fußabdruck Neumöbel vs. Gebrauchtmöbel"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption, .decentWork], encounter:
            .mission(Mission(
                prompt: "Such dir das Möbelstück in deiner Nähe, das am müdesten aussieht, und überleg konkret: Was bräuchte es, damit es wieder gut wäre?",
                hint: "Oft erstaunlich wenig – ein neuer Bezug, feste Schrauben, abgeschliffene Kanten. Aufarbeiten ist R5 und die am meisten unterschätzte Stufe."
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .story(Story(
                title: "Warum Möbel früher schwerer waren",
                paragraphs: [
                    "Alte Möbel sind schwer, weil sie aus massivem Holz sind. Neue sind leicht, weil sie aus beschichteten Spanplatten sind.",
                    "Das ist kein reiner Rückschritt: Spanplatte nutzt Reste, spart Material und macht Möbel bezahlbar.",
                    "Der Haken sitzt an den Kanten. Massivholz kann man abschleifen, leimen, neu ölen. Eine aufgequollene Spanplatte kann man nichts.",
                    "Deshalb sind neue Möbel oft nicht schlechter gebaut, sondern anders gedacht: für ein Leben statt für drei. Wer das weiß, kauft anders – und wirft anders weg."
                ]
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Was passiert mit einem Möbelstück am ehesten, wenn es aussortiert wird?",
                itemsInOrder: ["Es wird verkauft oder verschenkt", "Es steht am Straßenrand", "Es kommt zum Sperrmüll", "Es wird verbrannt"],
                lowLabel: "am besten",
                highLabel: "am schlechtesten",
                explanation: "Die Reihenfolge ist genau die R-Leiter im Kleinen: weiternutzen, umwidmen, verwerten, verbrennen. Wo ein Möbelstück landet, entscheidet meistens nicht sein Zustand, sondern wie viel Mühe man sich gibt – und wie früh man anfängt.",
                sourceHint: "Verbleib von Sperrmüll und Altmöbeln, Anteile"
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.decentWork, .responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Büromöbel werden im großen Stil aufgearbeitet und weiterverkauft. Warum ausgerechnet Büromöbel?",
                options: [
                    "Weil sie besonders robust gebaut sind",
                    "Weil sie in großen, gleichen Mengen anfallen",
                    "Weil sie besonders teuer sind"
                ],
                correctIndex: 1,
                explanation: "Wenn eine Firma umzieht, kommen hundert gleiche Stühle auf einmal. Gleiche Teile in großer Zahl machen das Aufarbeiten wirtschaftlich – dieselbe Bedingung, unter der Remanufacturing überall funktioniert. Einzelstücke lohnen sich fast nie, Serien fast immer.",
                sourceHint: "Markt für aufgearbeitete Büromöbel, Voraussetzungen für Remanufacturing"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Finde drei verschiedene Möbelstücke.",
                theme: .furniture,
                count: 3,
                seconds: 90,
                reward: "Möbel sind der langlebigste Besitz der meisten Haushalte – und der, über den am wenigsten nachgedacht wird."
            )))
    ]

    // MARK: - Geschirr

    static let tablewareEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Feier mit zwanzig Leuten. Was ist besser?",
                optionA: "Einweggeschirr aus Zuckerrohr oder Palmblatt",
                optionB: "Das eigene Geschirr und eine Stunde Abwasch",
                betterIsA: false,
                explanation: "Einweg aus nachwachsenden Rohstoffen ist besser als Kunststoff, aber immer noch Einweg: angebaut, geformt, transportiert, einmal benutzt. Der Abwasch ist unbeliebt und trotzdem die deutlich bessere Bilanz. Manchmal ist die richtige Antwort einfach die unbequeme.",
                sourceHint: "Ökobilanz Einweggeschirr aus Biomaterial vs. Mehrweg inkl. Spülen"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.cleanWater, .affordableEnergy], encounter:
            .quiz(Quiz(
                question: "Spülmaschine oder Handspülen – was verbraucht meist weniger Wasser?",
                options: ["Handspülen", "Die volle Spülmaschine", "Kommt aufs Geschirr an"],
                correctIndex: 1,
                explanation: "Eine voll beladene Spülmaschine schlägt Handspülen bei Wasser und meist auch bei Energie – vorausgesetzt, sie ist voll und man spült nicht vor. Das Vorspülen unter fließendem Wasser macht den Vorteil zunichte.",
                sourceHint: "Vergleichsstudien Geschirrspüler vs. Handspülen, Wasser- und Energieverbrauch"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Ein Teller, der zwanzig Jahre hält, wird etwa zehntausendmal benutzt. Kein anderer Gegenstand im Haushalt hat ein so gutes Verhältnis von Herstellungsaufwand zu Nutzung – außer vielleicht die Gabel daneben."
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Such den angeschlagenen Teller oder die Tasse mit dem Sprung heraus und gib ihr eine neue Aufgabe, statt sie wegzuwerfen.",
                hint: "Untersetzer, Seifenschale, Stiftebecher, Pflanzentopf. Ein Sprung macht Geschirr unbrauchbar zum Essen, nicht unbrauchbar."
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .qualityEducation], encounter:
            .story(Story(
                title: "Der Bruch, den man zeigt",
                paragraphs: [
                    "Wenn in Europa eine Schale zerbricht, wird sie weggeworfen oder unsichtbar geklebt. Der Bruch gilt als Makel.",
                    "In Japan gibt es eine Technik, die genau das Gegenteil tut: Die Bruchstellen werden mit Lack gefügt und mit Goldpulver bestäubt.",
                    "Die Naht wird also hervorgehoben, nicht versteckt. Die reparierte Schale ist danach auffälliger als die heile – und oft wertvoller.",
                    "Kintsugi ist deshalb mehr als eine Klebetechnik. Es ist die Behauptung, dass ein Gegenstand durch seine Geschichte gewinnt. Wer das glaubt, wirft anders weg."
                ],
                sourceHint: "Kintsugi, Technik und kunsthistorische Einordnung"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Wie oft muss ein Mehrwegbecher benutzt werden, bis er den Einwegbecher schlägt?",
                itemsInOrder: ["Becher aus dünnem Kunststoff", "Becher aus Glas", "Becher aus Edelstahl", "Becher aus Keramik"],
                lowLabel: "wenige Male",
                highLabel: "viele Male",
                explanation: "Je stabiler und aufwendiger der Becher, desto länger dauert es, bis er sich rechnet. Der schöne schwere Thermobecher ist die schlechteste Wahl, wenn er im Schrank steht – und die beste, wenn er täglich mitfährt. Mehrweg ist kein Material, es ist eine Gewohnheit.",
                sourceHint: "Break-even-Punkte Mehrwegbecher nach Material"
            )))
    ]

    // MARK: - Körperpflege

    static let hygieneEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption, .cleanWater], encounter:
            .fact(Fact(
                text: "Ein Stück festes Shampoo ersetzt mehrere Flaschen und besteht zum größten Teil aus dem, was man kaufen wollte. Flüssige Pflegeprodukte bestehen überwiegend aus Wasser – man bezahlt und transportiert also vor allem etwas, das zu Hause aus der Leitung käme.",
                sourceHint: "Wasseranteil in flüssigen Kosmetikprodukten"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.cleanWater, .lifeBelowWater], encounter:
            .quiz(Quiz(
                question: "Was landet über das Badezimmer am ehesten im Gewässer?",
                options: [
                    "Reste von Zahnpasta",
                    "Rückstände von Medikamenten",
                    "Seifenschaum"
                ],
                correctIndex: 1,
                explanation: "Kläranlagen holen Feststoffe und viele Nährstoffe heraus, aber Arzneimittelrückstände nur teilweise. Deshalb ist die eine Badezimmerregel, die wirklich zählt: Medikamente gehören niemals in Toilette oder Spüle, sondern in die Apotheke oder den Restmüll.",
                sourceHint: "Spurenstoffe in Gewässern, Eliminationsraten in Kläranlagen; Entsorgungswege Altmedikamente"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Rasieren.",
                optionA: "Einwegrasierer aus der Zehnerpackung",
                optionB: "Rasierhobel mit wechselbarer Klinge",
                betterIsA: false,
                explanation: "Beim Rasierhobel wird nur die Klinge getauscht – ein Gramm Stahl statt eines ganzen Griffs aus Kunststoff und Gummi. Es ist eines der wenigen Beispiele, wo die alte Technik der neuen in fast jeder Hinsicht überlegen ist, Preis eingeschlossen."
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.goodHealth, .responsibleConsumption], encounter:
            .story(Story(
                title: "Die Erfindung, die ein Problem gelöst hat, das es nicht gab",
                paragraphs: [
                    "Mikroplastik in Kosmetik war einmal ein Verkaufsargument: kleine Kügelchen als Peeling, gleichmäßiger als Sand oder Salz.",
                    "Sie waren billig, wirkten sanft und ließen sich gut bewerben. Ein Fortschritt, wie es schien.",
                    "Dann stellte sich heraus, dass keine Kläranlage sie zurückhält. Was im Waschbecken verschwindet, taucht im Gewässer wieder auf.",
                    "Inzwischen sind feste Mikroplastikpartikel in Kosmetik in der EU weitgehend beschränkt. Bleibt die Frage, die das Beispiel so gut stellt: Wie viele solcher Selbstverständlichkeiten benutzen wir gerade, ohne sie zu bemerken?"
                ],
                sourceHint: "EU-Beschränkung für absichtlich zugesetztes Mikroplastik, REACH"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Schau bei drei Pflegeprodukten in deinem Bad auf die Verpackung und finde heraus, welche davon sich überhaupt sortenrein trennen lässt.",
                hint: "Pumpspender mit Metallfeder, Tuben mit Aluschicht, Deckel aus anderem Kunststoff als die Flasche. Die meisten sind Mischungen – und Mischungen sind das Ende jedes Kreislaufs."
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Zwei Dinge aus dem Bad, die länger halten als eine Packung.",
                theme: .hygiene,
                count: 2,
                seconds: 90,
                reward: "Im Bad steht das Verhältnis besonders schlecht: viel Verpackung, wenig Ding."
            )))
    ]

    // MARK: - Gegenstand (Auffang)

    static let stuffEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Jeder Gegenstand um dich herum hat eine Vorgeschichte aus Material, Energie und Transport – und eine Nachgeschichte, die meist niemand plant. Die zehn R-Stufen sind nichts anderes als der Versuch, diese Nachgeschichte vorher zu entscheiden."
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Die ehrlichste Frage vor jedem Kauf.",
                optionA: "Ist das Produkt nachhaltig hergestellt?",
                optionB: "Brauche ich es?",
                betterIsA: false,
                explanation: "Die erste Frage ist die, die die Werbung beantwortet. Die zweite ist die, die niemand für dich beantwortet. R0 steht nicht ohne Grund ganz oben auf der Leiter: Kein Produkt schlägt kein Produkt."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Die R-Leiter – was wirkt am stärksten?",
                itemsInOrder: ["Gar nicht erst kaufen", "Länger benutzen", "Reparieren", "Recyceln"],
                lowLabel: "am stärksten",
                highLabel: "am schwächsten",
                explanation: "Recycling steht ganz unten und ist trotzdem das Einzige, worüber die meisten sprechen. Das ist die zentrale Verschiebung, die dieses Spiel geraderücken will: Recycling ist die Rettung, nicht die Lösung.",
                sourceHint: "R-Strategien-Hierarchie, Reihenfolge und Begründung"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Nimm den nächstbesten Gegenstand in die Hand und versuch zu rekonstruieren, woraus er besteht und wo er hergekommen ist.",
                hint: "Meistens kommt man nicht weit – und genau das ist die Erkenntnis. Wir besitzen fast nur Dinge, deren Herkunft wir nicht kennen."
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .story(Story(
                title: "Der Gegenstand, der niemandem gehört",
                paragraphs: [
                    "Wenn ein Ding kaputtgeht, ist die erste Frage meistens: Wegwerfen oder ersetzen?",
                    "Es gibt eine dritte Frage, die selten gestellt wird: Wem gehört eigentlich das Material darin?",
                    "Rechtlich: dir. Praktisch: niemandem, sobald es in der Tonne liegt – und danach dem, der es aussortiert.",
                    "Einige Hersteller drehen das gerade um und behalten das Material im Besitz, verkaufen nur die Nutzung. Teppichfliesen, Beleuchtung, Arbeitskleidung. Wer das Material behält, baut anders."
                ],
                sourceHint: "Produkt-als-Dienstleistung-Modelle, Beispiele und Verbreitung"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Finde drei verschiedene Dinge – irgendwelche.",
                theme: .stuff,
                count: 3,
                seconds: 60,
                reward: "Es ist erstaunlich, wie viele Gegenstände in Reichweite liegen, sobald man zählt."
            )))
    ]
}
