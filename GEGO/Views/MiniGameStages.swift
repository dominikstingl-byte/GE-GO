import SwiftUI
import UIKit

// Die zehn Minispiele. Getrennt von EncounterView, weil das sonst niemand
// mehr liest.
//
// Gemeinsame Linie: Erst spielen, dann auflösen, dann „Weiter“. Kein Spiel
// bewertet stillschweigend – die Auflösung ist der eigentliche Inhalt, das
// Spiel ist nur der Anlass, sie sehen zu wollen.

// MARK: - 1 Kreislauf schließen

/// Stationen im Ring. Die Kreisform ist nicht Zierrat: Sie ist die Aussage.
/// Wer die Stationen in eine Linie legt, hat eine Lieferkette; wer sie in
/// einen Ring legt, einen Kreislauf.
struct CycleStage: View {
    let game: CycleGame
    let onDone: (Bool) -> Void

    @State private var pool: [String] = []
    @State private var picked: [String] = []
    @State private var submitted = false

    private var isCorrect: Bool { picked == game.stationsInOrder }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            ring

            if !pool.isEmpty {
                VStack(spacing: Spacing.s) {
                    ForEach(pool, id: \.self) { station in
                        Button {
                            withAnimation {
                                pool.removeAll { $0 == station }
                                picked.append(station)
                            }
                        } label: {
                            Text(station)
                                .font(.body)
                                .foregroundStyle(Palette.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if submitted {
                if !isCorrect {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Der Kreis läuft so")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Palette.textSecondary)
                        Text(game.stationsInOrder.joined(separator: "  →  "))
                            .font(.footnote)
                            .foregroundStyle(Palette.textPrimary)
                    }
                    .cardStyle(Palette.surfaceMuted)
                }
                Resolution(title: isCorrect ? "Kreis geschlossen" : "Fast im Kreis",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: isCorrect ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(isCorrect) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button(pool.isEmpty ? "Prüfen" : "Tipp die Stationen der Reihe nach an") {
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
            var shuffled = game.stationsInOrder.shuffled()
            if shuffled == game.stationsInOrder { shuffled.reverse() }
            pool = shuffled
        }
    }

    private var ring: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let radius = side / 2 - 44
            let center = CGPoint(x: geo.size.width / 2, y: side / 2)
            ZStack {
                Circle()
                    .stroke(Palette.separator, style: StrokeStyle(lineWidth: 2, dash: [5, 6]))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)

                ForEach(Array(game.stationsInOrder.indices), id: \.self) { index in
                    let angle = Double(index) / Double(game.stationsInOrder.count) * 2 * .pi - .pi / 2
                    slot(at: index)
                        .position(x: center.x + radius * cos(angle),
                                  y: center.y + radius * sin(angle))
                }
            }
        }
        .frame(height: 240)
    }

    private func slot(at index: Int) -> some View {
        let filled = index < picked.count
        let name = filled ? picked[index] : "\(index + 1)"
        let right = submitted && filled && picked[index] == game.stationsInOrder[index]
        let wrong = submitted && filled && !right

        return Text(name)
            .font(.caption.weight(filled ? .semibold : .regular))
            .multilineTextAlignment(.center)
            .foregroundStyle(filled ? Palette.textPrimary : Palette.textSecondary)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs)
            .frame(width: 92)
            .background(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .fill(wrong ? Palette.alertSurface : (right ? Palette.accentSurface
                                                          : (filled ? Palette.surface : Palette.surfaceMuted)))
            )
            .onTapGesture {
                guard !submitted, filled else { return }
                withAnimation {
                    let station = picked.remove(at: index)
                    pool.append(station)
                }
            }
    }
}

// MARK: - 2 Wahr oder falsch

/// Die einzige Stelle im Spiel mit Zeitdruck. Ein Fehler beendet den Lauf –
/// das macht den Unterschied zwischen einer Fragereihe und einem Spiel.
struct TrueFalseStage: View {
    let run: TrueFalseRun
    let onDone: (Bool) -> Void

