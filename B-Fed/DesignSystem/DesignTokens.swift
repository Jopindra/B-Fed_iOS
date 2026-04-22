import SwiftUI

// MARK: - Color Tokens
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Primary – Pantone 12-1107 Peach Dust
    static let peachDust       = Color(hex: "E8C4B0")
    static let peachDustLight  = Color(hex: "F5E6DE")
    static let peachDustDark   = Color(hex: "C49070")

    // Bridge – Peach Dust → Lemon Icing arc transition
    static let peachLemonBridge = Color(hex: "EDD5C0")

    // Pantone 11-0515 Lemon Icing
    static let lemonIcing       = Color(hex: "EEE8C8")
    static let lemonIcingLight  = Color(hex: "F7F4E3")
    static let lemonIcingDark   = Color(hex: "C8BE7A")

    // Secondary – Pantone 13-6006 Almost Aqua
    static let almostAqua      = Color(hex: "B8CCBA")
    static let almostAquaLight = Color(hex: "DDE9DE")
    static let almostAquaDark  = Color(hex: "7A9E80")

    // Tertiary – Pantone 13-3802 Orchid Tint
    static let orchidTint      = Color(hex: "C4BCCD")
    static let orchidTintLight = Color(hex: "E4DFE9")
    static let orchidTintDark  = Color(hex: "8A7E96")

    // Neutrals
    static let inkPrimary      = Color(hex: "2E2929")
    static let inkSecondary    = Color(hex: "5A5555")
    static let backgroundBase  = Color(hex: "FAFAF8")
    static let backgroundCard  = Color(hex: "FFFFFF")

    // Dark mode variants
    static let dmBackgroundBase = Color(hex: "1C1A1A")
    static let dmBackgroundCard = Color(hex: "2A2727")
    static let dmInkPrimary     = Color(hex: "F5E6DE")
    static let dmInkSecondary   = Color(hex: "C4BCBA")

    // Legacy mapping for gradual migration
    static var brandPrimary: Color { .almostAquaDark }
    static var warmCoral: Color { .peachDust }
    static var warmLavender: Color { .orchidTint }
    static var textPrimary: Color { .inkPrimary }
    static var textSecondary: Color { .inkSecondary }
    static var textMuted: Color { .inkSecondary.opacity(0.6) }
}

// MARK: - Font Tokens
enum AppFont {
    // DM Sans weights
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .light: name = "DMSans-Light"
        case .medium: name = "DMSans-Medium"
        case .semibold: name = "DMSans-SemiBold"
        case .bold: name = "DMSans-Bold"
        default: name = "DMSans-Regular"
        }
        return Font.custom(name, size: size)
    }

    // DM Serif Display
    static func serif(_ size: CGFloat) -> Font {
        Font.custom("DMSerifDisplay-Regular", size: size)
    }

    // Type scale
    static let heroTitle    = serif(32)
    static let screenTitle  = serif(22)
    static let sectionTitle = sans(16, weight: .semibold)
    static let bodyLarge    = sans(15, weight: .medium)
    static let body         = sans(13, weight: .regular)
    static let caption      = sans(11, weight: .regular)
    static let label        = sans(10, weight: .semibold)
}

// MARK: - Text Style Modifiers
struct LabelTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.label)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

extension View {
    func labelStyle() -> some View {
        modifier(LabelTextStyle())
    }
}

// MARK: - Spacing Tokens
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius Tokens
enum AppRadius {
    static let small: CGFloat  = 10
    static let button: CGFloat = 14
    static let card: CGFloat   = 16
    static let hero: CGFloat   = 20
    static let pill: CGFloat   = 26
}
