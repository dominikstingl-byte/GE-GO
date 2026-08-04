import SwiftUI

/// Die Sammlung: zehn Stufen, die sich füllen. Der Bogen, der über Wochen
/// trägt – eine Lücke zieht stärker als jede Punktzahl.
///
/// Die zehn Stufen sind die zehn Formen des Logos. Was begriffen ist, leuchtet
/// in seiner Farbe; der Rest steht als Umriss da und wartet. Am Ende ist die
/// Blüte vollständig, und das ist der einzige Zustand, in dem sie aussieht wie
/// das Zeichen, aus dem sie stammt.
struct CollectionView: View {

    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var selected: RStrategy?
    @State private var showsResetConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.l) {
                    bloom
                    summary
                    ForEach(RStrategy.allCases) { strategy in
                        row(for: strategy)
                            .id(strategy)
                    }
                    Text("Die Leiter geht von oben nach unten: Was oben verhindert wird, muss unten nicht verwertet werden.")
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                        .padding(.top, Spacing.s)
                    resetSection
                }
                .padding(Spacing.m)
                .readableWidth()
            }
            .background(Palette.background)
            .navigationTitle("Sammlung")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .confirmationDialog("Fortschritt wirklich zurücksetzen?",
                                isPresented: $showsResetConfirmation,
                                titleVisibility: .visible) {
                Button("Zurücksetzen", role: .destructive) {
                    withAnimation { state.reset() }
                    selected = nil
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Funde, Blätter und Punkte auf diesem Gerät gehen verloren. Das lässt sich nicht rückgängig machen.")
            }
        }
    }

    // MARK: Zurücksetzen

    /// Der Reset lag bisher nur im Diagnoseblatt. Hier ist er auch ohne den
    /// Entwickler-Umweg erreichbar – dezent am Fuß der Sammlung und mit
    /// Rückfrage, weil er sichtbar für Spieler ist.
    private var resetSection: some View {
        VStack(spacing: Spacing.xs) {
            Button(role: .destructive) {
                showsResetConfirmation = true
            } label: {
                Text("Fortschritt zurücksetzen")
                    .font(.footnote.weight(.medium))
            }
            Text("Löscht alle Funde, Blätter und Punkte auf diesem Gerät.")
                .font(.caption2)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.l)
    }

    // MARK: Die Blüte

    private var bloom: some View {
        VStack(spacing: Spacing.m) {
            BloomView(
                filled: { state.has($0) },
                highlighted: selected,
                onTap: { strategy in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selected = selected == strategy ? nil : strategy
                    }
                }
            )
            .frame(maxWidth: 260)
            .padding(.top, Spacing.s)

            if let selected {
                VStack(spacing: 2) {
                    Text("\(selected.code) · \(selected.title)")
                        .font(.headline)
                        .foregroundStyle(selected.color)
                    Text(state.has(selected)
                         ? selected.summary
                         : "Noch \(state.requirement(for: selected) - state.masteredCount(for: selected)) verschiedene Funde bis dieses Blatt aufgeht.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Text("Tipp ein Blatt an.")
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(state.openPetals) von \(RStrategy.allCases.count) Blättern")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text("\(state.points) Punkte")
                    .font(.headline)
                    .foregroundStyle(Palette.accent)
            }
            ProgressView(value: state.collectionProgress)
                .tint(Palette.accent)
            Text("Ein Blatt geht auf, wenn du \(GameState.petalRequirement) verschiedene Gegenstände dieser Stufe begriffen hast.")
                .font(.footnote)
                .foregroundStyle(Palette.textSecondary)
        }
        .cardStyle()
    }

    private func row(for strategy: RStrategy) -> some View {
        let done = state.has(strategy)
        let mastered = state.masteredCount(for: strategy)
        let needed = state.requirement(for: strategy)
        let finds = state.findingCount(for: strategy)

        return VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                UprightPetal(strategy: strategy)
                    .fill(done ? strategy.brandColor : Color.clear)
                    .overlay(
                        UprightPetal(strategy: strategy)
                            .stroke(done ? Color.clear : Palette.separator, lineWidth: 1.5)
                    )
                    .frame(width: 20, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(strategy.code) · \(strategy.title)")
                        .font(.headline)
                        .foregroundStyle(done ? Palette.textPrimary : Palette.textSecondary)
                    Text(strategy.term)
                        .font(.caption)
                        .foregroundStyle(Palette.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(mastered)/\(needed)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(done ? strategy.color : Palette.textSecondary)
                    if finds > 0 {
                        Text("\(finds) Funde")
                            .font(.caption2)
                            .foregroundStyle(Palette.textSecondary)
                    }
                }
            }

            if done {
                Text(strategy.summary)
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            } else {
                Text("Such nach: \(hintObjects(for: strategy))")
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
                    .italic()
            }
        }
        .cardStyle(done ? Palette.surface : Palette.surfaceMuted)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selected = strategy
            }
        }
    }

    /// Verrät, wonach man Ausschau halten kann. Ohne diesen Hinweis sucht man
    /// die letzten Stufen ewig.
    ///
    /// Seit dem Themennetz kommt eine R-Stufe aus sehr vielen Richtungen – der
    /// Hinweis nennt deshalb Themen und nicht einzelne Gegenstände.
    private func hintObjects(for strategy: RStrategy) -> String {
        let handwritten = ObjectCatalog.entries(for: strategy)
            .filter { !(state.masteredByStrategy[strategy.rawValue]?.contains($0.label) ?? false) }
            .prefix(2)
            .map(\.name)
        let themed = Theme.offering(strategy).prefix(2).map(\.searchHint)
        let all = handwritten + themed
        return all.isEmpty ? "irgendetwas, das dir begegnet" : all.joined(separator: ", ")
    }
}