    @State private var index = 0
    @State private var remaining = 0
    @State private var answer: Bool?
    @State private var finished = false
    @State private var correctCount = 0

    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var current: TrueFalseItem { run.statements[min(index, run.statements.count - 1)] }
    private var survived: Bool { correctCount == run.statements.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if finished {
                Resolution(title: survived ? "Alle \(run.statements.count) geschafft"
                                           : "Bis \(correctCount) von \(run.statements.count)",
                           text: current.explanation,
                           sourceHint: current.sourceHint,
                           accent: survived ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(survived) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                header
                Text(current.text)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .cardStyle()

                if let answer {
                    let right = answer == current.isTrue
                    Resolution(title: right ? "Stimmt" : "Stimmt nicht",
                               text: current.explanation,
                               sourceHint: current.sourceHint,
                               accent: right ? Palette.accent : Palette.caution)
                    Button(right && index + 1 < run.statements.count ? "Nächste" : "Auflösen") {
                        advance(afterCorrect: right)
                    }
                    .buttonStyle(CalmButtonStyle())
                } else {
                    HStack(spacing: Spacing.s) {
                        choice("Stimmt", value: true)
                        choice("Stimmt nicht", value: false)
                    }
                }
            }
        }
        .onAppear { remaining = run.seconds }
        .onReceive(clock) { _ in
            guard !finished, answer == nil else { return }
            if remaining > 0 { remaining -= 1 } else { pick(!current.isTrue) }   // Zeit abgelaufen = falsch
        }
    }

    private var header: some View {
        HStack {
            Text("\(index + 1) von \(run.statements.count)")
                .font(.caption.weight(.medium))
                .foregroundStyle(Palette.textSecondary)
            Spacer()
            Text("\(remaining)s")
                .font(.callout.weight(.semibold).monospacedDigit())
                .foregroundStyle(remaining <= 3 ? Palette.caution : Palette.textSecondary)
        }
    }

    private func choice(_ title: String, value: Bool) -> some View {
        Button { pick(value) } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(Palette.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Layout.minTapTarget)
                .background(RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .fill(Palette.surface))
        }
        .buttonStyle(.plain)
    }

    private func pick(_ value: Bool) {
        withAnimation { answer = value }
        let right = value == current.isTrue
        if right { correctCount += 1 }
        Haptics.judge(right)
    }

    private func advance(afterCorrect right: Bool) {
        guard right, index + 1 < run.statements.count else {
            withAnimation { finished = true }
            return
        }
        withAnimation {
            index += 1
            answer = nil
            remaining = run.seconds
        }
    }
}

// MARK: - 3 Tonne treffen

struct SortingStage: View {
    let game: SortingGame
    let onDone: (Bool) -> Void

    @State private var assignment: [Int: Int] = [:]     // Gegenstand → Tonne
    @State private var selected: Int?
    @State private var submitted = false

