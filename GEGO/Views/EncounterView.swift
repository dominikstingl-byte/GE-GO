import SwiftUI

/// Das Blatt, das aufgeht, wenn man einen Fundpunkt antippt.
struct EncounterView: View {

    let entry: CatalogEntry
    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    /// Welche Begegnung dran ist, hängt davon ab, wie oft dieser Gegenstand
    /// schon gefunden wurde.
    private var encounter: Encounter {
        entry.encounter(forVisit: state.findings[entry.label] ?? 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header

                    switch encounter {
                    case .quiz(let quiz):
                        QuizStage(quiz: quiz) { correct in finish(mastered: correct) }
                    case .estimate(let estimate):
                        EstimateStage(estimate: estimate) { correct in finish(mastered: correct) }
                    case .story(let story):
                        StoryStage(story: story) { finish(mastered: true) }
                    case .fact(let fact):
                        FactStage(fact: fact) { finish(mastered: true) }
                    case .mission(let mission):
                        MissionStage(mission: mission) { accepted in finish(mastered: accepted) }
                    case .video(let tip):
                        VideoStage(tip: tip) { finish(mastered: true) }
                    }

                    sdgFooter
                }
                .padding(Spacing.m)
                .readableWidth()
            }
            .background(Palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Später") { dismiss() }
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        }
    }

    // MARK: Kopf

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Image(systemName: entry.strategy.symbolName)
                Text("\(entry.strategy.code) · \(entry.strategy.title)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(encounter.kindLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Palette.textSecondary)
            }
            .foregroundStyle(entry.strategy.color)

            Text(entry.name)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)

            Text(entry.strategy.summary)
                .font(.subheadline)
                .foregroundStyle(Palette.textSecondary)
        }
    }

    private var sdgFooter: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Zahlt ein auf")
            ForEach(entry.sdgs) { sdg in
                HStack(spacing: Spacing.s) {
                    Image(systemName: sdg.symbolName)
                        .foregroundStyle(Palette.accent)
                        .frame(width: 22)
                    Text("\(sdg.code) · \(sdg.title)")
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        }
        .padding(.top, Spacing.s)
    }

    private func finish(mastered: Bool) {
        state.record(entry, mastered: mastered)
        dismiss()
    }
}

// MARK: - Frage

private struct QuizStage: View {
    let quiz: Quiz
    let onDone: (Bool) -> Void

    @State private var chosen: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(quiz.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            ForEach(quiz.options.indices, id: \.self) { index in
                Button {
                    guard chosen == nil else { return }
                    withAnimation { chosen = index }
                } label: {
                    HStack {
                        Text(quiz.options[index])
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let chosen {
                            if index == quiz.correctIndex {
                                Image(systemName: "checkmark")
                            } else if index == chosen {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    .font(.body)
                    .foregroundStyle(Palette.textPrimary)
                    .cardStyle(background(for: index))
                }
                .buttonStyle(.plain)
            }

            if let chosen {
                Resolution(
                    title: chosen == quiz.correctIndex ? "Richtig" : "Knapp daneben",
                    text: quiz.explanation,
                    sourceHint: quiz.sourceHint,
                    accent: chosen == quiz.correctIndex ? Palette.accent : Palette.caution
                )
                Button("Weiter") { onDone(chosen == quiz.correctIndex) }
                    .buttonStyle(CalmButtonStyle())
            }
        }
    }

    private func background(for index: Int) -> Color {
        guard let chosen else { return Palette.surface }
        if index == quiz.correctIndex { return Palette.accentSurface }
        if index == chosen { return Palette.alertSurface }
        return Palette.surface
    }
}

// MARK: - Schätzung

private struct EstimateStage: View {
    let estimate: Estimate
    let onDone: (Bool) -> Void

    @State private var value: Double = 0
    @State private var submitted = false

    private var span: Double { estimate.range.upperBound - estimate.range.lowerBound }
    private var isClose: Bool { abs(value - estimate.answer) <= span * estimate.tolerance }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(estimate.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            VStack(spacing: Spacing.s) {
                Text(format(value))
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .foregroundStyle(submitted ? Palette.textSecondary : Palette.accent)
                    .contentTransition(.numericText())

                Slider(value: $value, in: estimate.range)
                    .tint(Palette.accent)
                    .disabled(submitted)

                HStack {
                    Text(format(estimate.range.lowerBound))
                    Spacer()
                    Text(format(estimate.range.upperBound))
                }
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
            }
            .cardStyle()

            if submitted {
                HStack(spacing: Spacing.s) {
                    Image(systemName: isClose ? "target" : "arrow.left.arrow.right")
                    Text("Richtig sind \(format(estimate.answer))")
                        .font(.headline)
                }
                .foregroundStyle(isClose ? Palette.accent : Palette.caution)

                Resolution(
                    title: isClose ? "Gut geschätzt" : "Weiter daneben als gedacht",
                    text: estimate.explanation,
                    sourceHint: estimate.sourceHint,
                    accent: isClose ? Palette.accent : Palette.caution
                )
                Button("Weiter") { onDone(isClose) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button("Das ist meine Schätzung") {
                    withAnimation { submitted = true }
                }
                .buttonStyle(CalmButtonStyle())
            }
        }
        .onAppear {
            // In der Mitte starten, damit die Startstellung keinen Hinweis gibt.
            value = (estimate.range.lowerBound + estimate.range.upperBound) / 2
        }
    }

    private func format(_ number: Double) -> String {
        let rounded = number < 10 ? String(format: "%.1f", number) : String(Int(number.rounded()))
        return "\(rounded) \(estimate.unit)"
    }
}

// MARK: - Geschichte

private struct StoryStage: View {
    let story: Story
    let onDone: () -> Void

    /// Absatz für Absatz, damit die Wendung am Ende auch ankommt.
    @State private var shown = 1

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(story.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)

            ForEach(0..<shown, id: \.self) { index in
                Text(story.paragraphs[index])
                    .font(.body)
                    .foregroundStyle(Palette.textPrimary)
                    .transition(.opacity)
            }

            if let hint = story.sourceHint, shown == story.paragraphs.count {
                SourceNote(hint: hint)
            }

            if shown < story.paragraphs.count {
                Button("Weiter") {
                    withAnimation { shown += 1 }
                }
                .buttonStyle(CalmButtonStyle(prominent: false))
            } else {
                Button("Verstanden") { onDone() }
                    .buttonStyle(CalmButtonStyle())
            }
        }
    }
}

