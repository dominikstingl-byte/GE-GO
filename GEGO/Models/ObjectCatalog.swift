import Foundation

/// Ein Gegenstand, den die Kamera erkennen kann, mit allem was das Spiel
/// darüber weiß.
struct CatalogEntry: Identifiable {
    /// Bezeichner aus der Vision-Taxonomie des iPhones. Muss exakt stimmen,
    /// sonst wird der Eintrag nie gefunden.
    let label: String
    let name: String
    let strategy: RStrategy
    let sdgs: [SDG]
    let encounters: [Encounter]

    var id: String { label }

    /// Welche Begegnung dran ist. Wechselt mit der Anzahl der bisherigen Funde
    /// durch, damit derselbe Gegenstand beim zweiten Mal etwas Neues erzählt.
    ///
    /// `avoiding` ist die Art, die gerade eben dran war – bei 19 Fakten
    /// gegenüber 6 Schätzfragen im Katalog käme sonst ständig zweimal
    /// hintereinander dasselbe Format. Gibt es keine Alternative, gewinnt der
    /// reguläre Zug: lieber wiederholen als gar nichts zeigen.
    func encounter(forVisit visit: Int, avoiding lastKind: String? = nil) -> Encounter {
        let start = visit % encounters.count
        for offset in 0..<encounters.count {
            let candidate = encounters[(start + offset) % encounters.count]
            if candidate.kindLabel != lastKind { return candidate }
        }
        return encounters[start]
    }
}

/// Alle Gegenstände, zu denen das Spiel etwas zu sagen hat.
///
/// Die Bezeichner stammen aus der eingebauten Erkennung des iPhones und sind
/// gegen die tatsächliche Liste geprüft. Wer hier etwas ergänzt, muss den
/// Bezeichner erst mit `Tools/taxonomie.swift` nachschlagen – erfundene
/// Bezeichner tauchen im Spiel einfach nie auf.
///
/// **Zum Stand der Inhalte:** Alle Texte hier sind Entwürfe. Wo `sourceHint`
/// gesetzt ist, steht eine Zahl oder eine Aussage im Text, die vor jedem
/// echten Einsatz an der genannten Stelle nachzuschlagen ist. Das Feld ist
/// ausdrücklich keine Quellenangabe, sondern ein Merkzettel.
enum ObjectCatalog {