    private var allPlaced: Bool { assignment.count == game.items.count }
    private var rightCount: Int {
        game.items.indices.filter { assignment[$0] == game.items[$0].binIndex }.count
    }
    private var isCorrect: Bool { rightCount == game.items.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            Text(submitted ? "" : "Erst den Gegenstand antippen, dann die Tonne.")
                .font(.caption)
                .foregroundStyle(Palette.textSecondary)

            VStack(spacing: Spacing.s) {
                ForEach(game.items.indices, id: \.self) { index in
                    itemRow(index)
                }
            }

            if !submitted {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: Spacing.s)],
                          spacing: Spacing.s) {
                    ForEach(game.bins.indices, id: \.self) { bin in
                        Button {
                            guard let selected else { return }
                            withAnimation {
                                assignment[selected] = bin
                                self.selected = nil
                            }
                        } label: {
                            Text(game.bins[bin])
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Palette.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .background(RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                                    .fill(selected == nil ? Palette.surfaceMuted : Palette.accentSurface))
                        }
                        .buttonStyle(.plain)
                        .disabled(selected == nil)
                    }
                }
            }

            if submitted {
                Resolution(title: isCorrect ? "Alles richtig einsortiert"
                                            : "\(rightCount) von \(game.items.count) richtig",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: isCorrect ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(isCorrect) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button("Prüfen") {
                    withAnimation { submitted = true }
                    Haptics.judge(isCorrect)
                }
                .buttonStyle(CalmButtonStyle())
                .disabled(!allPlaced)
                .opacity(allPlaced ? 1 : 0.5)
            }
        }
    }

    private func itemRow(_ index: Int) -> some View {
        let item = game.items[index]
        let bin = assignment[index]
        let right = submitted && bin == item.binIndex

        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Spacing.s) {
                Text(item.name)
                    .font(.body)
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                if let bin {
                    Text(game.bins[bin])
                        .font(.caption.weight(.medium))
                        .foregroundStyle(submitted ? (right ? Palette.accent : Palette.caution)
                                                   : Palette.textSecondary)
                }
                if submitted {
                    Image(systemName: right ? "checkmark" : "xmark")
                        .foregroundStyle(right ? Palette.accent : Palette.caution)
                }
            }
            if submitted && !right {
                Text("→ \(game.bins[item.binIndex]): \(item.note)")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
        .cardStyle(background(index))
        .contentShape(Rectangle())
        .onTapGesture {
            guard !submitted else { return }
            withAnimation { selected = (selected == index) ? nil : index }
        }
    }

    private func background(_ index: Int) -> Color {
        if submitted { return assignment[index] == game.items[index].binIndex
            ? Palette.accentSurface : Palette.alertSurface }
        return selected == index ? Palette.accentSurface : Palette.surface
    }
}

// MARK: - 4 Ausreißer

struct OddOneStage: View {
    let game: OddOne
    let onDone: (Bool) -> Void

    @State private var chosen: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.s),
                                GridItem(.flexible(), spacing: Spacing.s)],
                      spacing: Spacing.s) {
                ForEach(game.options.indices, id: \.self) { index in
                    Button {
                        guard chosen == nil else { return }
                        withAnimation { chosen = index }
                        Haptics.judge(index == game.oddIndex)
                    } label: {
                        Text(game.options[index])
                            .font(.body.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 76)
                            .background(RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                                .fill(background(index)))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let chosen {
                Resolution(title: chosen == game.oddIndex ? "Genau der" : "Der gehört dazu",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: chosen == game.oddIndex ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(chosen == game.oddIndex) }
                    .buttonStyle(CalmButtonStyle())
            }
        }
    }

    private func background(_ index: Int) -> Color {
        guard let chosen else { return Palette.surface }
        if index == game.oddIndex { return Palette.accentSurface }
        if index == chosen { return Palette.alertSurface }
        return Palette.surface
    }
}

// MARK: - 5 Höher oder tiefer

struct HigherLowerStage: View {
    let run: HigherLowerRun
    let onDone: (Bool) -> Void

    @State private var index = 0
    @State private var chosenA: Bool?
    @State private var finished = false
    @State private var correctCount = 0

    private var pair: HigherLowerPair { run.pairs[min(index, run.pairs.count - 1)] }
    private var survived: Bool { correctCount == run.pairs.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if finished {
                Resolution(title: survived ? "Alle \(run.pairs.count) richtig"
                                           : "Bis \(correctCount) von \(run.pairs.count)",
                           text: pair.explanation,
                           sourceHint: pair.sourceHint,
                           accent: survived ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(survived) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                HStack {
                    Text(run.intro)
                    Spacer()
                    Text("\(index + 1) von \(run.pairs.count)")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(Palette.textSecondary)
                Text(pair.question)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)

                card(pair.optionA, isA: true)
                card(pair.optionB, isA: false)

                if let chosenA {
                    let right = chosenA == pair.aIsLarger
                    Resolution(title: right ? "Richtig" : "Andersherum",
                               text: pair.explanation,
                               sourceHint: pair.sourceHint,
                               accent: right ? Palette.accent : Palette.caution)
                    Button(right && index + 1 < run.pairs.count ? "Nächste" : "Auflösen") {
                        guard right, index + 1 < run.pairs.count else {
                            withAnimation { finished = true }
                            return
                        }
                        withAnimation { index += 1; self.chosenA = nil }
                    }
                    .buttonStyle(CalmButtonStyle())
                }
            }
        }
    }

