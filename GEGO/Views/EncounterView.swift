import SwiftUI
import UIKit

/// Das Blatt, das aufgeht, wenn man einen Fundpunkt antippt.
///
/// Welche Begegnung darin steht, ist schon beim Setzen des Punkts entschieden –
/// deshalb steht hier nur noch, wie sie aussieht.
struct EncounterView: View {

    let find: Find
    @ObservedObject var state: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header
                    stage
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

    @ViewBuilder
    private var stage: some View {
        switch find.encounter {
        case .quiz(let quiz):
            QuizStage(quiz: quiz) { finish(mastered: $0) }
        case .estimate(let estimate):
            EstimateStage(estimate: estimate) { finish(mastered: $0) }
        case .ordering(let ordering):
            OrderingStage(ordering: ordering) { finish(mastered: $0) }
        case .duel(let duel):
            DuelStage(duel: duel) { finish(mastered: $0) }
        case .hunt(let hunt):
            HuntStage(hunt: hunt) { accepted in
                if accepted { state.startHunt(hunt, credit: find) }
                dismiss()
            }
        case .cycle(let game):
            CycleStage(game: game) { finish(mastered: $0) }
        case .trueFalse(let run):
            TrueFalseStage(run: run) { finish(mastered: $0) }
        case .sorting(let game):
            SortingStage(game: game) { finish(mastered: $0) }
        case .oddOne(let game):
            OddOneStage(game: game) { finish(mastered: $0) }
        case .higherLower(let run):
            HigherLowerStage(run: run) { finish(mastered: $0) }
        case .timeline(let game):
            TimelineStage(game: game) { finish(mastered: $0) }
        case .memory(let game):
            MemoryStage(game: game) { finish(mastered: $0) }
        case .spotErrors(let game):
            SpotErrorsStage(game: game) { finish(mastered: $0) }
        case .budget(let game):
            BudgetStage(game: game) { finish(mastered: $0) }
        case .story(let story):
            StoryStage(story: story) { finish(mastered: true) }
        case .fact(let fact):
            FactStage(fact: fact) { finish(mastered: true) }
        case .mission(let mission):
            MissionStage(mission: mission) { finish(mastered: $0) }
        case .video(let tip):
            VideoStage(tip: tip) { finish(mastered: true) }
        }
    }

    // MARK: Kopf

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                UprightPetal(strategy: find.strategy)
                    .fill(find.strategy.brandColor)
                    .frame(width: 16, height: 26)
                Text("\(find.strategy.code) · \(find.strategy.title)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(find.subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Palette.textSecondary)
            }
            .foregroundStyle(find.strategy.color)

