import SwiftUI

// MARK: - Buttons

struct PrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.button)
            .foregroundStyle(Color.backgroundCard)
            .frame(height: AppMetrics.buttonHeight)
            .background(Color.inkPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
    }
}

struct SecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.button)
            .foregroundStyle(Color.peachDustDark)
            .frame(height: AppMetrics.buttonHeight)
            .background(Color.peachDustLight)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
    }
}

struct GhostButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.button)
            .foregroundStyle(Color.inkSecondary)
            .frame(height: AppMetrics.buttonHeight)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(Color.inkSecondary.opacity(0.30), lineWidth: AppMetrics.borderWidth)
            )
    }
}

extension View {
    func primaryButton() -> some View {
        modifier(PrimaryButton())
    }

    func secondaryButton() -> some View {
        modifier(SecondaryButton())
    }

    func ghostButton() -> some View {
        modifier(GhostButton())
    }
}

// MARK: - Cards

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.lg)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
            )
    }
}

struct HeroCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.lg)
            .background(Color.orchidTint)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                    .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func heroCardStyle() -> some View {
        modifier(HeroCardStyle())
    }
}

// MARK: - Tags / Pills

struct TagActive: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.label)
            .foregroundStyle(Color.backgroundCard)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(Color.inkPrimary)
            .clipShape(Capsule())
    }
}

struct TagInactive: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.label)
            .foregroundStyle(Color.inkSecondary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(Color.backgroundCard)
            .overlay(
                Capsule()
                    .stroke(Color.inkSecondary.opacity(0.20), lineWidth: AppMetrics.borderWidth)
            )
    }
}

struct BadgeStyle: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(AppFont.label)
            .foregroundStyle(Color.backgroundCard)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(color)
            .clipShape(Capsule())
    }
}

extension View {
    func tagActive() -> some View {
        modifier(TagActive())
    }

    func tagInactive() -> some View {
        modifier(TagInactive())
    }

    func badge(color: Color) -> some View {
        modifier(BadgeStyle(color: color))
    }
}

// MARK: - Avatar

struct AvatarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.sans(13, weight: .semibold))
            .foregroundStyle(Color.peachDustDark)
            .frame(width: 34, height: 34)
            .background(Color.peachDust)
            .clipShape(Circle())
    }
}

extension View {
    func avatar() -> some View {
        modifier(AvatarStyle())
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double
    let index: Int

    private var fillColor: Color {
        switch index % 3 {
        case 0: return Color.peachDustDark
        case 1: return Color.almostAquaDark
        default: return Color.orchidTintDark
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(fillColor)
                    .frame(width: max(0, geo.size.width * progress), height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Onboarding Input Field

struct OnboardingInputField: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .return
    var accessibilityIdentifier: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let label = label {
                Text(label)
                    .font(AppFont.inputLabel)
                    .foregroundColor(Color.inkPrimary)
            }
            TextField(label ?? "", text: $text, prompt: Text(placeholder).foregroundColor(.orchidTint))
                .font(AppFont.input)
                .foregroundColor(Color.inkPrimary)
                .keyboardType(keyboardType)
                .submitLabel(submitLabel)
                .ifLet(accessibilityIdentifier) { view, id in
                    view.accessibilityIdentifier(id)
                }
                .padding(.horizontal, AppSpacing.lg)
                .frame(height: AppMetrics.inputHeight)
                .background(Color.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                )
        }
    }
}

// MARK: - Unit Toggle

struct UnitToggle: View {
    @Binding var unit: String
    let options: [(label: String, value: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.value) { option in
                let isSelected = unit == option.value
                Button(action: { unit = option.value }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.inkPrimary)
                            .padding(4)
                            .opacity(isSelected ? 1 : 0)
                        Text(option.label)
                            .font(AppFont.button)
                            .foregroundColor(isSelected ? Color.backgroundCard : Color.inkSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.label)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(height: AppMetrics.toggleHeight)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
    }
}

// MARK: - Conditional Modifier Helper

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Bottom Tab Bar Style

struct TabBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.backgroundCard)
            .overlay(
                Rectangle()
                    .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                    .frame(height: AppMetrics.borderWidth)
                    .frame(maxHeight: .infinity, alignment: .top),
                alignment: .top
            )
    }
}

extension View {
    func tabBarStyled() -> some View {
        modifier(TabBarStyle())
    }
}
