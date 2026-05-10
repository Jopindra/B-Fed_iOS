import SwiftUI

struct FeedingTypeScreen: View {
    @Binding var feedingType: String
    @Binding var formulaBrand: String
    @Binding var formulaStage: String
    let onBack: () -> Void
    let onContinue: () -> Void

    private let options: [(value: String, title: String, subtitle: String, icon: String, bgColor: Color, iconColor: Color)] = [
        ("breast", "Breastfeeding", "Nursing directly", "drop.fill", .peachDustLight, .peachDustDark),
        ("formula", "Formula", "Bottle feeding", "cylinder.fill", .almostAquaLight, .almostAquaDark),
        ("both", "Mixed feeding", "Both methods", "arrow.2.circlepath", .orchidTintLight, .orchidTintDark)
    ]

    private var hasSelection: Bool {
        !feedingType.isEmpty
    }
    
    private var showsFormulaDetails: Bool {
        feedingType == "formula" || feedingType == "both"
    }

    var body: some View {
        OnboardingStepView(
            stepNumber: 6,
            totalSteps: 7,
            question: "How are you feeding?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("You can change this anytime")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)

                    VStack(spacing: AppSpacing.md) {
                        ForEach(options, id: \.value) { option in
                            let isSelected = feedingType == option.value
                            FeedingOptionCard(
                                option: option,
                                isSelected: isSelected,
                                action: { feedingType = option.value }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    
                    if showsFormulaDetails {
                        VStack(spacing: AppSpacing.md) {
                            OnboardingInputField(
                                label: "Formula brand (optional)",
                                placeholder: "e.g. Aptamil",
                                text: $formulaBrand,
                                submitLabel: .next
                            )
                            
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Stage (optional)")
                                    .font(AppFont.sans(13))
                                    .foregroundStyle(Color.inkSecondary)
                                    .padding(.horizontal, AppSpacing.sm)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppSpacing.sm) {
                                        ForEach(FormulaStage.allCases, id: \.self) { stage in
                                            FormulaStageButton(
                                                stage: stage,
                                                isSelected: formulaStage == stage.rawValue
                                            ) {
                                                formulaStage = stage.rawValue
                                            }
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.lg)
                                }
                            }
                        }
                        .padding(.top, AppSpacing.lg)
                        
                    }

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: hasSelection,
            showSkip: false,
            background: { OnboardingBackground.feedingType() }
        )
    }
}

// MARK: - Feeding Option Card

private struct FeedingOptionCard: View {
    let option: (value: String, title: String, subtitle: String, icon: String, bgColor: Color, iconColor: Color)
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(option.bgColor)
                        .frame(width: 44, height: 44)
                    Image(systemName: option.icon)
                        .font(AppFont.sans(20, weight: .regular))
                        .foregroundColor(option.iconColor)
                }
                .padding(.leading, AppSpacing.lg)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundColor(.inkPrimary)
                    Text(option.subtitle)
                        .font(AppFont.sans(12))
                        .foregroundColor(.inkSecondary)
                }
                .padding(.leading, AppSpacing.md)

                Spacer()

                SelectionIndicator(isSelected: isSelected)
                    .padding(.trailing, AppSpacing.lg)
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(isSelected ? Color.inkPrimary : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: isSelected ? 1.5 : AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.title), \(option.subtitle)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("onboarding-feeding-\(option.value)")
    }
}

// MARK: - Selection Indicator

struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.clear : Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                .frame(width: 22, height: 22)

            if isSelected {
                Circle()
                    .fill(Color.inkPrimary)
                    .frame(width: 22, height: 22)
                Image(systemName: "checkmark")
                    .font(AppFont.caption)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Formula Stage Button

private struct FormulaStageButton: View {
    let stage: FormulaStage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(stage.displayName)
                .font(AppFont.sans(13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Color.inkPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? Color.almostAquaDark : Color.backgroundCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(stage.displayName)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

#Preview {
    FeedingTypeScreen(
        feedingType: .constant(""),
        formulaBrand: .constant(""),
        formulaStage: .constant(""),
        onBack: {},
        onContinue: {}
    )
}
