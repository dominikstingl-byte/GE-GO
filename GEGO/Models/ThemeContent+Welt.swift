import Foundation

// Inhalte für die Themen, die größer sind als ein Gegenstand: Energie, Wasser,
// Gebautes, Verkehr, Essen, Lebendiges.
//
// Gleiche Regel wie im Schwesterdatei: Alle Texte sind Entwürfe, jede Zahl
// trägt einen `sourceHint` als Merkzettel, und Videohinweise sind Suchbegriffe
// statt Adressen.

extension Theme {

    // MARK: - Energie

    static let energyEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.affordableEnergy, .climateAction], encounter:
            .ordering(Ordering(
                question: "Gleiche Helligkeit, gleiche Zeit – was braucht am meisten Strom?",
                itemsInOrder: ["LED", "Energiesparlampe", "Halogenlampe", "Glühbirne"],
                lowLabel: "am wenigsten",
                highLabel: "am meisten",
                explanation: "Eine Glühbirne ist im Grunde ein kleiner Heizkörper, der nebenbei leuchtet – der weitaus größte Teil der Energie wird Wärme statt Licht. Der Sprung von Glüh- auf LED-Licht ist eine der wenigen Effizienzgeschichten, die wirklich um den Faktor zehn gehen.",
                sourceHint: "Lichtausbeute in Lumen pro Watt nach Lampentyp"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.affordableEnergy, .climateAction], encounter:
            .story(Story(
                title: "Die Kilowattstunde, die nie gebraucht wurde",
                paragraphs: [
                    "Über Energie wird fast immer gesprochen, als sei die Frage: woher nehmen? Kohle, Gas, Wind, Sonne, Kernkraft.",
                    "Es gibt eine Energiequelle, die in keiner dieser Debatten vorkommt, obwohl sie die größte ist.",
                    "Die Kilowattstunde, die nicht gebraucht wird, muss nicht erzeugt, nicht transportiert, nicht gespeichert und nicht bezahlt werden. Sie hat keine Leitung, keinen Standort und keine Gegner.",
                    "In der Fachsprache heißt sie Negawatt. Sie ist unsichtbar, deshalb unpopulär – und deshalb steht Reduzieren im Spiel auf Stufe R2, weit oben."
                ],
                sourceHint: "Negawatt-Konzept, Amory Lovins; Effizienz als Energiequelle"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.affordableEnergy], encounter:
            .estimate(Estimate(
                question: "Wie viel Prozent der Energie einer Glühbirne wird tatsächlich Licht?",
                range: 0...30,
                answer: 5,
                unit: "%",
                explanation: "Der Rest wird Wärme. Das ist der Grund, warum alte Schreibtischlampen heiß werden und LEDs nicht – und ein gutes Bild dafür, dass „Verbrauch“ fast immer heißt: an der falschen Stelle Wärme erzeugen.",
                sourceHint: "Wirkungsgrad Glühlampe, Anteil sichtbares Licht"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.affordableEnergy, .climateAction], encounter:
            .duel(Duel(
                question: "Ein Grad kälter heizen oder alle Lampen auf LED?",
                optionA: "Ein Grad kälter heizen",
                optionB: "Alle Lampen tauschen",
                betterIsA: true,
                explanation: "Heizen ist im Haushalt der mit Abstand größte Energieposten, Licht einer der kleinsten. Ein Grad weniger spürt man kaum, in der Abrechnung dagegen deutlich. Wer bei Energie etwas bewegen will, fängt bei der Wärme an – nicht beim Licht.",
                sourceHint: "Anteil Raumwärme am Endenergieverbrauch der Haushalte"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy], encounter:
            .fact(Fact(
                text: "Jedes Gerät, das läuft, gibt am Ende seine ganze Energie als Wärme ab – der Laptop, der Kühlschrank, die Lampe, du selbst. Im Winter heizt das mit. Im Sommer ist es genau das, wogegen die Klimaanlage anarbeitet."
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.affordableEnergy, .industryInnovation], encounter:
            .video(VideoTip(
                searchTerm: "Warum Stromnetz Frequenz 50 Hertz Balance Erzeugung Verbrauch",
                why: "Strom lässt sich kaum speichern, deshalb muss in jeder Sekunde genau so viel erzeugt wie verbraucht werden. Wer das einmal verstanden hat, versteht auch, warum Speicher die eigentliche Frage der Energiewende sind."
            )))
    ]

    // MARK: - Wasser

    static let waterEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.cleanWater, .responsibleConsumption], encounter:
            .story(Story(
                title: "Das Wasser, das man nicht sieht",
                paragraphs: [
                    "Ein Mensch in Deutschland verbraucht rund 120 Liter Leitungswasser am Tag – Duschen, Spülen, Toilette.",
                    "Das ist die Zahl, die in jeder Broschüre steht. Sie ist richtig und sie ist der kleinere Teil.",
                    "Denn in allem, was wir kaufen, steckt Wasser: im Anbau der Baumwolle, im Futter für das Rind, in der Herstellung der Elektronik. Dieses virtuelle Wasser übersteigt den Hahn um ein Vielfaches.",
                    "Der unangenehme Teil daran: Das sichtbare Wasser kommt meist aus der Region und ist reichlich vorhanden. Das unsichtbare kommt oft aus Gegenden, in denen es das nicht ist."
                ],
                sourceHint: "Direkter Trinkwasserverbrauch pro Kopf; virtuelles Wasser im Konsum"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.cleanWater, .affordableEnergy], encounter:
            .quiz(Quiz(
                question: "Warum spart kürzer duschen mehr, als man denkt?",
                options: [
                    "Weil Wasser knapp ist",
                    "Weil das Wasser erwärmt werden muss",
                    "Weil die Kläranlage entlastet wird"
                ],
                correctIndex: 1,
                explanation: "In Deutschland ist Wasser selten knapp – Warmwasser dagegen ist Energie. Der eigentliche Posten beim Duschen ist die Heizung, nicht der Hahn. Deshalb ist die Duschzeit eine Energiefrage im Wasserkostüm.",
                sourceHint: "Anteil Warmwasserbereitung am Haushaltsenergieverbrauch"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.cleanWater, .lifeBelowWater], encounter:
            .ordering(Ordering(
                question: "Was gehört auf keinen Fall in den Abfluss?",
                itemsInOrder: ["Nudelwasser", "Speisereste", "Frittierfett", "Medikamente"],
                lowLabel: "unproblematisch",
                highLabel: "richtig schlecht",
                explanation: "Fett verstopft und bildet in Kanälen regelrechte Klumpen, Medikamente kommen durch die Kläranlage praktisch hindurch. Die Toilette ist kein zweiter Mülleimer – sie ist der Eingang zu einem System, das nur Wasser und Papier verarbeiten kann.",
                sourceHint: "Kanalverfettung; Elimination von Arzneimittelrückständen in Kläranlagen"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.cleanWater], encounter:
            .mission(Mission(
                prompt: "Stell beim nächsten Duschen einen Eimer unter, während du auf warmes Wasser wartest, und schau, wie viel zusammenkommt.",
                hint: "Das Wasser ist völlig sauber – es ist nur kalt. Blumen, Putzeimer, Toilettenspülung nehmen es gern."
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.cleanWater], encounter:
            .estimate(Estimate(
                question: "Ein Wasserhahn tropft einmal pro Sekunde. Wie viel Liter sind das im Jahr?",
                range: 0...15000,
                answer: 5000,
                unit: "Liter",
                explanation: "Ein Tropfen ist nichts, ein Jahr ist lang. Das ist das ganze Prinzip hinter kleinen Dauerlecks – und der Grund, warum eine Dichtung für zwei Euro die wirtschaftlichste Reparatur im Haushalt ist.",
                sourceHint: "Tropfenvolumen und Hochrechnung Wasserverlust tropfender Hahn"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.cleanWater, .affordableEnergy], encounter:
            .fact(Fact(
                text: "Das Warmwasser, das im Abfluss verschwindet, nimmt seine Wärme mit. Es gibt Duschrinnen, die genau diese Wärme zurückholen und dem zulaufenden Kaltwasser übergeben – Wärmerückgewinnung im Badezimmermaßstab.",
                sourceHint: "Wärmerückgewinnung aus Duschabwasser, erreichbare Rückgewinnungsraten"
            )))
    ]

    // MARK: - Abfall

    static let wasteEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Ein Mülleimer ist die einzige Stelle im Haushalt, an der man sieht, was man entschieden hat. Alles darin war einmal eine Kaufentscheidung – nur eben eine, die man längst vergessen hat."
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Joghurtbecher aus Kunststoff mit Aludeckel – was ist richtig?",
                options: [
                    "Zusammen in die Gelbe Tonne",
                    "Deckel abziehen, beides getrennt in die Gelbe Tonne",
                    "Becher spülen, dann zusammen entsorgen"
                ],
                correctIndex: 1,
                explanation: "Getrennt, aber nicht gespült: Die Sortieranlage erkennt Materialien einzeln, verbundene bleiben Gemisch. Ausspülen ist dagegen unnötig – löffelrein reicht, und das gespülte Wasser kostet mehr, als es bringt.",
                sourceHint: "Sortiervorgaben Leichtverpackungen, Trennung von Verbundmaterialien"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.zeroHunger, .responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Wo entstehen in Deutschland die meisten Lebensmittelabfälle?",
                itemsInOrder: ["Privathaushalte", "Gastronomie", "Handel", "Verarbeitung"],
                lowLabel: "am meisten",
                highLabel: "am wenigsten",
                explanation: "Die meisten vermuten den Supermarkt mit seinen vollen Regalen. Tatsächlich fällt der größte Anteil zu Hause an – in kleinen Mengen, unbemerkt, über das ganze Jahr verteilt. Was unsichtbar ist, wird unterschätzt.",
                sourceHint: "Lebensmittelabfälle nach Sektor in Deutschland, Thünen-Institut"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Schau in deinen Restmüll und finde ein Ding, das dort nicht hingehört hätte.",
                hint: "Batterien, Elektrokleinteile, Altglas, Bioabfall. In fast jedem Restmülleimer liegt etwas, das eine eigene Tonne hätte."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.affordableEnergy, .climateAction], encounter:
            .story(Story(
                title: "Warum Deponien schlimmer sind als Verbrennen",
                paragraphs: [
                    "Verbrennen klingt nach der schlechtesten Lösung. Rauch, Schornstein, weg ist es.",
                    "Auf einer Deponie passiert etwas Unauffälligeres: Organisches Material zersetzt sich ohne Sauerstoff.",
                    "Dabei entsteht Methan – ein Treibhausgas, das über zwanzig Jahre gerechnet ein Vielfaches der Wirkung von CO₂ hat.",
                    "Deshalb steht Verbrennen mit Energiegewinn im Spiel auf R9 und die Deponie überhaupt nicht mehr auf der Leiter. Nicht weil Verbrennen gut wäre – sondern weil langsames Verrotten unter Ausschluss von Luft noch schlechter ist."
                ],
                sourceHint: "Methanbildung auf Deponien, Treibhauspotenzial; Deponierungsverbot für unbehandelte Siedlungsabfälle in Deutschland"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Was verändert mehr?",
                optionA: "Perfekt trennen",
                optionB: "Halb so viel wegwerfen",
                betterIsA: false,
                explanation: "Trennen ist die letzte Station und ändert nur, wohin etwas geht. Weniger wegwerfen ändert, ob es überhaupt entsteht. Die R-Leiter ist nicht zufällig geordnet: Alles oben schlägt alles unten.",
                sourceHint: "Wirkung von Abfallvermeidung vs. Recycling in der Abfallhierarchie"
            )))
    ]

    // MARK: - Gebautes

    static let buildingEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.sustainableCities, .climateAction], encounter:
            .estimate(Estimate(
                question: "Wie viel des deutschen Abfallaufkommens stammt aus Bau und Abbruch?",
                range: 0...100,
                answer: 55,
                unit: "%",
                explanation: "Über die Hälfte – Bauschutt ist mit Abstand der größte Abfallstrom, weit vor allem, was Haushalte produzieren. Der Kreislauf der Gebäude ist deshalb der größte Hebel überhaupt, und der, über den am seltensten gesprochen wird.",
                sourceHint: "Abfallbilanz Deutschland, Anteil Bau- und Abbruchabfälle"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.sustainableCities, .climateAction], encounter:
            .duel(Duel(
                question: "Ein altes, schlecht gedämmtes Haus.",
                optionA: "Abreißen und effizient neu bauen",
                optionB: "Sanieren und dämmen",
                betterIsA: false,
                explanation: "In einem Bestandsgebäude steckt bereits alles: Beton, Stahl, Ziegel, Transport. Diese graue Energie ist bezahlt und wird beim Abriss vernichtet. Ein sanierter Altbau schlägt den Neubau meist über Jahrzehnte – das effizienteste Haus ist fast immer das, das schon steht.",
                sourceHint: "Graue Energie im Bestand, Vergleich Sanierung vs. Ersatzneubau"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.sustainableCities], encounter:
            .story(Story(
                title: "Das Gebäude als Rohstofflager",
                paragraphs: [
                    "Ein Haus wird gebaut, um zu stehen. Über seine Nutzungsdauer denkt man beim Bauen selten nach.",
                    "Es gibt einen Gegenentwurf: Gebäude so zu bauen, dass sie sich zerlegen lassen – geschraubt statt verklebt, sortenrein statt verbunden.",
                    "Dazu gehört ein Verzeichnis: Was ist wo verbaut, in welcher Menge, in welcher Qualität. Ein Gebäudepass für Material.",
                    "Damit wird das Haus vom Endlager zum Zwischenlager. Der Begriff dafür ist urban mining – die Stadt als Bergwerk, das man nicht aufschließen, sondern nur auseinanderschrauben muss."
                ],
                sourceHint: "Urban Mining und Materialkataster im Bauwesen, Beispiele"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.sustainableCities, .goodHealth], encounter:
            .ordering(Ordering(
                question: "Wie viel Fläche braucht der Weg zur Arbeit je Person?",
                itemsInOrder: ["Zu Fuß", "Fahrrad", "Bus", "Auto"],
                lowLabel: "wenig",
                highLabel: "viel",
                explanation: "Stadtplanung ist zum großen Teil eine Frage der Fläche, nicht der Emissionen. Ein Auto braucht im Fahren und im Stehen ein Vielfaches – und Parkplätze sind Flächen, die dauerhaft nichts anderes sein können.",
                sourceHint: "Flächenbedarf pro Person nach Verkehrsmittel, ruhender und fließender Verkehr"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.sustainableCities, .industryInnovation], encounter:
            .fact(Fact(
                text: "Beton lässt sich zu Schotter brechen und wieder verbauen, aber der Zement darin ist unwiederbringlich verbraucht – seine Herstellung setzt Kohlendioxid frei, das chemisch aus dem Kalkstein stammt und nicht aus dem Ofen. Zementherstellung ist deshalb auch mit grünem Strom nicht klimaneutral.",
                sourceHint: "Prozessbedingte CO₂-Emissionen bei der Zementherstellung, Anteil am Gesamtausstoß"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.sustainableCities], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei verschiedene Dinge, die zum Gebauten gehören.",
                theme: .building,
                count: 2,
                seconds: 120,
                reward: "Straßen, Mauern, Brücken, Dächer – das Größte um uns herum ist das, was am seltensten hinterfragt wird."
            )))
    ]

    // MARK: - Verkehr

    static let vehicleEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.sustainableCities, .climateAction], encounter:
            .ordering(Ordering(
                question: "Fünf Kilometer in die Stadt – was verursacht am wenigsten?",
                itemsInOrder: ["Fahrrad", "Straßenbahn", "Voll besetztes Auto", "Auto mit einer Person"],
                lowLabel: "am wenigsten",
                highLabel: "am meisten",
                explanation: "Die Besetzung entscheidet mehr als der Antrieb. Ein voll besetztes Auto schlägt eine halbleere Bahn, ein leeres Auto verliert gegen fast alles. Wer über Verkehr nachdenkt, sollte zuerst über Sitzplätze nachdenken.",
                sourceHint: "Emissionen pro Personenkilometer nach Verkehrsmittel und Auslastung"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.climateAction], encounter:
            .story(Story(
                title: "Das schwere Auto, das sparsam ist",
                paragraphs: [
                    "Ein Elektroauto fährt lokal ohne Abgase. Das ist der Grund, warum es als Lösung gilt.",
                    "Sein Fußabdruck beginnt aber lange vorher: Der Akku ist der aufwendigste Teil, und je größer die Reichweite, desto größer der Akku.",
                    "Ein schweres Elektroauto mit sehr großer Batterie muss viele Kilometer fahren, bevor es einen kleinen Verbrenner einholt – und noch mehr, wenn der Strom nicht sauber ist.",
                    "Das ist keine Absage an den Elektroantrieb, sondern an die Größe. Der wirksamste Hebel im Verkehr ist nicht der Antrieb, sondern Masse und Anzahl der Fahrten."
                ],
                sourceHint: "Break-even-Kilometer Elektroauto vs. Verbrenner nach Batteriegröße und Strommix"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .goodHealth], encounter:
            .quiz(Quiz(
                question: "Womit verlängert man die Lebensdauer eines Fahrrads am meisten?",
                options: [
                    "Teure Bauteile kaufen",
                    "Kette regelmäßig reinigen und ölen",
                    "Es im Winter nicht fahren"
                ],
                correctIndex: 1,
                explanation: "Der Antrieb verschleißt zuerst, und er verschleißt vor allem durch Schmutz. Zehn Minuten Kettenpflege verlängern das Leben von Kette, Ritzeln und Kettenblättern erheblich – das ist R4 in seiner billigsten Form.",
                sourceHint: "Verschleiß von Fahrradantrieben in Abhängigkeit von Wartung"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.sustainableCities], encounter:
            .estimate(Estimate(
                question: "Wie viel Prozent der Zeit steht ein privates Auto im Schnitt still?",
                range: 50...100,
                answer: 95,
                unit: "%",
                explanation: "Ein Auto ist überwiegend ein Möbelstück, das im öffentlichen Raum steht. Genau das macht Teilen so naheliegend – und genau deshalb ist Carsharing keine Verzichtsübung, sondern eine Auslastungsfrage.",
                sourceHint: "Standzeitanteil privater Pkw, Mobilitätsstudien"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.climateAction], encounter:
            .duel(Duel(
                question: "Was spart mehr Emissionen?",
                optionA: "Ein Jahr konsequent vegetarisch essen",
                optionB: "Einen Hin- und Rückflug nach Nordamerika weglassen",
                betterIsA: false,
                explanation: "Ein einziger Langstreckenflug übersteigt sehr viele alltägliche Entscheidungen zusammengenommen. Das entwertet den Alltag nicht – aber es sortiert ihn. Wer viel fliegt, kann das mit Mülltrennen nicht ausgleichen.",
                sourceHint: "Emissionen Langstreckenflug pro Person vs. Ernährungsumstellung pro Jahr"
            ))),

        ThemedEncounter(strategy: .remanufacture, sdgs: [.industryInnovation, .responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Runderneuerte Reifen – was passiert dabei?",
                options: [
                    "Das alte Profil wird nachgeschnitten",
                    "Auf den geprüften Unterbau kommt eine neue Lauffläche",
                    "Der Reifen wird eingeschmolzen und neu gegossen"
                ],
                correctIndex: 1,
                explanation: "Der Unterbau mit Karkasse und Stahlgürtel ist der aufwendige Teil eines Reifens und hält länger als das Profil. Bei Lkw ist Runderneuerung deshalb seit Jahrzehnten Alltag. Es ist eines der ältesten Beispiele für R6 – und eines, an das beim Wort Kreislaufwirtschaft niemand denkt.",
                sourceHint: "Runderneuerung von Reifen, Materialeinsparung und Verbreitung im Nutzfahrzeugbereich"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Prüf den Reifendruck am nächsten Fahrrad oder Auto, an das du kommst.",
                hint: "Zu weiche Reifen kosten Kraft und Kraftstoff und verschleißen schneller. Es ist die kleinste Wartung mit dem besten Verhältnis von Aufwand zu Wirkung."
            )))
    ]

    // MARK: - Pflanzliches

    static let plantFoodEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction, .zeroHunger], encounter:
            .ordering(Ordering(
                question: "Ein Kilo davon – was verursacht die meisten Treibhausgase?",
                itemsInOrder: ["Linsen", "Kartoffeln", "Käse", "Rindfleisch"],
                lowLabel: "wenig",
                highLabel: "sehr viel",
                explanation: "Der Abstand zwischen den Enden dieser Liste ist größer als fast jeder andere Unterschied, den man beim Essen treffen kann – größer als regional gegen importiert, größer als bio gegen konventionell. Was auf dem Teller liegt, zählt mehr als woher es kommt.",
                sourceHint: "Treibhausgasemissionen pro Kilogramm Lebensmittel, Poore & Nemecek"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.climateAction, .responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Was ist bei Gemüse ökologisch meist am wichtigsten?",
                options: [
                    "Dass es regional ist",
                    "Dass es Saison hat",
                    "Dass es unverpackt ist"
                ],
                correctIndex: 1,
                explanation: "Saison schlägt Region: Regionales Gemüse aus dem beheizten Gewächshaus kann schlechter abschneiden als Freilandware von weiter weg. Der Transport ist bei fast allen Lebensmitteln der kleinere Posten – außer es fliegt.",
                sourceHint: "Treibhausgasbilanz Gemüse nach Anbauart und Saison"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.zeroHunger, .responsibleConsumption], encounter:
            .story(Story(
                title: "Die krumme Gurke",
                paragraphs: [
                    "Ein erheblicher Teil der Ernte erreicht den Laden nie – weil Größe, Form oder Farbe nicht passen.",
                    "Diese Ware ist einwandfrei. Sie ist nur krumm.",
                    "Aussortiert wird sie nicht aus Bosheit, sondern weil Handel und Logistik auf Gleichmaß gebaut sind: Kisten, Regale, Preise, Erwartungen.",
                    "Der Punkt ist unbequem: Der Maßstab wurde nicht von der Landwirtschaft gesetzt und nicht vom Handel allein. Er wurde von Menschen gesetzt, die im Laden zur schöneren Gurke greifen."
                ],
                sourceHint: "Vorernte- und Nachernteverluste durch Handelsnormen, Größenordnung"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.zeroHunger], encounter:
            .mission(Mission(
                prompt: "Schau in den Kühlschrank und finde das Lebensmittel, das als nächstes schlecht wird. Plan jetzt, wann du es isst.",
                hint: "Die meisten Lebensmittel werden nicht weggeworfen, weil sie verdorben sind, sondern weil sie vergessen wurden."
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.zeroHunger, .responsibleConsumption], encounter:
            .duel(Duel(
                question: "Das Mindesthaltbarkeitsdatum von gestern.",
                optionA: "Wegwerfen, sicher ist sicher",
                optionB: "Schauen, riechen, probieren",
                betterIsA: false,
                explanation: "Das Mindesthaltbarkeitsdatum ist eine Zusage des Herstellers über Qualität, kein Verfallsdatum. Joghurt, Nudeln, Reis, Konserven sind oft weit darüber hinaus einwandfrei. Nur beim Verbrauchsdatum auf rohem Fisch und Fleisch gilt das nicht – das ist die Ausnahme, die man kennen muss.",
                sourceHint: "Unterschied Mindesthaltbarkeits- und Verbrauchsdatum, LMIV"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.zeroHunger, .lifeOnLand], encounter:
            .fact(Fact(
                text: "Schalen, Strünke und Kerne im Biomüll werden zu Kompost oder in Vergärungsanlagen zu Biogas. Landen sie im Restmüll, werden sie verbrannt – zusammen mit dem Wasser darin, das erst verdampft werden muss. Nasser Abfall ist im Ofen der schlechteste Brennstoff, den es gibt.",
                sourceHint: "Heizwert von Bioabfall im Restmüll; Vergärung vs. Verbrennung"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.zeroHunger], encounter:
            .hunt(Hunt(
                prompt: "Finde drei verschiedene pflanzliche Lebensmittel.",
                theme: .plantFood,
                count: 3,
                seconds: 120,
                reward: "Küche, Obstschale, Vorratsschrank – oder der nächste Supermarkt."
            )))
    ]

    // MARK: - Tierisches

    static let animalFoodEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .reduce, sdgs: [.climateAction, .lifeOnLand], encounter:
            .story(Story(
                title: "Der Umweg über das Tier",
                paragraphs: [
                    "Ein Rind frisst Pflanzen und macht daraus Fleisch. Dabei geht der größte Teil der Energie verloren – für Bewegung, Wärme, Leben.",
                    "Das ist keine Kritik am Rind, das ist Thermodynamik. Jede Stufe in der Nahrungskette kostet.",
                    "Deshalb braucht ein Kilo Rindfleisch ein Vielfaches an Fläche und Futter im Vergleich zu einem Kilo pflanzlicher Nahrung mit ähnlichem Nährwert.",
                    "Der Gegenpunkt gehört dazu: Weidetiere können Gras verwerten, das für uns unverdaulich ist, und Grünland ist oft kein Ackerland. Das Problem ist nicht das Tier auf der Wiese – es ist die Menge und das Kraftfutter dahinter."
                ],
                sourceHint: "Futterverwertung und Flächenbedarf tierischer Produkte; Grünlandnutzung"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction], encounter:
            .duel(Duel(
                question: "Was ändert mehr an deiner Ernährungsbilanz?",
                optionA: "Bio statt konventionell kaufen",
                optionB: "Weniger Fleisch und Käse essen",
                betterIsA: false,
                explanation: "Bio wirkt stark auf Boden, Wasser und Artenvielfalt – bei Treibhausgasen je Kilo ist der Unterschied dagegen klein. Die Menge tierischer Produkte ist der größere Hebel. Beides zusammen ist besser als eines allein, aber wenn man nur eines ändert, dann dieses.",
                sourceHint: "Vergleich Klimawirkung Bio vs. konventionell; Effekt Ernährungsumstellung"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.zeroHunger, .responsibleConsumption], encounter:
            .fact(Fact(
                text: "„From nose to tail“ heißt: ein Tier vollständig verwerten, nicht nur die vier beliebten Stücke. Es klingt nach Feinschmeckerei, ist aber schlicht die Konsequenz aus dem Aufwand, der in einem Tier steckt."
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.lifeBelowWater], encounter:
            .quiz(Quiz(
                question: "Worauf kommt es bei Fisch ökologisch am meisten an?",
                options: [
                    "Auf die Art des Fisches",
                    "Auf Fanggebiet und Fangmethode",
                    "Auf die Frische"
                ],
                correctIndex: 1,
                explanation: "Dieselbe Art kann je nach Bestand und Methode vertretbar oder problematisch sein. Grundschleppnetze zerstören den Meeresboden, andere Verfahren kaum. Deshalb hilft bei Fisch keine Faustregel, sondern nur ein Blick auf Herkunft und Methode.",
                sourceHint: "Fischereimethoden und Beifang; Bestandsbewertungen nach Fanggebiet"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.zeroHunger], encounter:
            .mission(Mission(
                prompt: "Plan für diese Woche ein Essen, bei dem du Reste vom Vortag zur Hauptzutat machst.",
                hint: "Aus altem Brot wird Auflauf, aus Kartoffeln von gestern Bratkartoffeln. Fast jede traditionelle Küche ist im Kern Resteverwertung."
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .estimate(Estimate(
                question: "Wie viel Liter Wasser stecken schätzungsweise in einem Kilogramm Käse?",
                range: 0...10000,
                answer: 5000,
                unit: "Liter",
                explanation: "Der größte Teil davon ist Regenwasser für das Futter der Kuh, nicht Wasser aus dem Hahn. Genau das macht virtuelles Wasser so schwer greifbar: Es ist echt, aber es fließt nirgends sichtbar.",
                sourceHint: "Wasserfußabdruck Käse, Anteil grünes/blaues Wasser"
            )))
    ]

    // MARK: - Verarbeitetes

    static let processedFoodEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption, .lifeOnLand], encounter:
            .quiz(Quiz(
                question: "Warum steht Palmöl so oft in der Kritik – und warum ist Ersetzen trotzdem knifflig?",
                options: [
                    "Es ist ungesund, Alternativen sind gesünder",
                    "Sein Anbau kostet Regenwald, aber andere Öle brauchen mehr Fläche",
                    "Es lässt sich nicht recyceln"
                ],
                correctIndex: 1,
                explanation: "Die Ölpalme liefert je Hektar deutlich mehr Öl als Raps, Soja oder Kokos. Ersetzt man Palmöl schlicht durch ein anderes Öl, kann der Flächenbedarf steigen. Die ehrliche Antwort ist unbequem: weniger Öl insgesamt, und das übrige aus zertifiziertem Anbau.",
                sourceHint: "Flächenertrag Ölpflanzen im Vergleich; Wirkung von Zertifizierungssystemen"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption], encounter:
            .ordering(Ordering(
                question: "Wie viel Verpackung kommt auf wie viel Inhalt?",
                itemsInOrder: ["Sack Kartoffeln", "Nudelpackung", "Einzeln verpackte Kekse", "Kaffeekapseln"],
                lowLabel: "wenig",
                highLabel: "sehr viel",
                explanation: "Je kleiner die Portion, desto größer der Verpackungsanteil – bei Kapseln nähert sich das Verhältnis von Hülle zu Inhalt beunruhigend der Eins. Bequemlichkeit wird fast immer in Verpackung bezahlt.",
                sourceHint: "Verpackungsanteil pro Portion nach Produktform, Kaffeekapseln"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.goodHealth, .responsibleConsumption], encounter:
            .story(Story(
                title: "Warum das Haltbare erfunden wurde",
                paragraphs: [
                    "Konservieren war eine der wichtigsten Erfindungen der Menschheit. Wer Nahrung haltbar macht, überlebt den Winter.",
                    "Salzen, Trocknen, Räuchern, Einkochen, Kühlen – jede dieser Techniken hat Hungersnöte verhindert.",
                    "Verarbeitung ist also nicht das Gegenteil von gut. Sie ist der Grund, warum Lebensmittel nicht verderben, und damit selbst ein Mittel gegen Verschwendung.",
                    "Die Frage ist nur, wofür sie eingesetzt wird: um Essen haltbar zu machen – oder um etwas billiger, bunter und einzeln verpackt zu bekommen, das vorher schon in Ordnung war."
                ]
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.zeroHunger], encounter:
            .duel(Duel(
                question: "Tiefkühlgemüse oder frisches Gemüse aus dem Regal?",
                optionA: "Tiefkühl",
                optionB: "Frisch",
                betterIsA: true,
                explanation: "Eine der wenigen Fragen, bei denen die naheliegende Antwort wirklich falsch ist: Tiefkühlgemüse wird erntefrisch verarbeitet, hält Nährstoffe gut und wird zu Hause kaum weggeworfen. Frisches Gemüse verdirbt im Kühlschrank – und weggeworfenes Essen ist ökologisch der teuerste Zustand überhaupt.",
                sourceHint: "Vergleich Ökobilanz und Nährstoffgehalt Tiefkühl- vs. Frischgemüse inkl. Verluste"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.zeroHunger], encounter:
            .mission(Mission(
                prompt: "Such in deinem Vorratsschrank das Lebensmittel, das am längsten unangetastet dort steht, und plan, es diese Woche zu benutzen.",
                hint: "In fast jedem Schrank steht eine Packung, die seit dem Einkauf wartet, für den sie gedacht war."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.responsibleConsumption], encounter:
            .video(VideoTip(
                searchTerm: "Foodsharing Container retten Lebensmittelverschwendung Handel",
                why: "Was in Deutschland täglich aussortiert wird, ist schwer zu glauben, solange man es nicht gesehen hat. Zahlen wirken abstrakt, volle Container nicht."
            )))
    ]

    // MARK: - Getränk

    static let drinkEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .refuse, sdgs: [.responsibleConsumption, .cleanWater], encounter:
            .estimate(Estimate(
                question: "Wie viel teurer ist stilles Wasser aus der Flasche gegenüber Leitungswasser, grob geschätzt?",
                range: 1...500,
                answer: 200,
                unit: "mal",
                explanation: "Der Größenordnungssprung ist der Punkt, nicht die genaue Zahl. Dazu kommt der Transport von etwas, das fast überall in Deutschland in Trinkwasserqualität aus der Wand kommt – überwacht strenger als Mineralwasser.",
                sourceHint: "Preisvergleich Leitungswasser je Liter vs. Flaschenwasser; Überwachung nach Trinkwasserverordnung"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction, .decentWork], encounter:
            .story(Story(
                title: "Die Tasse und der weite Weg",
                paragraphs: [
                    "Kaffee wächst in den Tropen, wird geerntet, geschält, fermentiert, getrocknet, verschifft, geröstet, gemahlen.",
                    "Trotzdem ist der Transport über den Ozean der kleinste Posten in dieser Kette – Schiffe sind pro Kilo erstaunlich sparsam.",
                    "Der größte Posten sitzt am Anfang, im Anbau, und ein überraschend großer am Ende: in der Milch, wenn welche hineinkommt.",
                    "Eine Tasse schwarzer Kaffee ist ökologisch kaum der Rede wert. Ein großer Milchkaffee ist eine andere Größenordnung – und das liegt nicht am Kaffee."
                ],
                sourceHint: "Lebenszyklusanalyse Kaffee, Anteile Anbau, Transport, Zubereitung, Milch"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Kaffee zum Mitnehmen.",
                optionA: "Einwegbecher aus Pappe mit Beschichtung",
                optionB: "Eigener Becher, den du seit Jahren dabei hast",
                betterIsA: false,
                explanation: "Der eigene Becher gewinnt – aber nur, weil „seit Jahren“ dabei steht. Ein neu gekaufter Mehrwegbecher muss erst dutzende Male benutzt werden, bis er sich lohnt. Der beste Mehrwegbecher ist immer der, den man schon besitzt.",
                sourceHint: "Break-even-Punkt Mehrwegbecher gegenüber Einweg"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .quiz(Quiz(
                question: "Warum ist das Pfandsystem für PET-Flaschen so wirksam?",
                options: [
                    "Weil PET besonders wertvoll ist",
                    "Weil die Flaschen sortenrein und sauber zurückkommen",
                    "Weil das Pfand die Herstellung verteuert"
                ],
                correctIndex: 1,
                explanation: "Der Trick am Pfand ist nicht das Geld, sondern die Sortenreinheit: Was zurückkommt, ist ein einziger Kunststoff in bekannter Qualität, nicht vermischt. Genau daran scheitert Recycling sonst fast überall.",
                sourceHint: "Rücklaufquote Einwegpfand; Bedeutung sortenreiner Erfassung für Rezyklatqualität"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption], encounter:
            .fact(Fact(
                text: "Ein Sprudelgerät zu Hause ersetzt das Transportieren von Wasser über Straßen. Was gekauft und gefahren wird, ist am Ende nur noch das Gas – und das Gerät selbst hält Jahre.",
                sourceHint: "Ökobilanz Sprudelgerät vs. Mineralwasser in Mehrwegflaschen"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Trink heute einmal bewusst Leitungswasser statt eines gekauften Getränks und achte darauf, ob es dir wirklich fehlt.",
                hint: "Bei vielen fehlt nur die Gewohnheit, nicht der Geschmack. Bei manchen fehlt der Geschmack – auch das ist ein brauchbares Ergebnis."
            )))
    ]

    // MARK: - Tier

    static let animalEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.lifeOnLand], encounter:
            .story(Story(
                title: "Die Biomasse-Waage",
                paragraphs: [
                    "Wenn man alle Landsäugetiere der Erde wiegen könnte, würde man erwarten, dass die Wildtiere schwer ins Gewicht fallen. Elefanten, Wale, Herden in der Savanne.",
                    "Tatsächlich machen wilde Landsäugetiere nur einen kleinen Bruchteil aus.",
                    "Den weit überwiegenden Teil stellen Menschen und ihre Nutztiere – Rinder und Schweine vor allem.",
                    "Das ist vielleicht die stillste Zahl der Umweltdebatte. Sie erklärt Flächenverbrauch, Artenschwund und Ernährung in einem einzigen Bild."
                ],
                sourceHint: "Biomasseverteilung Landsäugetiere, Bar-On, Phillips & Milo"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.lifeOnLand, .sustainableCities], encounter:
            .quiz(Quiz(
                question: "Was hilft Insekten im Garten oder auf dem Balkon am meisten?",
                options: [
                    "Ein Insektenhotel aufstellen",
                    "Heimische Pflanzen und weniger mähen",
                    "Zuckerwasser bereitstellen"
                ],
                correctIndex: 1,
                explanation: "Insektenhotels helfen einigen wenigen Arten und sehen gut aus. Was wirklich fehlt, ist Nahrung und Struktur: heimische Blühpflanzen, ein Stück ungemähte Wiese, liegengebliebenes Laub. Nichtstun ist hier oft die wirksamste Maßnahme.",
                sourceHint: "Wirksamkeit von Nisthilfen vs. Nahrungsangebot für Wildbienen"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.lifeOnLand, .sustainableCities], encounter:
            .duel(Duel(
                question: "Was tötet in Deutschland mehr Vögel?",
                optionA: "Windkraftanlagen",
                optionB: "Glasscheiben an Gebäuden",
                betterIsA: false,
                explanation: "Scheiben mit großem Abstand – Vögel sehen Glas nicht, sie sehen die Spiegelung von Himmel und Bäumen. Windräder sind ein reales, aber deutlich kleineres Problem. Das ist ein gutes Beispiel dafür, wie Aufmerksamkeit und Größenordnung auseinanderfallen.",
                sourceHint: "Vogelschlag an Glasflächen vs. Windenergieanlagen, Schätzungen für Deutschland"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.lifeOnLand], encounter:
            .fact(Fact(
                text: "Ein Totholzhaufen in einer Gartenecke beherbergt mehr Arten als die meisten gepflanzten Beete – Käfer, Pilze, Igel, Vögel. Es ist der einzige Lebensraum, den man durch Liegenlassen erschafft."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.lifeOnLand], encounter:
            .mission(Mission(
                prompt: "Such dir ein Tier in deiner Umgebung – auch eine Fliege zählt – und beobachte es eine Minute lang, ohne etwas anderes zu tun.",
                hint: "Eine Minute ist länger, als sie klingt. Die meisten Menschen haben zuletzt als Kind ein Tier wirklich angeschaut."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.lifeOnLand, .lifeBelowWater], encounter:
            .video(VideoTip(
                searchTerm: "Wölfe Yellowstone trophische Kaskade Flüsse verändert",
                why: "Die bekannteste Geschichte darüber, wie ein einzelnes Tier ein ganzes Ökosystem umbaut. Sie wird gelegentlich zu stark vereinfacht erzählt – gerade deshalb lohnt es, beim Anschauen auf die Einwände zu achten."
            )))
    ]

    // MARK: - Pflanze

    static let plantEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.lifeOnLand, .climateAction], encounter:
            .fact(Fact(
                text: "Eine Pflanze baut sich zum größten Teil aus Luft. Das Material für Stamm, Blatt und Wurzel kommt überwiegend aus dem Kohlendioxid der Atmosphäre, nicht aus dem Boden – der liefert vor allem Wasser und Nährsalze.",
                sourceHint: "Herkunft der Trockenmasse von Pflanzen, Photosynthese"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.lifeOnLand, .sustainableCities], encounter:
            .duel(Duel(
                question: "Was ist für die Artenvielfalt besser?",
                optionA: "Ein gepflegter, kurz gemähter Rasen",
                optionB: "Eine Ecke, die man einfach wachsen lässt",
                betterIsA: false,
                explanation: "Ein kurzer Rasen ist ökologisch fast eine Wüste – wenige Arten, keine Blüten, kein Schutz. Die ungemähte Ecke kostet nichts, braucht keine Arbeit und ist die wirksamste Naturschutzmaßnahme, die auf einen Balkon passt.",
                sourceHint: "Artenvielfalt auf Rasenflächen vs. extensiv gepflegten Flächen"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.zeroHunger, .lifeOnLand], encounter:
            .mission(Mission(
                prompt: "Setz den Strunk einer Lauchzwiebel, eines Selleries oder eines Salats in ein Glas Wasser und schau eine Woche zu.",
                hint: "Vieles wächst nach. Es ersetzt keinen Einkauf, aber es macht auf sehr direkte Weise anschaulich, dass Lebensmittel lebendig waren."
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.lifeOnLand], encounter:
            .quiz(Quiz(
                question: "Torf in Blumenerde – was ist das Problem?",
                options: [
                    "Er ist teuer und knapp",
                    "Sein Abbau zerstört Moore, die viel Kohlenstoff speichern",
                    "Er enthält zu wenige Nährstoffe"
                ],
                correctIndex: 1,
                explanation: "Moore speichern auf kleiner Fläche außerordentlich viel Kohlenstoff. Wird Torf abgebaut, entweicht er. Torffreie Erde ist im Laden gleich nebenan zu finden und funktioniert – man muss nur auf die Packung schauen.",
                sourceHint: "Kohlenstoffspeicherung in Mooren; Torfabbau für Blumenerde"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.lifeOnLand], encounter:
            .ordering(Ordering(
                question: "Wie viel Kohlenstoff speichert das auf gleicher Fläche?",
                itemsInOrder: ["Rasen", "Acker", "Wald", "Moor"],
                lowLabel: "wenig",
                highLabel: "sehr viel",
                explanation: "Das Moor gewinnt, und zwar deutlich – es speichert im nassen Boden über Jahrtausende. Der Wald ist die bekanntere Antwort und trotzdem nur die zweitbeste. Ein trockengelegtes Moor wiederum wird vom Speicher zur Quelle.",
                sourceHint: "Kohlenstoffvorräte nach Landnutzungstyp, Moore vs. Wald"
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.lifeOnLand], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei verschiedene Pflanzen.",
                theme: .plant,
                count: 2,
                seconds: 90,
                reward: "Topfpflanze, Unkraut im Pflaster, Baum am Straßenrand – Pflanzen sind der Werkstoff, der sich selbst herstellt."
            )))
    ]

    // MARK: - Landschaft

    static let landscapeEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction, .lifeOnLand], encounter:
            .story(Story(
                title: "Der Boden unter allem",
                paragraphs: [
                    "Fruchtbarer Boden sieht aus wie Dreck. Tatsächlich ist er ein Bauwerk aus Mineralien, Wasser, Luft und Milliarden Lebewesen.",
                    "Damit ein Zentimeter davon entsteht, vergehen je nach Bedingungen Jahrzehnte bis Jahrhunderte.",
                    "Abgetragen ist derselbe Zentimeter in einem einzigen starken Regen, wenn nichts darauf wächst und ihn festhält.",
                    "Boden ist damit im menschlichen Zeitmaßstab keine erneuerbare Ressource. Er ist eine, die man nur erhalten oder verlieren kann."
                ],
                sourceHint: "Bodenbildungsraten vs. Erosionsraten, Größenordnungen"
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.sustainableCities, .climateAction], encounter:
            .fact(Fact(
                text: "Eine versiegelte Fläche kann kein Wasser aufnehmen, keine Wärme abgeben und nichts wachsen lassen. In Deutschland kommt täglich weiter Fläche hinzu – der Fachbegriff dafür ist Flächenverbrauch, und er beschreibt eine der wenigen Umweltgrößen, die sich praktisch nicht rückgängig machen lässt.",
                sourceHint: "Tägliche Flächenneuinanspruchnahme in Deutschland, Zielwerte"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.climateAction], encounter:
            .ordering(Ordering(
                question: "Wie schnell reagiert das jeweils auf Erwärmung?",
                itemsInOrder: ["Meereis", "Gletscher", "Grönländischer Eisschild", "Tiefer Ozean"],
                lowLabel: "schnell",
                highLabel: "sehr langsam",
                explanation: "Die Trägheit ist das Unheimliche am Klimasystem: Die schnellen Teile sieht man sofort, die langsamen reagieren noch Jahrhunderte auf das, was heute passiert. Deshalb sagt eine Momentaufnahme wenig über das, was schon festgelegt ist.",
                sourceHint: "Reaktionszeiten von Klimasystemkomponenten, Trägheit des Ozeans"
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.climateAction, .goodHealth], encounter:
            .mission(Mission(
                prompt: "Geh nach draußen und such die nächste unversiegelte Fläche – Wiese, Beet, Waldboden – und fass sie einmal an.",
                hint: "In Innenstädten kann das überraschend weit sein. Diese Entfernung ist selbst schon die Antwort."
            ))),

        ThemedEncounter(strategy: .recover, sdgs: [.climateAction, .sustainableCities], encounter:
            .duel(Duel(
                question: "Was kühlt eine Stadt im Sommer stärker?",
                optionA: "Helle Dächer und Fassaden",
                optionB: "Große alte Bäume",
                betterIsA: false,
                explanation: "Bäume kühlen doppelt: Sie beschatten und sie verdunsten Wasser, was der Luft Wärme entzieht. Helle Flächen reflektieren nur. Ein alter Baum ist eine Klimaanlage, die niemand einschalten muss – und die durch keinen neu gepflanzten Setzling schnell zu ersetzen ist.",
                sourceHint: "Kühlleistung von Stadtbäumen durch Verdunstung vs. Albedoeffekte"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.climateAction], encounter:
            .video(VideoTip(
                searchTerm: "Kipppunkte Klimasystem erklärt AMOC Permafrost",
                why: "Der Unterschied zwischen allmählicher Veränderung und einem System, das umkippt, ist der Kern der Klimadebatte – und wird selten so erklärt, dass man ihn behält."
            )))
    ]

    // MARK: - Sport

    static let sportEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .rethink, sdgs: [.goodHealth, .sustainableCities], encounter:
            .fact(Fact(
                text: "Bewegung ist die einzige Gesundheitsmaßnahme, die nebenbei Verkehr ersetzt. Wer den Weg zur Arbeit zum Sport macht, spart zweimal – die Fahrt und die Fahrt zum Fitnessstudio."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .duel(Duel(
                question: "Neue Sportart ausprobieren.",
                optionA: "Ausrüstung gebraucht kaufen oder leihen",
                optionB: "Gleich richtig ausstatten, dann bleibt man dabei",
                betterIsA: true,
                explanation: "Die meisten neuen Sportarten werden nicht lange betrieben – das ist keine Charakterschwäche, sondern Statistik. Gebrauchte Ausrüstung macht das Ausprobieren billig und folgenlos. Wer dabei bleibt, kann immer noch aufrüsten.",
                sourceHint: "Abbruchquoten bei neu begonnenen Sportarten; Gebrauchtmarkt Sportausrüstung"
            ))),

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Prüf ein Sportgerät in deiner Nähe auf die Kleinigkeit, die es unbrauchbar macht – Luft, Schnürsenkel, lose Schraube.",
                hint: "Sportgeräte landen selten wegen Verschleiß in der Ecke. Sie landen dort, weil eine Kleinigkeit nie erledigt wurde."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption, .lifeBelowWater], encounter:
            .quiz(Quiz(
                question: "Kunstrasenplätze standen wegen eines bestimmten Problems in der Kritik. Welches?",
                options: [
                    "Der Wasserverbrauch",
                    "Das Granulat als Mikroplastikquelle",
                    "Die Beleuchtung"
                ],
                correctIndex: 1,
                explanation: "Das eingestreute Kunststoffgranulat wird über Schuhe, Wind und Regen ausgetragen und zählte zu den größeren vermeidbaren Mikroplastikquellen. Inzwischen wird es EU-weit beschränkt – ein Beispiel dafür, dass sich solche Quellen tatsächlich abstellen lassen.",
                sourceHint: "EU-Beschränkung für Kunststoffgranulat auf Sportplätzen, REACH"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.climateAction], encounter:
            .ordering(Ordering(
                question: "Was macht bei einem Skiwochenende den größten Anteil aus?",
                itemsInOrder: ["Die Ausrüstung", "Die Beschneiung", "Der Liftbetrieb", "Die Anreise"],
                lowLabel: "klein",
                highLabel: "größter Anteil",
                explanation: "Die Anreise dominiert fast immer – und zwar so deutlich, dass die Wahl des Verkehrsmittels mehr entscheidet als die Wahl des Skigebiets. Das gilt für die meisten Freizeitaktivitäten: Nicht die Aktivität zählt, sondern der Weg dorthin.",
                sourceHint: "Anteile am Fußabdruck eines Skiurlaubs, Anreise vs. Betrieb"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.goodHealth], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei Dinge, mit denen man sich bewegen kann.",
                theme: .sport,
                count: 2,
                seconds: 90,
                reward: "Ball, Fahrrad, Turnschuh, Treppe – die meisten Sportgeräte sind billiger als ihr Ruf."
            )))
    ]

    // MARK: - Instrument

    static let instrumentEncounters: [ThemedEncounter] = [
        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption, .qualityEducation], encounter:
            .fact(Fact(
                text: "Ein Musikinstrument ist eines der wenigen Dinge, die mit dem Alter besser werden können – und für die es eine Handwerksbranche gibt, die ausschließlich vom Erhalten lebt. Instrumentenbauer sind Reparaturberufe, die nie aus der Mode kamen."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.qualityEducation, .responsibleConsumption], encounter:
            .duel(Duel(
                question: "Kind will ein Instrument lernen.",
                optionA: "Instrument mieten",
                optionB: "Günstiges Einsteigerinstrument kaufen",
                betterIsA: true,
                explanation: "Mieten löst zwei Probleme auf einmal: Man bekommt ein gut eingestelltes Instrument statt eines billigen, das den Spaß verdirbt – und wenn es doch nichts wird, bleibt nichts übrig. Viele Musikhäuser rechnen die Miete beim späteren Kauf an.",
                sourceHint: "Mietmodelle im Musikalienhandel, Anrechnung auf den Kaufpreis"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.lifeOnLand], encounter:
            .story(Story(
                title: "Das Holz, das singt",
                paragraphs: [
                    "Für Instrumente wird seit Jahrhunderten bestimmtes Holz gesucht: langsam gewachsen, gleichmäßig, dicht.",
                    "Solches Holz wächst in kalten, kargen Lagen und braucht viele Jahrzehnte. Ersetzen lässt es sich nicht beliebig.",
                    "Einige Arten, vor allem Tropenhölzer für Griffbretter und Blasinstrumente, sind inzwischen im Handel geschützt.",
                    "Der Instrumentenbau ist damit ein Vorbote: eine Branche, die früher als andere lernen musste, mit einem Material zu arbeiten, das nicht nachbestellbar ist."
                ],
                sourceHint: "CITES-Schutz für Tonhölzer, betroffene Arten"
            ))),

        ThemedEncounter(strategy: .refurbish, sdgs: [.responsibleConsumption], encounter:
            .mission(Mission(
                prompt: "Finde ein Instrument, das bei dir oder jemandem im Umfeld ungenutzt steht, und finde heraus, was es bräuchte, um wieder spielbar zu sein.",
                hint: "Saiten, eine Reinigung, eine neue Einstellung. In sehr vielen Haushalten steht eine Gitarre, der eine Stunde Arbeit fehlt."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.qualityEducation], encounter:
            .quiz(Quiz(
                question: "Warum halten gut gebaute Instrumente oft Generationen?",
                options: [
                    "Weil sie kaum benutzt werden",
                    "Weil sie zerlegbar und aus reparierbaren Materialien gebaut sind",
                    "Weil sie besonders robust konstruiert sind"
                ],
                correctIndex: 1,
                explanation: "Geigen sind mit Leim gebaut, der sich wieder lösen lässt – ausdrücklich, damit man sie öffnen kann. Robust sind sie überhaupt nicht. Sie sind reparierbar, und das ist etwas völlig anderes.",
                sourceHint: "Verwendung von Hautleim im Geigenbau, Reversibilität"
            ))),

        ThemedEncounter(strategy: .repurpose, sdgs: [.qualityEducation], encounter:
            .video(VideoTip(
                searchTerm: "Instrumente aus Müll gebaut Recycled Orchestra Cateura",
                why: "Ein Orchester, dessen Instrumente aus Abfall einer Mülldeponie gebaut wurden. Es ist der seltene Fall, in dem Umwidmen nicht als Notlösung wirkt, sondern als Antwort."
            )))
    ]
}
