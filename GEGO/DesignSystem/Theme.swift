import SwiftUI
import UIKit

/// Farbwelt, aus dem Danach-Projekt übernommen: warmes Off-White, dunkles
/// Graublau, gedämpftes Salbeigrün als Akzent.
///
/// Für GE-GO kommen zwei Dinge dazu, die eine AR-App braucht: Flächen, die
/// über bewegtem Kamerabild lesbar bleiben, und eine eigene Farbe je
/// R-Stufe.
enum Palette {

    static let background = dynamic(light: 0xFAF8F4, dark: 0x14171A)
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x1E2226)
    static let surfaceMuted = dynamic(light: 0xF2EEE7, dark: 0x252A2F)

    static let textPrimary = dynamic(light: 0x2B333C, dark: 0xE9E7E2)
    static let textSecondary = dynamic(light: 0x5C6874, dark: 0xA9AFB6)

    static let accent = dynamic(light: 0x5F7F66, dark: 0x93B097)
    static let accentSurface = dynamic(light: 0xE6EDE5, dark: 0x232C26)

    static let caution = dynamic(light: 0x8A6321, dark: 0xD5A75F)
    static let cautionSurface = dynamic(light: 0xF6EEDF, dark: 0x2C2721)

    static let alert = dynamic(light: 0x91473D, dark: 0xCE8579)
    static let alertSurface = dynamic(light: 0xF7E9E6, dark: 0x2E2321)

    static let separator = dynamic(light: 0xE2DCD2, dark: 0x2F353B)

    // MARK: Über Kamerabild

    /// Auf dem Kamerabild gibt es keinen Hell- und Dunkelmodus, sondern nur
    /// „irgendein Bild darunter". Deshalb feste, dunkle Flächen mit heller
    /// Schrift – das ist der einzige Weg, der immer lesbar bleibt.
    static let overlay = Color.black.opacity(0.62)
    static let overlayStrong = Color.black.opacity(0.82)
    static let onOverlay = Color.white
    static let onOverlayMuted = Color.white.opacity(0.72)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    /// Hebt oder senkt die Helligkeit, bis die Farbe vor dem jeweiligen
    /// Untergrund lesbar wird. Der Farbton bleibt, nur der Wert wandert –
    /// so bleibt ein Markenton als Markenton erkennbar.
    func withBrightness(atLeast floor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        guard b < floor else { return self }
        return UIColor(hue: h, saturation: s * 0.9, brightness: floor, alpha: a)
    }

    func withBrightness(atMost ceiling: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        guard b > ceiling else { return self }
        return UIColor(hue: h, saturation: min(1, s * 1.05), brightness: ceiling, alpha: a)
    }
}

/// Abstände in festen Stufen, damit das Layout ruhig bleibt.
enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum Radius {
    static let card: CGFloat = 14
    static let control: CGFloat = 12
}

enum Layout {
    static let minTapTarget: CGFloat = 52
    static let readableWidth: CGFloat = 620
}

// MARK: - Bausteine

struct CardBackground: ViewModifier {
    var color: Color = Palette.surface

    func body(content: Content) -> some View {
        content
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .stroke(Palette.separator, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(_ color: Color = Palette.surface) -> some View {
        modifier(CardBackground(color: color))
    }

    func readableWidth() -> some View {
        frame(maxWidth: Layout.readableWidth)
            .frame(maxWidth: .infinity)
    }

    /// Fläche für Bedienelemente, die direkt auf dem Kamerabild liegen.
    func overlayStyle(_ color: Color = Palette.overlay) -> some View {
        padding(Spacing.m)
            .background(color, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}

struct CalmButtonStyle: ButtonStyle {
    var prominent: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(prominent ? Color.white : Palette.accent)
            .frame(maxWidth: .infinity)
            .frame(minHeight: Layout.minTapTarget)
            .padding(.horizontal, Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .fill(prominent ? Palette.accent : Palette.accentSurface)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .contentShape(Rectangle())
    }
}

struct SectionHeading: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Palette.textSecondary)
            .textCase(nil)
            .accessibilityAddTraits(.isHeader)
    }
}
