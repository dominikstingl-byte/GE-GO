import AVFoundation
import ARKit
import SwiftUI

struct RootView: View {

    @StateObject private var state = GameState()
    @State private var showsCollection = false
    @State private var showsDiagnostics = false
    @State private var cameraAllowed = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

    /// Treibt die Jagduhr. Läuft immer mit; das kostet nichts und erspart es,
    /// den Zeitgeber an- und abzuschalten.
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if !ARWorldTrackingConfiguration.isSupported {
                notice(
                    symbol: "iphone.slash",
                    title: "Dieses Gerät kann kein AR",
                    text: "GE-GO braucht ein iPhone mit ARKit. Im Simulator läuft es grundsätzlich nicht – die Kamera fehlt dort."
                )
            } else if cameraAllowed {
                game
            } else {
                permissionRequest
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Spiel

    private var game: some View {
        ZStack(alignment: .top) {
            ARGameView(state: state)
                .ignoresSafeArea()

            if state.diagnosticsEnabled {
                boxOverlay
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: Spacing.s) {
                hud
                if state.hunt != nil { huntBar }
                if let result = state.huntResult { resultBanner(result) }
            }

            VStack {
                Spacer()
                crosshairHint
            }
        }
        .onReceive(clock) { _ in state.tickHunt() }
        .sheet(item: $state.activeFind) { find in
            EncounterView(find: find, state: state)
        }
        .sheet(isPresented: $showsCollection) {
            CollectionView(state: state)
        }
        .sheet(isPresented: $showsDiagnostics) {
            DiagnosticsView(state: state)
        }
    }

    /// Zeichnet die Vision-Kästen dorthin, wo die Umrechnung sie hinlegt.
    /// Sitzen sie neben den Gegenständen, sieht man den Fehler, statt ihn aus
    /// ausbleibenden Fundpunkten zu erschließen.
    private var boxOverlay: some View {
        GeometryReader { _ in
            ForEach(Array(state.debugBoxes.enumerated()), id: \.offset) { _, box in
                Rectangle()
                    .stroke(Palette.caution, lineWidth: 2)
                    .frame(width: max(box.width, 4), height: max(box.height, 4))
                    .position(x: box.midX, y: box.midY)
            }
        }
    }

    private var hud: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(state.status)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.onOverlay)
                HStack(spacing: Spacing.xs) {
                    Text("\(state.points) Punkte · \(state.openPetals)/10 Blätter")
                    if let wanted = state.mostWantedStrategy {
                        Text("· fehlt \(wanted.code)")
                            .foregroundStyle(wanted.brandColor)
                    }
                }
                .font(.caption)
                .foregroundStyle(Palette.onOverlayMuted)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlay, in: Capsule())
            // Langer Druck öffnet das Werkzeugblatt. Versteckt, weil es kein
            // Teil des Spiels ist – aber am Gerät jederzeit erreichbar.
            .onLongPressGesture(minimumDuration: 0.8) {
                state.diagnosticsEnabled = true
                showsDiagnostics = true
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }

            Spacer()

            Button {
                showsCollection = true
            } label: {
                ZStack {
                    Circle().fill(Palette.overlay)
                    BloomView(filled: { state.has($0) })
                        .padding(9)
                }
                .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Sammlung, \(state.openPetals) von 10 Blättern offen")
        }
        .padding(.horizontal, Spacing.m)
        .padding(.top, Spacing.m)
    }

    // MARK: Jagd

    /// Die laufende Jagd bleibt sichtbar, während man den Raum absucht – sie
    /// ist das einzige Minispiel, das nicht im Blatt stattfindet.
    @ViewBuilder
    private var huntBar: some View {
        if let run = state.hunt {
            HStack(spacing: Spacing.s) {
                Image(systemName: "binoculars.fill")
                    .foregroundStyle(Palette.onOverlay)

                VStack(alignment: .leading, spacing: 2) {
                    Text(run.hunt.prompt)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Palette.onOverlay)
                        .lineLimit(2)
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<run.hunt.count, id: \.self) { index in
                            Capsule()
                                .fill(index < run.found.count ? Palette.accent : Color.white.opacity(0.25))
                                .frame(height: 3)
                        }
                    }
                }

                Text("\(run.remaining)s")
                    .font(.callout.weight(.semibold).monospacedDigit())
                    .foregroundStyle(run.remaining <= 10 ? Palette.caution : Palette.onOverlay)

                Button {
                    state.finishHunt(succeeded: false)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Palette.onOverlayMuted)
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlayStrong, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .padding(.horizontal, Spacing.m)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func resultBanner(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .foregroundStyle(Palette.onOverlay)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlayStrong, in: Capsule())
            .padding(.horizontal, Spacing.m)
            .transition(.opacity)
            .task(id: text) {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                withAnimation { state.huntResult = nil }
            }
    }

    private var crosshairHint: some View {
        Text("Tipp die leuchtenden Blätter an")
            .font(.footnote)
            .foregroundStyle(Palette.onOverlayMuted)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlay, in: Capsule())
            .padding(.bottom, Spacing.xl)
            .opacity(state.spotCount > 0 && state.hunt == nil ? 1 : 0)
            .animation(.easeInOut, value: state.spotCount)
    }

    // MARK: Kamera

    private var permissionRequest: some View {
        VStack(spacing: Spacing.l) {
            notice(
                symbol: "camera",
                title: "GE-GO braucht die Kamera",
                text: "Das Spiel erkennt Gegenstände in deiner Umgebung und setzt Fundpunkte darauf. Es werden keine Bilder gespeichert und nichts verschickt – die Auswertung läuft vollständig auf dem Gerät."
            )
            Button("Kamera freigeben") {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async { cameraAllowed = granted }
                }
            }
            .buttonStyle(CalmButtonStyle())
            .padding(.horizontal, Spacing.xl)
        }
    }

    private func notice(symbol: String, title: String, text: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: symbol)
                .font(.system(size: 44))
                .foregroundStyle(Palette.accent)
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Palette.textPrimary)
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.textSecondary)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background)
    }
}
