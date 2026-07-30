import AVFoundation
import ARKit
import SwiftUI

struct RootView: View {

    @StateObject private var state = GameState()
    @State private var showsCollection = false
    @State private var cameraAllowed = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

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

            hud

            VStack {
                Spacer()
                crosshairHint
            }
        }
        .sheet(item: $state.activeEntry) { entry in
            EncounterView(entry: entry, state: state)
        }
        .sheet(isPresented: $showsCollection) {
            CollectionView(state: state)
        }
    }

    private var hud: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(state.status)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.onOverlay)
                Text("\(state.points) Punkte · \(state.understood.count)/10 Stufen")
                    .font(.caption)
                    .foregroundStyle(Palette.onOverlayMuted)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlay, in: Capsule())

            Spacer()

            Button {
                showsCollection = true
            } label: {
                Image(systemName: "square.grid.2x2")
                    .font(.title3)
                    .foregroundStyle(Palette.onOverlay)
                    .frame(width: 44, height: 44)
                    .background(Palette.overlay, in: Circle())
            }
        }
        .padding(Spacing.m)
    }

    private var crosshairHint: some View {
        Text("Tipp die leuchtenden Punkte an")
            .font(.footnote)
            .foregroundStyle(Palette.onOverlayMuted)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Palette.overlay, in: Capsule())
            .padding(.bottom, Spacing.xl)
            .opacity(state.spotCount > 0 ? 1 : 0)
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