            Text(find.name)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)

            Text(find.strategy.summary)
                .font(.subheadline)
                .foregroundStyle(Palette.textSecondary)

            petalProgress
        }
    }

    /// Zeigt sofort, was dieser Fund für das Blatt bedeutet. Ohne das bleibt
    /// die Sammlung eine Zahl in einem anderen Bildschirm.
    private var petalProgress: some View {
        let done = state.masteredCount(for: find.strategy)
        let needed = state.requirement(for: find.strategy)
        return HStack(spacing: Spacing.xs) {
            ForEach(0..<needed, id: \.self) { index in
                Capsule()
                    .fill(index < done ? find.strategy.color : Palette.separator)
                    .frame(height: 4)
            }
            Text(done >= needed ? "Blatt offen" : "\(done)/\(needed)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(Palette.textSecondary)
                .padding(.leading, Spacing.xs)
        }
        .padding(.top, Spacing.xs)
    }

    private var sdgFooter: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeading(text: "Zahlt ein auf")
            ForEach(find.sdgs) { sdg in
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
        let wasOpen = state.has(find.strategy)
        state.record(find, mastered: mastered)

        // Ein Blatt, das gerade aufgegangen ist, darf sich anders anfühlen als
        // ein Fund unter vielen.
        if !wasOpen && state.has(find.strategy) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
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
                    Haptics.judge(index == quiz.correctIndex)
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
                    Haptics.judge(isClose)
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

// MARK: - Reihenfolge

/// Antippen statt Ziehen: Man tippt die Dinge in der vermuteten Reihenfolge an,
/// sie wandern nach oben. Das ist am Telefon deutlich sicherer zu bedienen als
/// Ziehen und Fallenlassen – und schneller, was bei einem Minispiel zählt.
private struct OrderingStage: View {
    let ordering: Ordering
    let onDone: (Bool) -> Void

    @State private var pool: [String] = []
    @State private var picked: [String] = []
    @State private var submitted = false

    private var isCorrect: Bool { picked == ordering.itemsInOrder }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(ordering.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            HStack {
                Text(ordering.lowLabel)
                Spacer()
                Image(systemName: "arrow.down")
                Spacer()
                Text(ordering.highLabel)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(Palette.textSecondary)

            VStack(spacing: Spacing.s) {
                ForEach(Array(picked.enumerated()), id: \.element) { index, item in
                    row(item, number: index + 1, state: rowState(for: item, at: index))
                        .onTapGesture {
                            guard !submitted else { return }
                            withAnimation {
                                picked.removeAll { $0 == item }
                                pool.append(item)
                            }
                        }
                }
            }

            if !pool.isEmpty {
                Divider().background(Palette.separator)
                VStack(spacing: Spacing.s) {
                    ForEach(pool, id: \.self) { item in
                        row(item, number: nil, state: .neutral)
                            .onTapGesture {
                                withAnimation {
                                    pool.removeAll { $0 == item }
                                    picked.append(item)
                                }
                            }
                    }
                }
            }

            if submitted {
                if !isCorrect {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Richtig wäre")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Palette.textSecondary)
                        ForEach(Array(ordering.itemsInOrder.enumerated()), id: \.element) { index, item in
                            Text("\(index + 1). \(item)")
                                .font(.footnote)
                                .foregroundStyle(Palette.textPrimary)
                        }
                    }
                    .cardStyle(Palette.surfaceMuted)
                }

                Resolution(
                    title: isCorrect ? "Genau die Reihenfolge" : "Fast",
                    text: ordering.explanation,
                    sourceHint: ordering.sourceHint,
                    accent: isCorrect ? Palette.accent : Palette.caution
                )
                Button("Weiter") { onDone(isCorrect) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button(pool.isEmpty ? "Prüfen" : "Tipp sie der Reihe nach an") {
                    withAnimation { submitted = true }
                    Haptics.judge(isCorrect)
                }
                .buttonStyle(CalmButtonStyle())
                .disabled(!pool.isEmpty)
                .opacity(pool.isEmpty ? 1 : 0.5)
            }
        }
        .onAppear {
            guard pool.isEmpty && picked.isEmpty else { return }
            // Gemischt, aber nie zufällig in der richtigen Reihenfolge.
            var shuffled = ordering.itemsInOrder.shuffled()
            if shuffled == ordering.itemsInOrder { shuffled.reverse() }
            pool = shuffled
        }
    }

    private enum RowState { case neutral, right, wrong }

    private func rowState(for item: String, at index: Int) -> RowState {
        guard submitted else { return .neutral }
        return ordering.itemsInOrder.firstIndex(of: item) == index ? .right : .wrong
    }

    private func row(_ item: String, number: Int?, state: RowState) -> some View {
        HStack(spacing: Spacing.s) {
            if let number {
                Text("\(number)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 18)
            } else {
                Image(systemName: "plus.circle")
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 18)
            }
            Text(item)
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            if state == .right { Image(systemName: "checkmark").foregroundStyle(Palette.accent) }
            if state == .wrong { Image(systemName: "xmark").foregroundStyle(Palette.caution) }
        }
        .cardStyle(background(for: state))
        .contentShape(Rectangle())
    }

    private func background(for state: RowState) -> Color {
        switch state {
        case .neutral: return Palette.surface
        case .right: return Palette.accentSurface
        case .wrong: return Palette.cautionSurface
        }
    }
}

// MARK: - Duell

private struct DuelStage: View {
    let duel: Duel
    let onDone: (Bool) -> Void

    @State private var chosenA: Bool?

    private var wasRight: Bool { chosenA == duel.betterIsA }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(duel.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            card(duel.optionA, isA: true)
            Text("oder")
                .font(.caption.weight(.medium))
                .foregroundStyle(Palette.textSecondary)
                .frame(maxWidth: .infinity)
            card(duel.optionB, isA: false)

            if chosenA != nil {
                Resolution(
                    title: wasRight ? "Richtig entschieden" : "Der andere Weg wäre besser",
                    text: duel.explanation,
                    sourceHint: duel.sourceHint,
                    accent: wasRight ? Palette.accent : Palette.caution
                )
                Button("Weiter") { onDone(wasRight) }
                    .buttonStyle(CalmButtonStyle())
            }
        }
    }

    private func card(_ text: String, isA: Bool) -> some View {
        Button {
            guard chosenA == nil else { return }
            withAnimation { chosenA = isA }
            Haptics.judge(isA == duel.betterIsA)
        } label: {
            HStack(alignment: .top, spacing: Spacing.s) {
                Text(text)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                if chosenA != nil {
                    Image(systemName: isA == duel.betterIsA ? "checkmark" : "xmark")
                        .foregroundStyle(isA == duel.betterIsA ? Palette.accent : Palette.caution)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(background(isA: isA))
        }
        .buttonStyle(.plain)
    }

    private func background(isA: Bool) -> Color {
        guard let chosenA else { return Palette.surface }
        if isA == duel.betterIsA { return Palette.accentSurface }
        if isA == chosenA { return Palette.alertSurface }
        return Palette.surface
    }
}

// MARK: - Jagd

private struct HuntStage: View {
    let hunt: Hunt
    let onDecide: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(hunt.prompt)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            HStack(spacing: Spacing.l) {
                stat(value: "\(hunt.count)", label: "verschiedene")
                stat(value: "\(hunt.seconds)s", label: "Zeit")
            }
            .frame(maxWidth: .infinity)
            .cardStyle()

            Text("Es zählt, was die Kamera erkennt – nicht, was du antippst. Halt sie einfach auf die Dinge.")
                .font(.footnote)
                .foregroundStyle(Palette.textSecondary)

            Button("Los") { onDecide(true) }
                .buttonStyle(CalmButtonStyle())
            Button("Diesmal nicht") { onDecide(false) }
                .buttonStyle(CalmButtonStyle(prominent: false))
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(Palette.accent)
            Text(label)
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)
        }
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

struct Resolution: View {
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
struct SourceNote: View {
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

enum Haptics {
    /// Richtig und falsch dürfen sich unterschiedlich anfühlen – das ist die
    /// billigste Rückmeldung, die ein Spiel geben kann.
    static func judge(_ correct: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(correct ? .success : .warning)
    }
}