// MARK: - Gewusst

private struct FactStage: View {
    let fact: Fact
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(fact.text)
                .font(.title3)
                .foregroundStyle(Palette.textPrimary)
            if let hint = fact.sourceHint {
                SourceNote(hint: hint)
            }
            Button("Mitgenommen") { onDone() }
                .buttonStyle(CalmButtonStyle())
        }
    }
}

// MARK: - Auftrag

private struct MissionStage: View {
    let mission: Mission
    let onDone: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(mission.prompt)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            HStack(alignment: .top, spacing: Spacing.s) {
                Image(systemName: "lightbulb")
                Text(mission.hint)
            }
            .font(.footnote)
            .foregroundStyle(Palette.textSecondary)
            .cardStyle(Palette.surfaceMuted)

            Button("Mach ich") { onDone(true) }
                .buttonStyle(CalmButtonStyle())
            Button("Diesmal nicht") { onDone(false) }
                .buttonStyle(CalmButtonStyle(prominent: false))
        }
    }
}

// MARK: - Video

private struct VideoStage: View {
    let tip: VideoTip
    let onDone: () -> Void

    /// Suche statt fester Adresse: Links veralten, Suchbegriffe nicht.
    private var searchURL: URL? {
        var components = URLComponents(string: "https://www.youtube.com/results")
        components?.queryItems = [URLQueryItem(name: "search_query", value: tip.searchTerm)]
        return components?.url
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(tip.why)
                .font(.title3)
                .foregroundStyle(Palette.textPrimary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                SectionHeading(text: "Suchbegriff")
                Text(tip.searchTerm)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
            }
            .cardStyle(Palette.surfaceMuted)

            if let searchURL {
                Link(destination: searchURL) {
                    Text("Danach suchen")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: Layout.minTapTarget)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                                .fill(Palette.accent)
                        )
                }
            }

            Button("Später anschauen") { onDone() }
                .buttonStyle(CalmButtonStyle(prominent: false))
        }
    }
}

// MARK: - Gemeinsame Bausteine

private struct Resolution: View {
    let title: String
    let text: String
    var sourceHint: String?
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.headline)
                .foregroundStyle(accent)
            Text(text)
                .font(.body)
                .foregroundStyle(Palette.textPrimary)
            if let sourceHint {
                SourceNote(hint: sourceHint)
            }
        }
        .cardStyle()
    }
}

/// Merkzettel, keine Quellenangabe. Steht bewusst sichtbar in der App,
/// solange die Inhalte Entwürfe sind.
private struct SourceNote: View {
    let hint: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.triangle")
            Text("Noch zu prüfen: \(hint)")
        }
        .font(.caption)
        .foregroundStyle(Palette.caution)
    }
}