    private func card(_ text: String, isA: Bool) -> some View {
        Button {
            guard chosenA == nil else { return }
            withAnimation { chosenA = isA }
            let right = isA == pair.aIsLarger
            if right { correctCount += 1 }
            Haptics.judge(right)
        } label: {
            HStack {
                Text(text)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                if chosenA != nil {
                    Image(systemName: isA == pair.aIsLarger ? "arrow.up" : "arrow.down")
                        .foregroundStyle(isA == pair.aIsLarger ? Palette.accent : Palette.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(background(isA: isA))
        }
        .buttonStyle(.plain)
    }

    private func background(isA: Bool) -> Color {
        guard let chosenA else { return Palette.surface }
        if isA == pair.aIsLarger { return Palette.accentSurface }
        if isA == chosenA { return Palette.alertSurface }
        return Palette.surface
    }
}

// MARK: - 6 Zeitstrahl

/// Logarithmisch, weil die Spanne von Tagen bis Jahrhunderten reicht. Auf
/// einem linearen Regler läge alles unter fünfzig Jahren im ersten Millimeter –
/// und genau die Wahrnehmung, dass „lange“ sehr verschiedene Dinge heißt, ist
/// das Ziel des Spiels.
struct TimelineStage: View {
    let game: TimelineGame
    let onDone: (Bool) -> Void

    /// Von einer Woche bis zur Obergrenze des Spiels, in Zehnerpotenzen von Tagen.
    private let lower = log10(7.0)
    private var upper: Double { log10(365.0 * game.maxYears) }

    @State private var value: Double = 0
    @State private var submitted = false

    private var guessedDays: Double { pow(10, value) }
    private var isClose: Bool {
        let factor = guessedDays / game.answerDays
        return factor >= 1 / game.tolerance && factor <= game.tolerance
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            Text(game.item)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Palette.accent)

            VStack(spacing: Spacing.s) {
                Text(spell(guessedDays))
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(submitted ? Palette.textSecondary : Palette.accent)
                    .contentTransition(.numericText())

                Slider(value: $value, in: lower...upper)
                    .tint(Palette.accent)
                    .disabled(submitted)

                HStack {
                    Text("Woche")
                    Spacer()
                    Text("Jahr")
                    Spacer()
                    Text(spell(365 * game.maxYears))
                }
                .font(.caption2)
                .foregroundStyle(Palette.textSecondary)
            }
            .cardStyle()

            if submitted {
                HStack(spacing: Spacing.s) {
                    Image(systemName: isClose ? "target" : "arrow.left.arrow.right")
                    Text("Richtig sind etwa \(spell(game.answerDays))")
                        .font(.headline)
                }
                .foregroundStyle(isClose ? Palette.accent : Palette.caution)

                Resolution(title: isClose ? "Gut eingeordnet" : "Andere Größenordnung",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: isClose ? Palette.accent : Palette.caution)
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
        .onAppear { value = (lower + upper) / 2 }
    }

    /// Tage in etwas, das ein Mensch fühlt.
    private func spell(_ days: Double) -> String {
        switch days {
        case ..<14: return "\(Int(days.rounded())) Tage"
        case ..<70: return "\(Int((days / 7).rounded())) Wochen"
        case ..<730: return "\(Int((days / 30.4).rounded())) Monate"
        case ..<36_500: return "\(Int((days / 365).rounded())) Jahre"
        case ..<365_000: return "\(Int((days / 365 / 100).rounded())) Jahrhunderte"
        default: return "\(Int((days / 365 / 1000).rounded())) Jahrtausende"
        }
    }
}

// MARK: - 7 Blüten-Memory

/// Das einzige Spiel, in dem Marke und Mechanik zusammenfallen: Das
/// Spielmaterial sind die Blütenblätter selbst. Die zehn Stufen prägen sich
/// beim Suchen ein, ohne dass jemand sie lernt.
struct MemoryStage: View {
    let game: MemoryGame
    let onDone: (Bool) -> Void

    private struct Card: Identifiable {
        let id: Int
        let strategy: RStrategy
        /// Blattseite oder Textseite – jedes Paar hat eine von beiden.
        let showsPetal: Bool
    }

    @State private var cards: [Card] = []
    @State private var faceUp: Set<Int> = []
    @State private var matched: Set<Int> = []
    @State private var attempts = 0
    @State private var busy = false

    /// Bestanden, wer nicht mehr als das Doppelte der Paare braucht.
    private var allowedAttempts: Int { game.strategies.count * 2 }
    private var done: Bool { matched.count == cards.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.intro)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            HStack {
                Text("Versuche: \(attempts)")
                Spacer()
                Text("höchstens \(allowedAttempts)")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(attempts > allowedAttempts ? Palette.caution : Palette.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.s), count: 4),
                      spacing: Spacing.s) {
                ForEach(cards) { card in
                    face(card)
                        .onTapGesture { flip(card) }
                }
            }

            if done {
                Resolution(title: attempts <= allowedAttempts ? "Alle Paare gefunden"
                                                              : "Gefunden – mit \(attempts) Versuchen",
                           text: game.explanation,
                           sourceHint: nil,
                           accent: attempts <= allowedAttempts ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(attempts <= allowedAttempts) }
                    .buttonStyle(CalmButtonStyle())
            }
        }
        .onAppear(perform: deal)
    }

