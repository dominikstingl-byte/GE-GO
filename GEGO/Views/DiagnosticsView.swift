import SwiftUI

/// Das Werkzeugblatt für den Gerätetest. Nicht Teil des Spiels.
///
/// Es beantwortet die Fragen, die sich ohne es nicht beantworten lassen:
/// Erscheint kein Fundpunkt – sieht die Erkennung nichts, gewinnt kein Thema
/// deutlich genug, oder liefert sie nur Oberbegriffe? Erscheint Unsinn –
/// welches Thema hat gewonnen und mit welchem Abstand? Von außen ist beides
/// jeweils ein einziges Symptom mit mehreren möglichen Ursachen.
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
                 start: "0,30",
                 explanation: "Alle Vorschläge zahlen auf ihr Thema ein. Hier steht, wie viel zusammenkommen muss. Höher heißt: seltener, aber sicherer.")

            knob(title: "Abstand zum zweiten Thema",
                 value: Binding(get: { Double(state.minimumMargin) },
                                set: { state.minimumMargin = Float($0) }),
                 range: 1.0...4.0,
                 format: "%.1f×",
                 start: "1,6×",
                 explanation: "Wie deutlich das beste Thema vorn liegen muss. Ist die Szene mehrdeutig – halb Wand, halb Regal – ist Schweigen besser als Raten.")

            Text("Ein Punkt erscheint erst, wenn dasselbe Thema dreimal hintereinander an derselben Stelle gewinnt. Etwa anderthalb Sekunden ruhig draufhalten.")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
        }
        .cardStyle()
    }

    private func knob(title: String, value: Binding<Double>, range: ClosedRange<Double>,
                      format: String, start: String, explanation: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text(String(format: format, value.wrappedValue))
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
                Text("Noch nichts. Die Erkennung läuft zweimal pro Sekunde – kurz warten und die Kamera auf einen klar abgegrenzten Gegenstand halten.")
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
            line("Punkte in der Szene", "\(state.spotCount)")
            line("Rahmen gezeichnet", "\(state.debugBoxes.count)")
            line("Bestätigungen nötig", "3")
            if let rejection = state.lastRejection {
                Text(rejection)
                    .font(.footnote)
                    .foregroundStyle(Palette.caution)
            }
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
