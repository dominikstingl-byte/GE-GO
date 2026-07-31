import Foundation

/// Der Vorrat für die Blüten-Fundpunkte.
///
/// Anders als die Themeninhalte hängen Minispiele **nicht am Gegenstand**.
/// Eine Blüte kann überall auftauchen, und was darin steckt, hat mit dem
/// Stuhl davor nichts zu tun. Das ist Absicht: Ein Minispiel ist ein
/// Zwischenspiel, kein Steckbrief.
///
/// Wie überall gilt: Wo eine Zahl steht, hängt ein `sourceHint` daran. Bei
/// Serienformaten ist das je Aussage einer.
enum MiniGameCatalog {

    static let all: [ThemedEncounter] = [

        // MARK: 1 Kreislauf schließen

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption, .industryInnovation], encounter:
            .cycle(CycleGame(
                question: "Eine Pfandflasche aus Kunststoff geht ihren Weg. In welcher Reihenfolge?",
                stationsInOrder: ["Abfüllung", "Verkauf", "Rückgabe am Automaten", "Sortierung nach Sorte", "Mahlen und Reinigen", "Neue Flasche"],
                explanation: "Der Schritt, an dem alles hängt, ist die Sortierung nach Sorte. Nur weil Pfandflaschen sortenrein und sauber zurückkommen, lässt sich daraus wieder eine Flasche machen. Bei gemischtem Kunststoff endet derselbe Kreis nach der Sortierung – und wird bestenfalls Blumenkasten.",
                sourceHint: "Verwertungskette PET-Einwegpfand, Anteil Flasche-zu-Flasche"
            ))),

        ThemedEncounter(strategy: .rethink, sdgs: [.responsibleConsumption], encounter:
            .cycle(CycleGame(
                question: "So läuft es heute bei den meisten Dingen. Bring die Stationen in die richtige Reihenfolge.",
                stationsInOrder: ["Rohstoff abbauen", "Herstellen", "Verkaufen", "Kurz benutzen", "Wegwerfen"],
                explanation: "Das ist kein Kreis, das ist eine Gerade – und sie endet im Abfall. Genau deshalb heißt das Gegenmodell Kreislaufwirtschaft und nicht besseres Recycling: Es geht darum, die Linie zu schließen, nicht darum, ihr Ende ordentlicher zu gestalten.",
                sourceHint: "Lineares vs. zirkuläres Wirtschaftsmodell, Grundbegriffe"
            ))),

        // MARK: 2 Was passt nicht dazu?

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .oddOne(OddOne(
                question: "Drei davon lassen sich praktisch endlos wiederverwerten. Welches nicht?",
                options: ["Aluminium", "Glas", "Stahl", "Papier"],
                oddIndex: 3,
                explanation: "Metall und Glas verlieren beim Einschmelzen ihre Form, aber nicht ihre Eigenschaften. Papierfasern werden bei jedem Durchgang kürzer und sind nach etwa fünf bis sieben Runden zu kurz zum Verfilzen. Papier ist kein Kreis, sondern eine sehr lange Spirale.",
                sourceHint: "Maximale Recyclingdurchgänge nach Werkstoff, Faserverkürzung Papier"
            ))),

        ThemedEncounter(strategy: .refuse, sdgs: [.climateAction], encounter:
            .oddOne(OddOne(
                question: "Drei dieser Entscheidungen wirken im Alltag ähnlich stark. Welche fällt aus dem Rahmen?",
                options: ["Mülltrennen", "Kurz duschen", "Stoßlüften statt kippen", "Einen Langstreckenflug weglassen"],
                oddIndex: 3,
                explanation: "Die ersten drei sind richtig und sinnvoll – und liegen in derselben Größenordnung. Ein einziger Langstreckenflug übersteigt sie zusammengenommen um ein Vielfaches. Das entwertet den Alltag nicht, aber es sortiert ihn.",
                sourceHint: "Emissionen Langstreckenflug pro Person vs. typische Haushaltsmaßnahmen im Jahr"
            ))),

        // MARK: 3 Wahr oder falsch

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption, .affordableEnergy], encounter:
            .trueFalse(TrueFalseRun(
                intro: "Fünf Aussagen, acht Sekunden je Aussage. Ein Fehler beendet den Lauf.",
                statements: [
                    TrueFalseItem(text: "Joghurtbecher müssen vor dem Wegwerfen ausgespült werden.",
                                  isTrue: false,
                                  explanation: "Löffelrein reicht. Die Sortieranlage kommt mit Resten zurecht, und das Spülwasser kostet mehr, als es bringt. Wichtig ist nur, Deckel und Becher zu trennen.",
                                  sourceHint: "Hinweise der dualen Systeme zur Vorbehandlung von Leichtverpackungen"),
                    TrueFalseItem(text: "Der Standby-Verbrauch ist der größte Stromposten im Haushalt.",
                                  isTrue: false,
                                  explanation: "Standby ist real, aber klein. Heizen, Warmwasser und Wäschetrockner liegen weit davor. Standby fühlt sich nur wie das Hauptproblem an, weil das Lämpchen sichtbar ist.",
                                  sourceHint: "Anteil Standby am Haushaltsstromverbrauch"),
                    TrueFalseItem(text: "Das Mindesthaltbarkeitsdatum ist kein Verfallsdatum.",
                                  isTrue: true,
                                  explanation: "Es ist eine Zusage des Herstellers über Qualität. Nur das Verbrauchsdatum auf rohem Fisch und Fleisch ist eine harte Grenze.",
                                  sourceHint: "Unterschied Mindesthaltbarkeits- und Verbrauchsdatum, LMIV"),
                    TrueFalseItem(text: "Eine volle Spülmaschine braucht weniger Wasser als Handspülen.",
                                  isTrue: true,
                                  explanation: "Vorausgesetzt, sie ist wirklich voll und es wird nicht vorgespült. Vorspülen unter fließendem Wasser macht den Vorteil zunichte.",
                                  sourceHint: "Vergleichsstudien Geschirrspüler vs. Handspülen"),
                    TrueFalseItem(text: "Kassenbons gehören ins Altpapier.",
                                  isTrue: false,
                                  explanation: "Thermopapier gehört in den Restmüll – die Beschichtung belastet den Papierkreislauf. Am besten ist, ihn gar nicht erst zu nehmen.",
                                  sourceHint: "Thermopapier und Bisphenole, Entsorgungshinweise")
                ]
            ))),

        // MARK: 4 Höher oder tiefer

        ThemedEncounter(strategy: .rethink, sdgs: [.climateAction, .responsibleConsumption], encounter:
            .higherLower(HigherLowerRun(
                intro: "Vier Paare. Welches wiegt mehr?",
                pairs: [
                    HigherLowerPair(question: "Treibhausgase je Kilogramm – was ist höher?",
                                    optionA: "Rindfleisch", optionB: "Hähnchen",
                                    aIsLarger: true,
                                    explanation: "Der Abstand ist nicht knapp, sondern ein Vielfaches. Wiederkäuer erzeugen zusätzlich Methan, und der Futterbedarf je Kilo Fleisch ist deutlich höher.",
                                    sourceHint: "Treibhausgasemissionen je kg Rind vs. Geflügel"),
                    HigherLowerPair(question: "Energiebedarf in der Herstellung – was ist höher?",
                                    optionA: "Eine Papiertüte", optionB: "Eine Plastiktüte",
                                    aIsLarger: true,
                                    explanation: "Überraschend, aber gut belegt: Papier braucht in der Herstellung mehr Energie und deutlich mehr Wasser. Es lohnt sich erst nach mehreren Einsätzen – die kaum jemand macht.",
                                    sourceHint: "Umweltbundesamt, Tragetaschen im Vergleich"),
                    HigherLowerPair(question: "Anteil am Fußabdruck eines Smartphones – was ist höher?",
                                    optionA: "Der Betrieb über vier Jahre", optionB: "Die Herstellung",
                                    aIsLarger: false,
                                    explanation: "Die Herstellung dominiert deutlich. Deshalb ändert Strom sparen beim Handy fast nichts, während ein Jahr längere Nutzung sehr viel ändert.",
                                    sourceHint: "Anteil Herstellung am Lebenszyklus-Fußabdruck von Smartphones"),
                    HigherLowerPair(question: "Getötete Vögel in Deutschland – was ist höher?",
                                    optionA: "Windkraftanlagen", optionB: "Glasscheiben an Gebäuden",
                                    aIsLarger: false,
                                    explanation: "Scheiben mit großem Abstand. Vögel sehen Glas nicht, sondern die Spiegelung von Himmel und Bäumen. Windräder sind ein reales, aber deutlich kleineres Problem.",
                                    sourceHint: "Vogelschlag an Glasflächen vs. Windenergieanlagen, Schätzungen")
                ]
            ))),

        // MARK: 5 Jagd nach R-Stufe

        ThemedEncounter(strategy: .repair, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei Dinge in deiner Nähe, die man reparieren könnte.",
                theme: nil,
                strategy: .repair,
                count: 2,
                seconds: 120,
                reward: "Reparierbar ist mehr, als man denkt – und der Blick dafür ist der halbe Weg."
            ))),

        ThemedEncounter(strategy: .reuse, sdgs: [.responsibleConsumption], encounter:
            .hunt(Hunt(
                prompt: "Finde zwei Dinge, die jemand anders noch gebrauchen könnte.",
                theme: nil,
                strategy: .reuse,
                count: 2,
                seconds: 120,
                reward: "Weitergeben überspringt die ganze Verwertungskette."
            ))),

        // MARK: 6 Zeitstrahl

        ThemedEncounter(strategy: .refuse, sdgs: [.lifeBelowWater, .responsibleConsumption], encounter:
            .timeline(TimelineGame(
                question: "Wie lange braucht das in der Umwelt, bis es zerfallen ist?",
                item: "Ein Zigarettenfilter",
                answerDays: 365 * 12,
                explanation: "Filter bestehen aus Celluloseacetat – also Kunststoff, nicht Watte. Sie sind zugleich der weltweit am häufigsten gefundene Abfall an Stränden. Der unscheinbarste Gegenstand ist der häufigste.",
                sourceHint: "Zerfallszeit Celluloseacetat-Filter; Strandmüll-Erhebungen, häufigste Fundstücke"
            ))),

        ThemedEncounter(strategy: .recycle, sdgs: [.lifeBelowWater], encounter:
            .timeline(TimelineGame(
                question: "Wie lange braucht das in der Umwelt, bis es zerfallen ist?",
                item: "Eine Glasflasche",
                answerDays: 365 * 4000,
                maxYears: 20_000,
                explanation: "Glas zerfällt in der Natur praktisch nicht – es zerbricht nur in immer kleinere Stücke. Genau das macht Altglas so wertvoll: Was nie verschwindet, sollte im Kreislauf bleiben.",
                sourceHint: "Verwitterungszeiten von Glas in der Umwelt, Größenordnung"
            ))),

        // MARK: 7 Tonne treffen

        ThemedEncounter(strategy: .recycle, sdgs: [.responsibleConsumption], encounter:
            .sorting(SortingGame(
                question: "Wohin gehört das?",
                bins: ["Restmüll", "Gelbe Tonne", "Altpapier", "Bioabfall", "Altglas", "Wertstoffhof"],
                items: [
                    SortingItem(name: "Pizzakarton mit Fettflecken", binIndex: 0,
                                note: "Fett lässt sich nicht auswaschen und macht die Fasern unbrauchbar."),
                    SortingItem(name: "Joghurtbecher mit Aludeckel", binIndex: 1,
                                note: "Deckel abziehen, beides getrennt hinein – Verbunde bleiben sonst Gemisch."),
                    SortingItem(name: "Kassenbon", binIndex: 0,
                                note: "Thermopapier belastet den Papierkreislauf."),
                    SortingItem(name: "Teebeutel", binIndex: 3,
                                note: "Samt Inhalt – nur die Klammer bleibt draußen."),
                    SortingItem(name: "Blaue Weinflasche", binIndex: 4,
                                note: "Alles Bunte ins Grünglas; es verträgt Fremdfarben am besten."),
                    SortingItem(name: "Kaputte Energiesparlampe", binIndex: 5,
                                note: "Enthält Quecksilber – nie in den Hausmüll.")
                ],
                explanation: "Die zwei Regeln, die am meisten helfen: Verbunde trennen, und alles mit Batterie, Akku oder Leuchtmittel gehört nie in den Hausmüll. Beides scheitert selten am Wissen und meistens an der Bequemlichkeit.",
                sourceHint: "Sortiervorgaben duale Systeme; ElektroG und Batteriegesetz zur Rücknahme"
            ))),

        // MARK: 8 Blüten-Memory

        ThemedEncounter(strategy: .rethink, sdgs: [.qualityEducation, .responsibleConsumption], encounter:
            .memory(MemoryGame(
                intro: "Finde die Paare: Blatt und Bedeutung.",
                strategies: [.refuse, .repair, .recycle, .recover],
                explanation: "Diese vier spannen die ganze Leiter auf: Verweigern ganz oben, Energie zurückholen ganz unten. Alles dazwischen ist eine Frage, wie viel von einem Ding erhalten bleibt – die Gestalt, die Funktion oder nur noch das Material."
            ))),

        ThemedEncounter(strategy: .reduce, sdgs: [.qualityEducation], encounter:
            .memory(MemoryGame(
                intro: "Noch einmal, mit den mittleren Stufen.",
                strategies: [.reuse, .refurbish, .remanufacture, .repurpose],
                explanation: "Die vier in der Mitte werden am häufigsten verwechselt. Der Unterschied ist, wie tief eingegriffen wird: weiternutzen ohne Eingriff, aufarbeiten als Ganzes, aus Teilen neu fertigen, oder eine völlig neue Aufgabe geben."
            ))),

        // MARK: 9 Fehlersuche

        ThemedEncounter(strategy: .reduce, sdgs: [.responsibleConsumption, .affordableEnergy], encounter:
            .spotErrors(SpotErrors(
                scene: "Jemand räumt die Küche auf: Er spült die Joghurtbecher gründlich aus, wirft den Kassenbon ins Altpapier, stellt den halbleeren Geschirrspüler an, kippt das Nudelwasser in den Ausguss und stellt den warmen Topf in den Kühlschrank.",
                question: "Welche dieser Aussagen über die Szene stimmen nicht?",
                statements: [
                    ErrorStatement(text: "Die Becher auszuspülen war richtig.", isWrong: true),
                    ErrorStatement(text: "Der Kassenbon gehört nicht ins Altpapier.", isWrong: false),
                    ErrorStatement(text: "Den halbleeren Geschirrspüler anzustellen war in Ordnung.", isWrong: true),
                    ErrorStatement(text: "Das Nudelwasser durfte in den Ausguss.", isWrong: false),
                    ErrorStatement(text: "Der warme Topf im Kühlschrank ist unproblematisch.", isWrong: true)
                ],
                explanation: "Drei Fehler: Ausspülen ist unnötig (löffelrein reicht), der halbleere Geschirrspüler verschenkt seinen ganzen Vorteil, und ein warmer Topf zwingt den Kühlschrank zu Mehrarbeit. Der Kassenbon gehört tatsächlich nicht ins Altpapier, und Nudelwasser ist harmlos – diese beiden Aussagen stimmen also.",
                sourceHint: "Vorbehandlung von Verpackungen; Teillast bei Geschirrspülern; Wärmeeintrag Kühlgeräte"
            ))),

        // MARK: 10 Budget verteilen

        ThemedEncounter(strategy: .refuse, sdgs: [.climateAction, .responsibleConsumption], encounter:
            .budget(BudgetGame(
                question: "Du hast hundert Punkte Aufmerksamkeit für ein Jahr. Wo bringen sie am meisten?",
                options: [
                    BudgetOption(name: "Weniger fliegen", weight: 0.45,
                                 note: "einzelne Flüge übersteigen ganze Alltagsjahre"),
                    BudgetOption(name: "Weniger Fleisch und Käse", weight: 0.30,
                                 note: "der größte Hebel beim Essen"),
                    BudgetOption(name: "Ein Grad kälter heizen", weight: 0.20,
                                 note: "Wärme ist der größte Posten im Haushalt"),
                    BudgetOption(name: "Sorgfältiger Müll trennen", weight: 0.05,
                                 note: "richtig und nötig, aber klein")
                ],
                explanation: "Mülltrennen steht zu Recht ganz unten und wird trotzdem am häufigsten genannt – es ist sichtbar, täglich und fühlt sich nach Handeln an. Genau darum geht es in diesem Spiel: nicht ob etwas wirkt, sondern wie viel es wiegt. Die Anteile sind grobe Größenordnungen und hängen stark davon ab, wie jemand lebt.",
                sourceHint: "Vergleich der Minderungspotenziale privater Maßnahmen pro Kopf und Jahr"
            )))
    ]
}