    private func face(_ card: Card) -> some View {
        let open = faceUp.contains(card.id) || matched.contains(card.id)
        return ZStack {
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .fill(open ? Palette.surface : Palette.surfaceMuted)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                        .stroke(matched.contains(card.id) ? Palette.accent : Palette.separator,
                                lineWidth: matched.contains(card.id) ? 2 : 1)
                )
            if open {
                if card.showsPetal {
                    UprightPetal(strategy: card.strategy)
                        .fill(card.strategy.brandColor)
                        .padding(Spacing.s)
                } else {
                    VStack(spacing: 1) {
                        Text(card.strategy.code)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(card.strategy.color)
                        Text(card.strategy.title)
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Palette.textPrimary)
                    }
                    .padding(2)
                }
            } else {
                Image(systemName: "questionmark")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
        .aspectRatio(0.78, contentMode: .fit)
    }

    private func deal() {
        guard cards.isEmpty else { return }
        var built: [Card] = []
        for (index, strategy) in game.strategies.enumerated() {
            built.append(Card(id: index * 2, strategy: strategy, showsPetal: true))
            built.append(Card(id: index * 2 + 1, strategy: strategy, showsPetal: false))
        }
        cards = built.shuffled()
    }

    private func flip(_ card: Card) {
        guard !busy, !matched.contains(card.id), !faceUp.contains(card.id), !done else { return }
        withAnimation { _ = faceUp.insert(card.id) }

        guard faceUp.count == 2 else { return }
        attempts += 1
        let open = cards.filter { faceUp.contains($0.id) }
        if open.count == 2 && open[0].strategy == open[1].strategy {
            withAnimation {
                matched.formUnion(faceUp)
                faceUp.removeAll()
            }
            Haptics.judge(true)
        } else {
            busy = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation { faceUp.removeAll() }
                busy = false
            }
        }
    }
}

// MARK: - 8 Fehlersuche

struct SpotErrorsStage: View {
    let game: SpotErrors
    let onDone: (Bool) -> Void

    @State private var picked: Set<Int> = []
    @State private var submitted = false

