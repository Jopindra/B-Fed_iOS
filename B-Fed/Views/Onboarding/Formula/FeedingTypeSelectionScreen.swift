import SwiftUI

// MARK: - Feeding Type Selection Screen
/// Simplified feeding type picker. Formula details handled in subsequent steps.
struct FeedingTypeSelectionScreen: View {
    @Binding var feedingType: FeedingType?
    var stepNumber: Int = 6
    var totalSteps: Int = 10
    let onBack: () -> Void
    let onContinue: () -> Void
    
    private let options: [(type: FeedingType, title: String, subtitle: String, icon: String, bgColor: Color, iconColor: Color)] = [
        (.breast, "Breastfeeding", "Nursing directly", "drop.fill", .peachDustLight, .peachDustDark),
        (.formula, "Formula", "Bottle feeding", "cylinder.fill", .almostAquaLight, .almostAquaDark),
        (.mixed, "Mixed feeding", "Both methods", "arrow.2.circlepath", .orchidTintLight, .orchidTintDark)
    ]
    
    var body: some View {
        OnboardingStepView(
            stepNumber: stepNumber,
            totalSteps: totalSteps,
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
                        ForEach(options, id: \.type) { option in
                            FeedingTypeCard(
                                option: option,
                                isSelected: feedingType == option.type,
                                action: { feedingType = option.type }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    
                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: feedingType != nil,
            showSkip: false,
            background: { OnboardingBackground.feedingType() }
        )
    }
}

// MARK: - Feeding Type Card
private struct FeedingTypeCard: View {
    let option: (type: FeedingType, title: String, subtitle: String, icon: String, bgColor: Color, iconColor: Color)
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
    }
}
