import SwiftUI

/// Das Werkzeugblatt für den Gerätetest. Nicht Teil des Spiels.
///
/// Es beantwortet die Fragen, die sich ohne es nicht beantworten lassen:
/// Erscheint kein Fundpunkt – sieht die Erkennung nichts, gewinnt kein Thema
/// deutlich genug, oder liefert sie nur Oberbegriffe? Erscheint Unsinn –
/// welches Thema hat gewonnen und mit welchem Stimmenanteil? Von außen ist
/// beides jeweils ein einziges Symptom mit mehreren möglichen Ursachen.
struct DiagnosticsView: View {

    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    threshold
                    themes
                    candidates
                    situation
                    danger
                }
                .padding(Spacing.m)
                .readableWidth()
            }
            .background(Palette.background)
            .navigationTitle("Diagnose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    // MARK: Schwellen

    private var threshold: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeading(text: "Annahmeschwellen")

            knob(title: "Mindestsumme je Thema",
                 value: Binding(get: { Double(state.minimumThemeScore) },
                                set: { state.minimumThemeScore = Float($0) }),
                 range: 0.05...1.2,
                 format: "%.2f",
                 start: "0,20",
                 explanation: "Alle Vorschläge zahlen auf ihr Thema ein. Hier steht, wie viel zusammenkommen muss. Höher heißt: seltener, aber sicherer.")

            knob(title: "Anteil an allen Stimmen",
                 value: Binding(get: { Double(state.minimumShare) },
                                set: { state.minimumShare = Float($0) }),
                 range: 0.10...0.90,
                 format: "%.0f%%",
                 start: "30 %",
                 explanation: "Wie viel vom Gesamtergebnis auf das beste Thema entfallen muss. Misst, ob überhaupt ein Signal da ist – nicht, ob der Zweite knapp dahinterliegt. Ein Holztisch ist zu Recht gleichzeitig Holz und Möbel.",
                 percent: true)

            knob(title: "Nötige Beobachtungsstärke",
                 value: Binding(get: { Double(state.requiredEvidence) },
                                set: { state.requiredEvidence = Float($0) }),
                 range: 0.2...2.5,
                 format: "%.2f",
                 start: "0,75",
                 explanation: "Aufsummiert über mehrere Durchläufe, mindestens zwei. Ein eindeutiger Gegenstand ist damit nach etwa einer Sekunde da, ein zweifelhafter braucht länger. Kleiner heißt: schneller, aber wackliger.")
        }
        .cardStyle()
    }

    private func knob(title: String, value: Binding<Double>, range: ClosedRange<Double>,
                      format: String, start: String, explanation: String,
                      percent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text(String(format: format, percent ? value.wrappedValue * 100 : value.wrappedValue))
                    .font(.system(.body, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Palette.accent)
            }
            Slider(value: value, in: range).tint(Palette.accent)
            Text("\(explanation) Startwert \(start).")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
        }
    }

    // MARK: Themenabstimmung

    private var themes: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Themenabstimmung")
            if state.themeScores.isEmpty {
                Text("Noch keine Abstimmung. Halt die Kamera auf einen einzelnen Gegenstand.")
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            } else {
                ForEach(state.themeScores.prefix(5)) { entry in
                    HStack(spacing: Spacing.s) {
                        Text(entry.theme.name)
                            .font(.subheadline)
                            .foregroundStyle(Palette.textPrimary)
                        Spacer()
                        Text(String(format: "%.2f", entry.score))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(entry.score >= state.minimumThemeScore
                                             ? Palette.textPrimary : Palette.textSecondary)
                    }
                }
                Text("Der Fund wird nach dem konkretesten Begriff im Gewinnerthema benannt. Oberbegriffe wie „material“ dürfen mitstimmen, aber nichts benennen – sonst hieße drinnen fast alles „Gegenstand“.")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .padding(.top, Spacing.xs)
            }
        }
        .cardStyle()
    }

    // MARK: Was die Kamera wirklich sieht

    private var candidates: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Rohe Vorschläge")

            if state.rawCandidates.isEmpty {
                Text("Noch nichts. Die Erkennung läuft knapp dreimal pro Sekunde – kurz warten und die Kamera auf einen klar abgegrenzten Gegenstand halten.")
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            } else {
                ForEach(state.rawCandidates) { candidate in
                    HStack(spacing: Spacing.s) {
                        Image(systemName: candidate.generic ? "circle.dotted"
                                          : (candidate.known ? "checkmark.circle.fill" : "circle"))
                            .foregroundStyle(candidate.generic ? Palette.caution
                                             : (candidate.known ? Palette.accent : Palette.textSecondary))
                        Text(candidate.label)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(candidate.known ? Palette.textPrimary : Palette.textSecondary)
                        Spacer()
                        Text(String(format: "%.3f", candidate.confidence))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(Palette.textPrimary)
                    }
                }
                Text("Haken heißt: spielbar. Gepunkteter Kreis heißt: Oberbegriff – zählt für sein Thema, benennt aber nie einen Fund.")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
                    .padding(.top, Spacing.xs)
            }
        }
        .cardStyle()
    }

    // MARK: Lage

    private var situation: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Lage")
            line("Auffällige Bereiche", "\(state.regionCount)")
            line("Angenommene Sichtungen", "\(state.debugBoxes.count)")
            line("Reift gerade", "\(state.ripeningCount)")
            line("Punkte in der Szene", "\(state.spotCount)")
            if let rejection = state.lastRejection {
                Text(rejection)
                    .font(.footnote)
                    .foregroundStyle(Palette.caution)
            }
            Text("Null auffällige Bereiche heißt: Es liegt an der Bildsuche, nicht an den Schwellen – dann näher an einen einzelnen Gegenstand halten.")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
            Text("Die gelben Rahmen im Kamerabild zeigen, wo die Erkennung den Gegenstand vermutet. Liegen sie neben dem Gegenstand, ist die Umrechnung von Vision auf den Bildschirm schuld – nicht die Erkennung. Die Stelle ist in ARGameView kommentiert.")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
        }
        .cardStyle()
    }

    private func line(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Palette.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced).weight(.medium))
                .foregroundStyle(Palette.textPrimary)
        }
    }

    // MARK: Zurücksetzen

    private var danger: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Button("Fortschritt zurücksetzen") {
                state.reset()
            }
            .buttonStyle(CalmButtonStyle(prominent: false))
            Text("Löscht Funde, Blätter und Punkte auf diesem Gerät.")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
        }
    }
}
