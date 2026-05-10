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

    // MARK: Dynamic semantic colours
    static let backgroundBase = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1C1A1A"))
                : UIColor(Color(hex: "FAFAF8"))
        }
    )
    static let backgroundCard = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "2A2727"))
                : UIColor(Color(hex: "FFFFFF"))
        }
    )
    static let inkPrimary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "F5E6DE"))
                : UIColor(Color(hex: "2E2929"))
        }
    )
    static let inkSecondary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "C4BCBA"))
                : UIColor(Color(hex: "5A5555"))
        }
    )

    // MARK: Static palette colours (do not adapt, used for accents)
    static let peachDust       = Color(hex: "E8C4B0")
    static let peachDustLight  = Color(hex: "F5E6DE")
    static let peachDustDark   = Color(hex: "C49070")
    static let peachLemonBridge = Color(hex: "EDD5C0")
    static let lemonIcing       = Color(hex: "EEE8C8")
    static let lemonIcingLight  = Color(hex: "F7F4E3")
    static let lemonIcingDark   = Color(hex: "C8BE7A")
    static let almostAqua      = Color(hex: "B8CCBA")
    static let almostAquaLight = Color(hex: "DDE9DE")
    static let almostAquaDark  = Color(hex: "7A9E80")
    static let orchidTint      = Color(hex: "C4BCCD")
    static let orchidTintLight = Color(hex: "E4DFE9")
    static let orchidTintDark  = Color(hex: "8A7E96")

    // MARK: Common semantic colours (used across the app)
    static let textPrimary    = Color(hex: "1C2421")
    static let textSecondary  = Color(hex: "888780")
    static let textTertiary   = Color(hex: "B4B2A9")
    static let accentGreen    = Color(hex: "5A8A5A")
    static let accentPurple   = Color(hex: "7B6A9A")
    static let accentLavender = Color(hex: "C8C0D4")
    static let surfaceCream   = Color(hex: "F7F6F2")
    static let surfaceGreen   = Color(hex: "EEF4EE")
    static let surfacePurple  = Color(hex: "F0EDF5")
    static let surfaceGray    = Color(hex: "F5F5F5")
    static let errorRed       = Color(hex: "E24B4A")
    static let disabledGray   = Color(hex: "E0E0E0")

    // MARK: Dark mode variants (legacy — prefer semantic tokens above)
    static let dmBackgroundBase = Color(hex: "1C1A1A")
    static let dmBackgroundCard = Color(hex: "2A2727")
    static let dmInkPrimary     = Color(hex: "F5E6DE")
    static let dmInkSecondary   = Color(hex: "C4BCBA")

    // MARK: Legacy mapping for gradual migration
    static var brandPrimary: Color { .almostAquaDark }
    static var warmCoral: Color { .peachDust }
    static var warmLavender: Color { .orchidTint }
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
        return Font.custom(name, size: size, relativeTo: .body)
    }

    // DM Serif Display
    static func serif(_ size: CGFloat) -> Font {
        Font.custom("DMSerifDisplay-Regular", size: size, relativeTo: .body)
    }

    // Type scale
    static let jumbo        = serif(96)
    static let display      = serif(38)
    static let heroTitle    = serif(32)
    static let subHero      = serif(28)
    static let question     = serif(26)
    static let screenTitle  = serif(22)
    static let largeValue   = serif(24)
    static let lead         = serif(20)
    static let sectionTitle = sans(16, weight: .semibold)
    static let bodyLarge    = sans(15, weight: .medium)
    static let body         = sans(13, weight: .regular)
    static let input        = sans(17, weight: .regular)
    static let button       = sans(14, weight: .semibold)
    static let inputLabel   = sans(12, weight: .semibold)
    static let caption      = sans(11, weight: .regular)
    static let label        = sans(10, weight: .semibold)
}

// MARK: - Text Style Modifiers
struct LabelTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.label)
            .textCase(.uppercase)
            .tracking(0.4)
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
    static let xxxl: CGFloat = 48
}

// MARK: - Corner Radius Tokens
enum AppRadius {
    static let small: CGFloat  = 10
    static let button: CGFloat = 14
    static let card: CGFloat   = 16
    static let hero: CGFloat   = 20
    static let pill: CGFloat   = 26
}

// MARK: - Metrics Tokens
enum AppMetrics {
    static let inputHeight: CGFloat = 56
    static let toggleHeight: CGFloat = 48
    static let buttonHeight: CGFloat = 54
    static let borderOpacity: CGFloat = 0.07
    static let borderWidth: CGFloat = 0.5
    static let blobScaleLarge: CGFloat = 0.62
    static let blobScaleMedium: CGFloat = 0.55
    static let blobScaleSmall: CGFloat = 0.35
    static let blobOpacityStrong: CGFloat = 0.80
    static let blobOpacityMedium: CGFloat = 0.70
    static let blobOpacitySubtle: CGFloat = 0.65
}

// MARK: - Shared Date Formatters
enum AppFormatters {
    static let time: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    static let dayLabel: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f
    }()
    
    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    static let compactTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mma"
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        return f
    }()
    
    static let monthName: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "MMMM"
        return f
    }()
}
