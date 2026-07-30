import SwiftUI

/// Die Sammlung: zehn Stufen, die sich füllen. Der Bogen, der über Wochen
/// trägt – eine Lücke zieht stärker als jede Punktzahl.
struct CollectionView: View {

    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.m) {
                    summary
                    ForEach(RStrategy.allCases) { strategy in
                        row(for: strategy)
                    }
                    Text("Die Leiter geht von oben nach unten: Was oben verhindert wird, muss unten nicht verwertet werden.")
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                        .padding(.top, Spacing.s)
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
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(state.understood.count) von \(RStrategy.allCases.count)")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text("\(state.points) Punkte")
                    .font(.headline)
                    .foregroundStyle(Palette.accent)
            }
            ProgressView(value: state.collectionProgress)
                .tint(Palette.accent)
            Text("Stufen, die du mindestens einmal richtig beantwortet hast.")
                .font(.footnote)
                .foregroundStyle(Palette.textSecondary)
        }
        .cardStyle()
    }

    private func row(for strategy: RStrategy) -> some View {
        let done = state.has(strategy)
        let finds = state.findingCount(for: strategy)

        return VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Image(systemName: done ? strategy.symbolName : "circle.dotted")
                    .font(.title3)
                    .foregroundStyle(done ? strategy.color : Palette.textSecondary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(strategy.code) · \(strategy.title)")
                        .font(.headline)
                        .foregroundStyle(done ? Palette.textPrimary : Palette.textSecondary)
                    Text(strategy.term)
                        .font(.caption)
                        .foregroundStyle(Palette.textSecondary)
                }

                Spacer()

                if finds > 0 {
                    Text("\(finds)×")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            if done {
                Text(strategy.summary)
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
            } else {
                Text("Noch nicht begriffen. Such nach: \(hintObjects(for: strategy))")
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
                    .italic()
            }
        }
        .cardStyle(done ? Palette.surface : Palette.surfaceMuted)
    }

    /// Verrät, wonach man Ausschau halten kann. Ohne diesen Hinweis sucht man
    /// die letzten Stufen ewig.
    private func hintObjects(for strategy: RStrategy) -> String {
        ObjectCatalog.entries(for: strategy)
            .prefix(3)
            .map(\.name)
            .joined(separator: ", ")
    }
}