    static let all: [CatalogEntry] = [

        // MARK: - R0 Verweigern

        CatalogEntry(
            label: "bottle",
            name: "Flasche",
            strategy: .refuse,
            sdgs: [.responsibleConsumption, .cleanWater],
            encounters: [
                .quiz(Quiz(
                    question: "Du hast Durst und stehst vor dem Regal. Was ist ökologisch am günstigsten?",
                    options: [
                        "Einwegflasche aus Plastik",
                        "Mehrwegflasche aus Glas",
                        "Leitungswasser in der eigenen Flasche"
                    ],
                    correctIndex: 2,
                    explanation: "Kein Transport, keine Verpackung, keine Reinigung im Werk. Die beste Flasche ist die, die du schon hast.",
                    sourceHint: "Umweltbundesamt, Vergleich Getränkeverpackungen"
                )),
                .story(Story(
                    title: "Die Flasche, die zweimal fährt",
                    paragraphs: [
                        "Mehrweg gilt als die gute Wahl. Stimmt auch – aber nicht immer, und der Grund ist überraschend banal.",
                        "Eine Mehrwegflasche muss zurück. Zum Händler, zum Abfüller, gereinigt, wieder befüllt. Jede dieser Fahrten kostet Diesel.",
                        "Solange der Abfüller in der Nähe ist, ist das kein Problem. Kommt das Wasser aber von weit her, kann die Mehrwegflasche ihren Vorsprung auf der Autobahn wieder verlieren.",
                        "Deshalb ist die entscheidende Frage bei Mehrweg nicht „aus welchem Material“, sondern „wie weit“. Regional abgefüllt schlägt Mehrweg von weit her."
                    ],
                    sourceHint: "Umweltbundesamt, Ökobilanzen Getränkeverpackungen"
                )),
                .mission(Mission(
                    prompt: "Finde heraus, wo hier in der Nähe die nächste Stelle ist, an der du kostenlos Wasser nachfüllen kannst.",
                    hint: "Viele Städte haben öffentliche Brunnen oder Cafés, die mitmachen."
                ))
            ]
        ),

        CatalogEntry(
            label: "paper_bag",
            name: "Papiertüte",
            strategy: .refuse,
            sdgs: [.responsibleConsumption, .lifeOnLand],
            encounters: [
                .quiz(Quiz(
                    question: "Papiertüte statt Plastiktüte – immer die bessere Wahl?",
                    options: ["Ja, Papier ist ja aus Holz", "Nein, nicht zwingend", "Nur wenn sie recycelt ist"],
                    correctIndex: 1,
                    explanation: "Papiertüten brauchen in der Herstellung mehr Energie und Wasser als Plastiktüten und reißen schneller. Sie lohnen sich erst nach mehreren Einsätzen. Der eigene Beutel schlägt beide.",
                    sourceHint: "Umweltbundesamt, Tragetaschen im Vergleich"
                )),
                .fact(Fact(
                    text: "Die umweltfreundlichste Tüte ist die, die du nicht brauchst, weil du schon einen Beutel dabei hast."
                ))
            ]
        ),

        CatalogEntry(
            label: "straw_drinking",
            name: "Trinkhalm",
            strategy: .refuse,
            sdgs: [.lifeBelowWater, .responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Ein Trinkhalm wird im Schnitt wenige Minuten benutzt. Für diese Minuten wird ein Gegenstand hergestellt, verpackt, um die halbe Welt gefahren und entsorgt."
                )),
                .story(Story(
                    title: "Warum ausgerechnet der Strohhalm?",
                    paragraphs: [
                        "Trinkhalme machen einen winzigen Anteil des Plastikmülls im Meer aus. Trotzdem wurden ausgerechnet sie verboten. Warum?",
                        "Weil sie sichtbar sind. Ein Video einer Meeresschildkröte mit einem Halm in der Nase ging 2015 um die Welt und hat mehr bewegt als jede Statistik davor.",
                        "Das ist die unbequeme Erkenntnis: Was Menschen zum Handeln bringt, ist selten das, was am meisten wiegt, sondern das, was man sich vorstellen kann.",
                        "Man kann das billig finden. Man kann es aber auch nutzen – und die Aufmerksamkeit von dort weiterleiten, wo die wirklich großen Mengen liegen: Fischernetze, Verpackungen, Reifenabrieb."
                    ],
                    sourceHint: "Zusammensetzung Meeresmüll – Anteil Fischereigerät prüfen"
                )),
                .mission(Mission(
                    prompt: "Bestell dir das nächste Getränk bewusst ohne Halm.",
                    hint: "Ein Satz reicht: „Ohne Strohhalm, bitte.“"
                ))
            ]
        ),

        // MARK: - R1 Umdenken

        CatalogEntry(
            label: "bicycle",
            name: "Fahrrad",
            strategy: .rethink,
            sdgs: [.sustainableCities, .climateAction, .goodHealth],
            encounters: [
                .quiz(Quiz(
                    question: "Wie lang ist in Deutschland eine durchschnittliche Autofahrt?",
                    options: ["Unter 10 Kilometer", "Etwa 30 Kilometer", "Über 50 Kilometer"],
                    correctIndex: 0,
                    explanation: "Die meisten Autofahrten sind kurz – Strecken, die mit dem Rad gut zu schaffen wären. Genau da liegt der größte ungenutzte Hebel.",
                    sourceHint: "Studie „Mobilität in Deutschland“, mittlere Wegelänge"
                )),
                .fact(Fact(
                    text: "Ein Fahrrad braucht in der Herstellung einen Bruchteil des Materials eines Autos und im Betrieb nichts außer dir."
                ))
            ]
        ),

        CatalogEntry(
            label: "car",
            name: "Auto",
            strategy: .rethink,
            sdgs: [.sustainableCities, .climateAction],
            encounters: [
                .estimate(Estimate(
                    question: "Wie viel Prozent seiner Zeit steht ein privates Auto ungenutzt herum?",
                    range: 0...100,
                    answer: 95,
                    unit: "Prozent",
                    explanation: "Ein Auto ist fast immer geparkt. Es ist der teuerste Gegenstand, den die meisten Menschen besitzen – und der am wenigsten benutzte.",
                    sourceHint: "Kraftfahrt-Bundesamt / Mobilitätsstudien, Standzeit Pkw"
                )),
                .story(Story(
                    title: "Das teuerste Möbelstück",
                    paragraphs: [
                        "Stell dir vor, du kaufst einen Stuhl für dreißigtausend Euro. Du benutzt ihn eine Stunde am Tag. Die übrigen dreiundzwanzig steht er auf der Straße und du zahlst Miete für seinen Platz.",
                        "Genau das ist ein Auto. Nur fällt es niemandem auf, weil es alle so machen.",
                        "In einer Stadt beansprucht jedes parkende Auto ungefähr so viel Fläche wie ein kleines Zimmer. Multipliziert mit allen Autos einer Straße ergibt das eine Wohnfläche, die niemand bewohnt.",
                        "Umdenken heißt hier nicht: schlechtes Gewissen beim Fahren. Es heißt: die Frage ändern. Nicht „welches Auto kaufe ich“, sondern „brauche ich eins, oder brauche ich Fahrten“."
                    ]
                )),
                .video(VideoTip(
                    searchTerm: "induzierter Verkehr warum mehr Straßen mehr Stau",
                    why: "Neue Fahrspuren lösen Stau nicht auf, sie erzeugen neuen Verkehr. Der Effekt heißt induzierte Nachfrage und ist eines der schönsten Beispiele für ein System, das sich gegen die naheliegende Lösung wehrt."
                ))
            ]
        ),

        CatalogEntry(
            label: "power_saw",
            name: "Säge",
            strategy: .rethink,
            sdgs: [.responsibleConsumption, .partnerships],
            encounters: [
                .fact(Fact(
                    text: "Eine Bohrmaschine wird in ihrem ganzen Leben nur wenige Minuten benutzt. Werkzeug ist das Musterbeispiel für etwas, das man teilen statt besitzen kann.",
                    sourceHint: "Oft zitierte Zahl „13 Minuten“ – Ursprung prüfen"
                )),
                .mission(Mission(
                    prompt: "Such nach einer Werkzeugbibliothek oder einem Repair-Café in deiner Nähe.",
                    hint: "Viele Städte haben inzwischen eine – oft an eine Bibliothek angeschlossen."
                ))
            ]
        ),

        CatalogEntry(
            label: "solar_panel",
            name: "Solarmodul",
            strategy: .rethink,
            sdgs: [.affordableEnergy, .climateAction],
            encounters: [
                .estimate(Estimate(
                    question: "Wie lange braucht ein Solarmodul in Deutschland, bis es die Energie seiner Herstellung wieder eingespielt hat?",
                    range: 0...15,
                    answer: 1.5,
                    unit: "Jahre",
                    tolerance: 0.15,
                    explanation: "Deutlich kürzer, als die meisten schätzen – und das Modul läuft danach noch Jahrzehnte. Der Fachbegriff dafür ist energetische Amortisation.",
                    sourceHint: "Fraunhofer ISE, Photovoltaics Report"
                )),
                .quiz(Quiz(
                    question: "Was passiert mit Solarmodulen am Ende ihrer Laufzeit?",
                    options: [
                        "Sie werden zu Sondermüll",
                        "Glas und Aluminium werden zurückgewonnen",
                        "Sie bleiben einfach auf dem Dach"
                    ],
                    correctIndex: 1,
                    explanation: "Der größte Teil eines Moduls ist Glas und Aluminium und wird verwertet. Schwieriger sind die dünnen Schichten aus Silizium und Metallen – daran wird gearbeitet."
                ))
            ]
        ),

        CatalogEntry(
            label: "wind_turbine",
            name: "Windrad",
            strategy: .rethink,
            sdgs: [.affordableEnergy, .climateAction, .industryInnovation],
            encounters: [
                .story(Story(
                    title: "Das Problem sind die Flügel",
                    paragraphs: [
                        "Ein Windrad ist fast vollständig verwertbar. Turm aus Stahl, Fundament aus Beton, Generator aus Kupfer und Magneten – alles bekannte Wege.",
                        "Bis auf die Rotorblätter. Die bestehen aus Glas- oder Kohlefasern, eingegossen in Kunstharz. Genau diese Verbindung macht sie leicht und stabil.",
                        "Und genau sie macht sie fast untrennbar. Man kann sie schreddern und als Füllstoff verwenden, aber die Fasern selbst zurückzugewinnen ist bisher teurer, als neue herzustellen.",
                        "Das ist die allgemeine Regel hinter dem Einzelfall: Was gut verbunden ist, ist schwer zu trennen. Jeder Verbundwerkstoff kauft seine Leistung mit einem schwierigen Lebensende."
                    ],
                    sourceHint: "Stand Rotorblatt-Recycling – aktuelle Verfahren prüfen"
                ))
            ]
        ),

        // MARK: - R2 Verringern

        CatalogEntry(
            label: "light_bulb",
            name: "Glühbirne",
            strategy: .reduce,
            sdgs: [.affordableEnergy, .climateAction],
            encounters: [
                .quiz(Quiz(
                    question: "Eine LED verbraucht für dieselbe Helligkeit im Vergleich zur alten Glühlampe ungefähr",
                    options: ["die Hälfte", "ein Viertel", "ein Zehntel"],
                    correctIndex: 2,
                    explanation: "Die alte Glühlampe gab den größten Teil der Energie als Wärme ab, nicht als Licht. Sie war streng genommen eine kleine Heizung, die nebenbei leuchtete."
                )),
                .story(Story(
                    title: "Die Glühbirne, die seit 1901 brennt",
                    paragraphs: [
                        "In einer Feuerwache in Livermore, Kalifornien, hängt eine Glühbirne, die seit über hundert Jahren fast ununterbrochen leuchtet.",
                        "Sie ist kein Wunder. Sie brennt mit wenigen Watt, sehr schwach, und wurde kaum je aus- und wieder eingeschaltet – das Ein- und Ausschalten tötet Glühfäden, nicht das Brennen.",
                        "Trotzdem stellt sie eine unbequeme Frage: Man kann Dinge bauen, die halten. Es ist eine Entscheidung, keine Naturgesetzlichkeit.",
                        "Die Gegenfrage ist genauso wichtig: Diese Lampe verbraucht für ihr bisschen Licht ein Vielfaches einer LED. Lange halten und wenig verbrauchen sind zwei verschiedene Tugenden, und sie widersprechen sich manchmal."
                    ]
                )),
                .video(VideoTip(
                    searchTerm: "Glühbirnenkartell Phoebus geplante Obsoleszenz",
                    why: "1924 verabredeten die großen Hersteller, die Lebensdauer von Glühbirnen auf 1000 Stunden zu begrenzen. Das ist kein Verschwörungsgerücht, sondern aktenkundig – und der Ursprung des Begriffs geplante Obsoleszenz."
                ))
            ]
        ),

        CatalogEntry(
            label: "shower",
            name: "Dusche",
            strategy: .reduce,
            sdgs: [.cleanWater, .affordableEnergy],
            encounters: [
                .estimate(Estimate(
                    question: "Wie viele Liter laufen pro Minute aus einer normalen Dusche?",
                    range: 0...30,
                    answer: 12,
                    unit: "Liter",
                    explanation: "Ein Sparduschkopf kommt mit der Hälfte aus, ohne dass es sich schwächer anfühlt – er mischt Luft bei. Das ist die seltene Maßnahme, die nichts kostet und nichts einschränkt.",
                    sourceHint: "Umweltbundesamt, Wasserverbrauch im Haushalt"
                )),
                .fact(Fact(
                    text: "Beim Duschen ist nicht das Wasser das Teure, sondern die Energie, es zu erwärmen. Wer kürzer duscht, spart vor allem Heizung."
                )),
                .mission(Mission(
                    prompt: "Miss beim nächsten Duschen die Zeit. Nur messen, nichts ändern.",
                    hint: "Wissen kommt vor Verändern. Die Zahl überrascht die meisten."
                ))
            ]
        ),

        CatalogEntry(
            label: "refrigerator",
            name: "Kühlschrank",
            strategy: .reduce,
            sdgs: [.affordableEnergy, .zeroHunger],
            encounters: [
                .quiz(Quiz(
                    question: "Der Kühlschrank läuft rund um die Uhr. Was senkt seinen Verbrauch am meisten?",
                    options: [
                        "Ihn voller einräumen",
                        "Ein Grad wärmer einstellen",
                        "Eisschicht entfernen und Wärmequellen wegräumen"
                    ],
                    correctIndex: 2,
                    explanation: "Eine Eisschicht wirkt wie eine Dämmung an der falschen Stelle, und ein Herd direkt daneben heizt gegen die Kühlung an. Sieben Grad reichen im Kühlteil.",
                    sourceHint: "Verbraucherzentrale, Stromverbrauch Kühlgeräte"
                ))
            ]
        ),

        CatalogEntry(
            label: "laundry_machine",
            name: "Waschmaschine",
            strategy: .reduce,
            sdgs: [.affordableEnergy, .cleanWater],
            encounters: [
                .fact(Fact(
                    text: "Der größte Teil des Stroms beim Waschen geht ins Aufheizen des Wassers. Dreißig statt sechzig Grad senkt den Verbrauch deutlich – und reicht für normal getragene Kleidung.",
                    sourceHint: "Verbraucherzentrale, Waschtemperatur und Stromverbrauch"
                )),
                .story(Story(
                    title: "Was beim Waschen ins Meer geht",
                    paragraphs: [
                        "Kleidung aus Polyester, Fleece und Sportstoffen verliert bei jedem Waschgang winzige Fasern. Kunststofffasern, dünner als ein Haar.",
                        "Die Kläranlage hält den größten Teil zurück, aber nicht alles. Was durchkommt, landet im Fluss und irgendwann im Meer.",
                        "Das Unangenehme daran: Es gibt keinen Hersteller, den man dafür belangen kann, und keinen Moment, in dem man sich falsch entscheidet. Es passiert einfach beim Waschen.",
                        "Was hilft: volle Trommeln, kühler waschen, weniger schleudern – und beim Kauf auf Naturfasern achten, wo es geht. Kleine Hebel, aber es sind die einzigen an dieser Stelle."
                    ],
                    sourceHint: "Mikrofasern aus Textilwäsche – Rückhaltequote Kläranlagen prüfen"
                ))
            ]
        ),

        // MARK: - R3 Weiternutzen

        CatalogEntry(
            label: "jar",
            name: "Schraubglas",
            strategy: .reuse,
            sdgs: [.responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Ein Schraubglas ist fertig gebaut, dicht und hitzefest. Es ein zweites Mal zu benutzen kostet nichts. Es einzuschmelzen kostet etwa 1500 Grad.",
                    sourceHint: "Schmelztemperatur Behälterglas"
                )),
                .mission(Mission(
                    prompt: "Finde in deiner Küche ein Glas, das gerade als Vorratsdose arbeitet, statt im Altglas zu liegen.",
                    hint: "Falls keins da ist: das nächste leere behalten."
                ))
            ]
        ),

        CatalogEntry(
            label: "clothing",
            name: "Kleidung",
            strategy: .reuse,
            sdgs: [.responsibleConsumption, .decentWork, .cleanWater],
            encounters: [
                .quiz(Quiz(
                    question: "Was verlängert das Leben eines Kleidungsstücks am wirksamsten?",
                    options: ["Es öfter waschen", "Es seltener und kühler waschen", "Es nur chemisch reinigen lassen"],
                    correctIndex: 1,
                    explanation: "Waschen ist nach dem Tragen der größte Verschleißfaktor. Lüften statt waschen klingt banal, verlängert die Lebensdauer aber erheblich."
                )),
                .story(Story(
                    title: "Die zweite Reise der Altkleider",
                    paragraphs: [
                        "Du wirfst einen Pullover in den Altkleidercontainer. Er ist noch gut. Du stellst dir vor, dass ihn jemand bekommt, der ihn braucht.",
                        "Ein Teil davon stimmt. Ein anderer Teil geht in den Export, vor allem nach Ostafrika und Osteuropa, und wird dort verkauft – ein eigener Wirtschaftszweig mit Händlern und Märkten.",
                        "Und ein dritter Teil ist von vornherein unverkäuflich: zu billig produziert, zu abgetragen, zu speziell. Der landet am Ziel auf einer Deponie, die das Land nicht bestellt hat.",
                        "Das macht Altkleidersammlung nicht schlecht. Aber es verschiebt die Verantwortung: Die entscheidende Frage ist nicht, wohin ein Stück am Ende geht, sondern wie viele Stücke überhaupt gekauft werden."
                    ],
                    sourceHint: "Altkleiderexporte, Anteil unverwertbar – Zahlen prüfen"
                )),
                .video(VideoTip(
                    searchTerm: "Fast Fashion Atacama Wüste Kleiderberg",
                    why: "In der Atacama-Wüste in Chile liegt ein Berg aus unverkaufter Kleidung, groß genug, um ihn aus dem Weltraum zu sehen. Bilder, die man nicht mehr loswird."
                ))
            ]
        ),

        CatalogEntry(
            label: "book",
            name: "Buch",
            strategy: .reuse,
            sdgs: [.qualityEducation, .responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Ein Buch kann Dutzende Leser haben, ohne sich abzunutzen. Bibliotheken sind Kreislaufwirtschaft, seit es sie gibt – nur nennt sie niemand so."
                ))
            ]
        ),

        CatalogEntry(
            label: "cup",
            name: "Becher",
            strategy: .reuse,
            sdgs: [.responsibleConsumption],
            encounters: [
                .quiz(Quiz(
                    question: "Ab wie vielen Nutzungen schlägt ein Mehrwegbecher den Einwegbecher in der Ökobilanz?",
                    options: ["Ab der ersten", "Nach etwa zehn bis zwanzig", "Nach über hundert"],
                    correctIndex: 1,
                    explanation: "Ein Mehrwegbecher kostet in der Herstellung mehr. Der Vorsprung kommt erst durch Wiederholung – und dann deutlich. Ein Becher, der zu Hause im Schrank steht, hilft nicht.",
                    sourceHint: "Ökobilanz Mehrwegbecher, Break-even-Zahl prüfen"
                ))
            ]
        ),

        // MARK: - R4 Reparieren

        CatalogEntry(
            label: "toolbox",
            name: "Werkzeugkasten",
            strategy: .repair,
            sdgs: [.responsibleConsumption, .industryInnovation],
            encounters: [
                .fact(Fact(
                    text: "Reparieren ist die Stufe, auf der das Ding dasselbe bleibt. Nichts wird neu hergestellt, nichts eingeschmolzen – nur ein Fehler behoben."
                )),
                .mission(Mission(
                    prompt: "Denk an einen Gegenstand bei dir zu Hause, der kaputt ist und wartet. Nimm dir vor, ihn diese Woche anzuschauen.",
                    hint: "Anschauen reicht. Oft ist es weniger, als man befürchtet."
                ))
            ]
        ),

        CatalogEntry(
            label: "screwdriver",
            name: "Schraubendreher",
            strategy: .repair,
            sdgs: [.responsibleConsumption, .industryInnovation],
            encounters: [
                .quiz(Quiz(
                    question: "Was macht ein Gerät reparierbar?",
                    options: [
                        "Dass es billig war",
                        "Schrauben statt Klebstoff und erhältliche Ersatzteile",
                        "Dass es aus Metall ist"
                    ],
                    correctIndex: 1,
                    explanation: "Verklebte Gehäuse und fehlende Ersatzteile machen Reparatur unmöglich, egal wie geschickt man ist. Genau deshalb gibt es inzwischen Regeln zum Recht auf Reparatur.",
                    sourceHint: "EU-Richtlinie Recht auf Reparatur, aktueller Stand"
                )),
                .story(Story(
                    title: "Die Schraube, die es nicht im Laden gibt",
                    paragraphs: [
                        "Es gibt Schrauben mit fünf Zacken. Mit einem Stift in der Mitte. Mit einem Profil, das aussieht wie eine Blume.",
                        "Für fast keine davon gibt es einen technischen Grund. Ein Kreuzschlitz hält genauso gut.",
                        "Der Grund ist ein anderer: Wer den Schraubendreher nicht hat, macht das Gerät nicht auf. Und wer es nicht aufmacht, repariert es nicht.",
                        "Inzwischen gibt es die Bits im Set für ein paar Euro. Das ist die stille Gegenbewegung: Sobald ein Hindernis bekannt ist, wird es billig zu umgehen."
                    ]
                ))
            ]
        ),

        CatalogEntry(
            label: "shoes",
            name: "Schuhe",
            strategy: .repair,
            sdgs: [.responsibleConsumption, .decentWork],
            encounters: [
                .fact(Fact(
                    text: "Ein besohlbarer Schuh kann Jahrzehnte halten. Ein verklebter ist nach der ersten durchgelaufenen Sohle Abfall. Dieselbe Funktion, ein völlig anderes Lebensende."
                ))
            ]
        ),

        CatalogEntry(
            label: "sewing",
            name: "Nähzeug",
            strategy: .repair,
            sdgs: [.responsibleConsumption, .qualityEducation],
            encounters: [
                .mission(Mission(
                    prompt: "Finde heraus, ob jemand in deinem Umfeld einen Knopf annähen kann – oder ob du es selbst kannst.",
                    hint: "Es ist eine Fähigkeit, die eine Generation zurück noch selbstverständlich war."
                ))
            ]
        ),

        // MARK: - R5 Aufarbeiten

        CatalogEntry(
            label: "laptop",
            name: "Laptop",
            strategy: .refurbish,
            sdgs: [.responsibleConsumption, .industryInnovation, .climateAction],
            encounters: [
                .quiz(Quiz(
                    question: "Wo entsteht der größte Teil der Umweltlast eines Laptops?",
                    options: ["Beim Stromverbrauch im Betrieb", "In der Herstellung", "Bei der Entsorgung"],
                    correctIndex: 1,
                    explanation: "Chips, Metalle und Montage machen den Löwenanteil aus. Deshalb ist ein Gerät länger zu nutzen wirksamer als jedes Stromsparen – und ein gebrauchtes schlägt fast jedes neue.",
                    sourceHint: "Öko-Institut, Lebenszyklusanalyse Notebooks"
                )),
                .fact(Fact(
                    text: "„Refurbished“ heißt: geprüft, überholt, mit Garantie. Das ist etwas anderes als gebraucht vom Flohmarkt – und der Unterschied steht im Kaufvertrag."
                ))
            ]
        ),

        CatalogEntry(
            label: "phone",
            name: "Telefon",
            strategy: .refurbish,
            sdgs: [.responsibleConsumption, .decentWork, .peaceJustice],
            encounters: [
                .estimate(Estimate(
                    question: "Wie viele verschiedene chemische Elemente stecken in einem Smartphone?",
                    range: 0...80,
                    answer: 30,
                    unit: "Elemente",
                    tolerance: 0.15,
                    explanation: "Viele davon in winzigen Mengen, verteilt über das ganze Gerät. Genau das macht die Rückgewinnung so schwer: Man kann ein Smartphone nicht sortieren, nur zerkleinern.",
                    sourceHint: "Zusammensetzung Smartphone, Anzahl Elemente prüfen"
                )),
                .story(Story(
                    title: "Der Rohstoff, der aus dem Krieg kommt",
                    paragraphs: [
                        "In jedem Handy steckt Tantal. Es macht winzige Kondensatoren möglich, und ohne diese Kondensatoren gäbe es keine flachen Geräte.",
                        "Ein erheblicher Teil des Tantals stammt aus der Region der Großen Seen in Zentralafrika. Der Abbau dort hat über Jahre bewaffnete Gruppen mitfinanziert.",
                        "Deshalb gibt es heute Lieferkettenregeln für vier Rohstoffe: Zinn, Tantal, Wolfram, Gold. Im Englischen abgekürzt als 3TG.",
                        "Die Regeln haben etwas verändert, aber nicht alles. Und sie machen deutlich, was ein Handy eigentlich ist: kein Gerät, sondern das Ende einer sehr langen Kette, von der man am Bildschirm nichts sieht."
                    ],
                    sourceHint: "EU-Konfliktmineralienverordnung, aktueller Stand"
                ))
            ]
        ),

        CatalogEntry(
            label: "computer_monitor",
            name: "Bildschirm",
            strategy: .refurbish,
            sdgs: [.responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Bildschirme werden selten ersetzt, weil sie kaputt sind, sondern weil ein neuer Rechner kommt. Ein guter Monitor überlebt problemlos zwei oder drei Geräte."
                ))
            ]
        ),

        // MARK: - R6 Neu fertigen

        CatalogEntry(
            label: "printer",
            name: "Drucker",
            strategy: .remanufacture,
            sdgs: [.responsibleConsumption, .industryInnovation],
            encounters: [
                .quiz(Quiz(
                    question: "Was ist eine wiederaufbereitete Druckerpatrone?",
                    options: [
                        "Eine nachgemachte Billigpatrone",
                        "Eine gereinigte Originalpatrone, neu befüllt und geprüft",
                        "Eine Patrone aus Recyclingplastik"
                    ],
                    correctIndex: 1,
                    explanation: "Das Gehäuse bleibt, die Verschleißteile werden ersetzt, das Ganze wird geprüft. Der aufwendigste Schritt – die Fertigung des Gehäuses – entfällt vollständig."
                ))
            ]
        ),

        CatalogEntry(
            label: "camera",
            name: "Kamera",
            strategy: .remanufacture,
            sdgs: [.responsibleConsumption, .industryInnovation],
            encounters: [
                .fact(Fact(
                    text: "Bei Kameras, Werkzeug und Maschinen ist Wiederaufbereitung ein eigener Industriezweig: Altgeräte kommen zurück ins Werk und gehen mit voller Garantie wieder hinaus."
                ))
            ]
        ),

        // MARK: - R7 Umwidmen

        CatalogEntry(
            label: "cardboard_box",
            name: "Karton",
            strategy: .repurpose,
            sdgs: [.responsibleConsumption],
            encounters: [
                .mission(Mission(
                    prompt: "Denk dir für diesen Karton eine zweite Aufgabe aus, die nichts mit Transport zu tun hat.",
                    hint: "Schublade, Ordnungshilfe, Unterlage, Katzenhöhle – Umwidmen braucht vor allem Einfallsreichtum."
                ))
            ]
        ),

        CatalogEntry(
            label: "wood_processed",
            name: "Verarbeitetes Holz",
            strategy: .repurpose,
            sdgs: [.responsibleConsumption, .lifeOnLand],
            encounters: [
                .fact(Fact(
                    text: "Ein Brett, das schon einmal ein Möbelstück war, ist immer noch ein Brett. Umwidmen ist die kreativste Stufe der Leiter – und die, die am wenigsten Infrastruktur braucht."
                ))
            ]
        ),

        CatalogEntry(
            label: "curtain",
            name: "Vorhang",
            strategy: .repurpose,
            sdgs: [.responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Große Stoffflächen sind selten und wertvoll: Aus einem alten Vorhang werden Beutel, Kissen und Putzlappen. Drei Leben statt einem."
                ))
            ]
        ),

        // MARK: - R8 Verwerten

        CatalogEntry(
            label: "drinking_glass",
            name: "Trinkglas",
            strategy: .recycle,
            sdgs: [.responsibleConsumption],
            encounters: [
                .quiz(Quiz(
                    question: "Trinkgläser gehören in den Altglascontainer.",
                    options: ["Stimmt", "Stimmt nicht"],
                    correctIndex: 1,
                    explanation: "Trinkgläser, Fensterglas und Glaskeramik schmelzen bei anderen Temperaturen als Verpackungsglas und stören die ganze Charge. Sie gehören in den Restmüll oder auf den Wertstoffhof.",
                    sourceHint: "Vorgaben Altglassammlung, kommunale Abfallberatung"
                ))
            ]
        ),

        CatalogEntry(
            label: "newspaper",
            name: "Zeitung",
            strategy: .recycle,
            sdgs: [.responsibleConsumption, .lifeOnLand],
            encounters: [
                .estimate(Estimate(
                    question: "Wie oft lässt sich dieselbe Papierfaser ungefähr wiederverwerten, bevor sie zu kurz ist?",
                    range: 0...25,
                    answer: 6,
                    unit: "mal",
                    tolerance: 0.15,
                    explanation: "Bei jedem Durchlauf werden die Fasern kürzer. Recycling verlangsamt den Verbrauch, es hebt ihn nicht auf – irgendwann muss frische Faser dazu.",
                    sourceHint: "Papierrecycling, Anzahl möglicher Kreisläufe"
                ))
            ]
        ),

        CatalogEntry(
            label: "carton",
            name: "Getränkekarton",
            strategy: .recycle,
            sdgs: [.responsibleConsumption],
            encounters: [
                .quiz(Quiz(
                    question: "Woraus besteht ein Getränkekarton?",
                    options: [
                        "Nur aus Pappe",
                        "Aus Pappe, Kunststoff und meist Aluminium",
                        "Aus beschichtetem Papier ohne Zusätze"
                    ],
                    correctIndex: 1,
                    explanation: "Genau diese Verbindung macht ihn dicht und leicht – und die Trennung aufwendig. Verbundstoffe sind der schwierigste Fall für jedes Recycling."
                ))
            ]
        ),

        CatalogEntry(
            label: "trash_can",
            name: "Mülleimer",
            strategy: .recycle,
            sdgs: [.responsibleConsumption, .sustainableCities],
            encounters: [
                .fact(Fact(
                    text: "Die Tonne ist das Ende der Leiter, nicht ihr Anfang. Alles, was hier landet, hat neun Stufen ungenutzt hinter sich."
                )),
                .mission(Mission(
                    prompt: "Schau in den nächsten Mülleimer, an dem du vorbeikommst. Was darin hätte noch eine Stufe höher gekonnt?",
                    hint: "Nur hinschauen. Nichts herausholen."
                ))
            ]
        ),

        // MARK: - R9 Energie zurückholen

        CatalogEntry(
            label: "wood_natural",
            name: "Holz",
            strategy: .recover,
            sdgs: [.affordableEnergy, .lifeOnLand],
            encounters: [
                .fact(Fact(
                    text: "Holz zu verbrennen ist die letzte sinnvolle Stufe – aber erst, wenn es vorher Möbel, Brett und Span war. Frisches Holz direkt zu verbrennen überspringt neun Stufen."
                ))
            ]
        ),

        CatalogEntry(
            label: "container",
            name: "Behälter",
            strategy: .recover,
            sdgs: [.responsibleConsumption, .sustainableCities],
            encounters: [
                .quiz(Quiz(
                    question: "Was passiert mit dem Restmüll in Deutschland überwiegend?",
                    options: ["Er wird deponiert", "Er wird verbrannt und die Wärme genutzt", "Er wird exportiert"],
                    correctIndex: 1,
                    explanation: "Unbehandelter Siedlungsabfall darf seit 2005 nicht mehr deponiert werden. Verbrennung mit Energienutzung ist besser als eine Deponie – aber sie ist ein Ende, kein Kreislauf.",
                    sourceHint: "Deponierungsverbot 2005, Abfallstatistik Destatis"
                ))
            ]
        ),

        // MARK: - Natur und Umgebung

        CatalogEntry(
            label: "tree",
            name: "Baum",
            strategy: .rethink,
            sdgs: [.climateAction, .lifeOnLand, .sustainableCities],
            encounters: [
                .estimate(Estimate(
                    question: "Wie viel Wasser verdunstet eine große Buche an einem heißen Sommertag?",
                    range: 0...1000,
                    answer: 400,
                    unit: "Liter",
                    tolerance: 0.15,
                    explanation: "Diese Verdunstung kühlt – wie Schwitzen, nur im Großen. Deshalb ist es unter einem Baum spürbar kühler als unter einem Sonnenschirm derselben Größe.",
                    sourceHint: "Transpirationsleistung Laubbaum, Größenordnung prüfen"
                )),
                .story(Story(
                    title: "Woraus ein Baum gemacht ist",
                    paragraphs: [
                        "Frag jemanden, woher die Masse eines Baumes kommt, und fast alle sagen: aus dem Boden.",
                        "Stimmt nicht. Der Boden liefert Wasser und Spurenstoffe. Der Kohlenstoff, aus dem das Holz besteht, kommt aus der Luft.",
                        "Ein Baum ist, ganz wörtlich, gefrorene Luft. Er zieht Kohlendioxid aus der Atmosphäre und baut daraus einen Stamm.",
                        "Wenn er verbrennt oder verrottet, geht dieser Kohlenstoff denselben Weg zurück. Deshalb ist ein Wald nur so lange eine Senke, wie er wächst – und ein Holzhaus ein Speicher, so lange es steht."
                    ]
                )),
                .video(VideoTip(
                    searchTerm: "where does a tree's mass come from Veritasium",
                    why: "Die Frage, an der fast jeder scheitert – und die man danach nie wieder vergisst."
                ))
            ]
        ),

        CatalogEntry(
            label: "plant",
            name: "Pflanze",
            strategy: .reduce,
            sdgs: [.lifeOnLand, .goodHealth],
            encounters: [
                .fact(Fact(
                    text: "Eine Pflanze auf der Fensterbank ist kein Klimaschutz. Aber sie ist eine tägliche Erinnerung daran, dass etwas Zeit braucht, um zu wachsen."
                ))
            ]
        ),

        CatalogEntry(
            label: "bee",
            name: "Biene",
            strategy: .rethink,
            sdgs: [.lifeOnLand, .zeroHunger],
            encounters: [
                .story(Story(
                    title: "Die falsche Biene",
                    paragraphs: [
                        "„Rettet die Bienen“ steht auf den Plakaten, und daneben ist eine Honigbiene abgebildet.",
                        "Die Honigbiene ist aber ein Nutztier. Sie wird gehalten, gezüchtet und gezählt. Ihr geht es, gemessen an der Zahl der Völker, nicht schlecht.",
                        "Bedroht sind die Wildbienen – in Deutschland mehrere hundert Arten, viele davon auf einzelne Pflanzen spezialisiert. Fehlt die Pflanze, fehlt die Art.",
                        "Noch unangenehmer: Zu viele Honigbienenvölker in der Stadt können Wildbienen die Nahrung wegkonkurrieren. Gut gemeint ist hier nachweislich nicht dasselbe wie gut."
                    ],
                    sourceHint: "Konkurrenz Honigbiene/Wildbiene – Forschungsstand prüfen"
                ))
            ]
        ),

        CatalogEntry(
            label: "grass",
            name: "Rasen",
            strategy: .rethink,
            sdgs: [.lifeOnLand, .sustainableCities],
            encounters: [
                .quiz(Quiz(
                    question: "Was hilft Insekten auf einer Rasenfläche am meisten?",
                    options: ["Öfter mähen, damit es ordentlich bleibt", "Eine Ecke stehen lassen", "Regelmäßig düngen"],
                    correctIndex: 1,
                    explanation: "Ein kurz geschorener Rasen ist für Insekten eine Wüste. Schon eine ungemähte Ecke verändert das – und kostet nichts außer der Bereitschaft, es unordentlich aussehen zu lassen."
                ))
            ]
        ),

        CatalogEntry(
            label: "bread",
            name: "Brot",
            strategy: .reduce,
            sdgs: [.zeroHunger, .responsibleConsumption],
            encounters: [
                .fact(Fact(
                    text: "Brot gehört zu den am häufigsten weggeworfenen Lebensmitteln. Altbackenes Brot ist nicht verdorben – es ist trocken, und dagegen gibt es seit Jahrhunderten Rezepte.",
                    sourceHint: "Lebensmittelabfälle Deutschland, Anteil Backwaren"
                ))
            ]
        ),

        CatalogEntry(
            label: "vegetable",
            name: "Gemüse",
            strategy: .reduce,
            sdgs: [.zeroHunger, .climateAction, .responsibleConsumption],
            encounters: [
                .quiz(Quiz(
                    question: "Was ist bei Gemüse ökologisch meist am wichtigsten?",
                    options: ["Dass es regional ist", "Dass es Saison hat", "Dass es unverpackt ist"],
                    correctIndex: 1,
                    explanation: "Saison schlägt Region: Regionales Gemüse aus dem beheizten Gewächshaus kann schlechter abschneiden als Freilandware von weiter weg. Der Transport ist selten der große Posten.",
                    sourceHint: "Treibhausgasbilanz Gemüse nach Anbauart"
                )),
                .video(VideoTip(
                    searchTerm: "food miles überschätzt Transport Anteil Emissionen Lebensmittel",
                    why: "Transport macht bei den meisten Lebensmitteln nur einen kleinen Teil der Emissionen aus. Was man isst, zählt fast immer mehr als woher es kommt."
                ))
            ]
        )
    ]

    /// Schneller Zugriff über den Erkennungsbezeichner.
    static let byLabel: [String: CatalogEntry] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.label, $0) }
    )

    static func entry(for label: String) -> CatalogEntry? { byLabel[label] }

    /// Alle Bezeichner, auf die sich die Erkennung überhaupt lohnt.
    static let knownLabels: Set<String> = Set(all.map(\.label))

    static func entries(for strategy: RStrategy) -> [CatalogEntry] {
        all.filter { $0.strategy == strategy }
    }
}
