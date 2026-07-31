import SwiftUI

/// Das Werkzeugblatt für den Gerätetest. Nicht Teil des Spiels.
///
/// Es beantwortet die eine Frage, die sich ohne es nicht beantworten lässt:
/// Wenn kein Fundpunkt erscheint – sieht die Erkennung nichts, sieht sie etwas
/// unterhalb der Schwelle, oder sieht sie etwas, zu dem der Katalog nichts
/// sagt? Drei sehr verschiedene Ursachen, von außen ein einziges Symptom.
struct DiagnosticsView: View {

    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    threshold
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

    // MARK: Schwelle

    private var threshold: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Erkennungsschwelle")
            HStack {
                Text(String(format: "%.3f", state.minimumConfidence))
                    .font(.system(.title2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Palette.accent)
                Spacer()
                Text("Startwert 0,120")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
            Slider(value: Binding(
                get: { Double(state.minimumConfidence) },
                set: { state.minimumConfidence = Float($0) }
            ), in: 0.01...0.6)
            .tint(Palette.accent)

            Text("Zu hoch heißt: nichts wird gefunden. Zu niedrig heißt: alles ist alles. Die Klassifikation verteilt ihre Sicherheit auf über 1300 Begriffe, deshalb sind kleine Werte normal.")
                .font(.footnote)
                .foregroundStyle(Palette.textSecondary)
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
                        Image(systemName: candidate.known ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(candidate.known ? Palette.accent : Palette.textSecondary)
                        Text(candidate.label)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(candidate.known ? Palette.textPrimary : Palette.textSecondary)
                        Spacer()
                        Text(String(format: "%.3f", candidate.confidence))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(candidate.confidence >= state.minimumConfidence
                                             ? Palette.textPrimary : Palette.textSecondary)
                    }
                }
                Text("Haken heißt: steht im Katalog. Ohne Haken kennt das iPhone den Gegenstand, aber das Spiel hat nichts dazu zu sagen – ein Kandidat für `ObjectCatalog`.")
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