    private var wrongIndices: Set<Int> {
        Set(game.statements.indices.filter { game.statements[$0].isWrong })
    }
    private var isCorrect: Bool { picked == wrongIndices }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.scene)
                .font(.body)
                .foregroundStyle(Palette.textSecondary)
                .cardStyle(Palette.surfaceMuted)

            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            VStack(spacing: Spacing.s) {
                ForEach(game.statements.indices, id: \.self) { index in
                    row(index)
                }
            }

            if submitted {
                Resolution(title: isCorrect ? "Alle gefunden, keine zu viel"
                                            : "Nicht ganz",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: isCorrect ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(isCorrect) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button("Prüfen") {
                    withAnimation { submitted = true }
                    Haptics.judge(isCorrect)
                }
                .buttonStyle(CalmButtonStyle())
                .disabled(picked.isEmpty)
                .opacity(picked.isEmpty ? 0.5 : 1)
            }
        }
    }

    private func row(_ index: Int) -> some View {
        let statement = game.statements[index]
        let chosen = picked.contains(index)
        let right = submitted && (chosen == statement.isWrong)

        return HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: chosen ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(chosen ? Palette.accent : Palette.textSecondary)
            Text(statement.text)
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            if submitted {
                Image(systemName: right ? "checkmark" : "xmark")
                    .foregroundStyle(right ? Palette.accent : Palette.caution)
            }
        }
        .cardStyle(submitted ? (right ? Palette.accentSurface : Palette.alertSurface)
                             : Palette.surface)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !submitted else { return }
            withAnimation {
                if chosen { picked.remove(index) } else { picked.insert(index) }
            }
        }
    }
}

// MARK: - 9 Budget verteilen

/// Das inhaltlich stärkste Format: Es fragt nicht, ob eine Maßnahme wirkt,
/// sondern wie viel sie wiegt. Genau daran scheitert die Alltagsintuition –
/// Mülltrennen und Flugverzicht fühlen sich beide nach „etwas tun“ an.
struct BudgetStage: View {
    let game: BudgetGame
    let onDone: (Bool) -> Void

    @State private var shares: [Double] = []
    @State private var submitted = false

    private var spent: Double { shares.reduce(0, +) }
    private var remaining: Double { max(0, 100 - spent) }

    /// Bestanden, wer die wirksamste Maßnahme am höchsten gewichtet hat.
    private var isCorrect: Bool {
        guard let mine = shares.indices.max(by: { shares[$0] < shares[$1] }),
              let truth = game.options.indices.max(by: { game.options[$0].weight < game.options[$1].weight })
        else { return false }
        return mine == truth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(game.question)
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.textPrimary)

            HStack {
                Text("Noch zu verteilen")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
                Spacer()
                Text("\(Int(remaining))")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(remaining == 0 ? Palette.accent : Palette.textPrimary)
            }

            ForEach(game.options.indices, id: \.self) { index in
                option(index)
            }

            if submitted {
                Resolution(title: isCorrect ? "Schwerpunkt richtig gesetzt"
                                            : "Der Schwerpunkt liegt woanders",
                           text: game.explanation,
                           sourceHint: game.sourceHint,
                           accent: isCorrect ? Palette.accent : Palette.caution)
                Button("Weiter") { onDone(isCorrect) }
                    .buttonStyle(CalmButtonStyle())
            } else {
                Button("So verteile ich") {
                    withAnimation { submitted = true }
                    Haptics.judge(isCorrect)
                }
                .buttonStyle(CalmButtonStyle())
                .disabled(spent < 99)
                .opacity(spent < 99 ? 0.5 : 1)
            }
        }
        .onAppear {
            if shares.isEmpty { shares = Array(repeating: 0, count: game.options.count) }
        }
    }

    private func option(_ index: Int) -> some View {
        let truth = game.options[index].weight * 100
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(game.options[index].name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text("\(Int(shares.indices.contains(index) ? shares[index] : 0))")
                    .font(.body.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Palette.accent)
            }
            Slider(value: Binding(
                get: { shares.indices.contains(index) ? shares[index] : 0 },
                set: { newValue in
                    guard shares.indices.contains(index) else { return }
                    let others = spent - shares[index]
                    shares[index] = min(newValue, 100 - others)
                }
            ), in: 0...100)
            .tint(Palette.accent)
            .disabled(submitted)

            if submitted {
                HStack(spacing: Spacing.xs) {
                    Text("tatsächlich etwa \(Int(truth))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Palette.caution)
                    Text("· \(game.options[index].note)")
                        .font(.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}
