import SwiftUI

// MARK: - Gentle Guide Screen
struct GentleGuideScreen: View {
    let babyProfile: BabyProfile
    let viewModel: FormulaSetupViewModel
    var stepNumber: Int = 9
    var totalSteps: Int = 10
    let onBack: () -> Void
    let onContinue: () -> Void
    
    private var guidance: FormulaGuidanceResult {
        FormulaGuidanceService.guidance(for: babyProfile)
    }
    
    var body: some View {
        OnboardingStepView(
            stepNumber: stepNumber,
            totalSteps: totalSteps,
            question: "A gentle guide",
            onBack: onBack,
            content: {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // Selected formula summary
                        if viewModel.hasntChosenYet {
                            notChosenCard
                        } else {
                            formulaSummaryCard
                        }
                        
                        // Guidance cards
                        VStack(spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.md) {
                                GentleGuideCard(
                                    title: "Estimated daily",
                                    value: "\(guidance.suggestedDailyMin)–\(guidance.suggestedDailyMax) ml",
                                    subtitle: guidance.weightBased ? "Based on weight" : "Based on age",
                                    tint: Color.almostAquaDark
                                )
                            }
                            
                            HStack(spacing: AppSpacing.md) {
                                GentleGuideCard(
                                    title: "Typical feed size",
                                    value: "\(guidance.estimatedFeedSizeMin)–\(guidance.estimatedFeedSizeMax) ml",
                                    subtitle: "Per feed",
                                    tint: Color.peachDustDark
                                )
                                
                                GentleGuideCard(
                                    title: "Feeds per day",
                                    value: "\(guidance.estimatedFeedsPerDay.lowerBound)–\(guidance.estimatedFeedsPerDay.upperBound)",
                                    subtitle: "Times",
                                    tint: Color.orchidTintDark
                                )
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Stage guidance
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Usually suited to this age")
                                .font(AppFont.sans(12, weight: .semibold))
                                .foregroundStyle(Color.inkSecondary)
                                .padding(.horizontal, AppSpacing.sm)
                            
                            Text(guidance.applicableStageLabel)
                                .font(AppFont.bodyLarge)
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.backgroundCard)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                        .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                                )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Explanation
                        Text(guidance.explanationText)
                            .font(AppFont.body)
                            .foregroundStyle(Color.inkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.lg)
                        
                        // Disclaimer
                        FormulaDisclaimerView()
                            .padding(.horizontal, AppSpacing.lg)
                        
                        // Weight prompt
                        if !guidance.weightBased {
                            addWeightPrompt
                        }
                    }
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxl)
                }
            },
            onContinue: onContinue,
            continueEnabled: true,
            showSkip: false,
            background: { OnboardingBackground.babyWeight() }
        )
    }
    
    private var formulaSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(AppFont.sans(14))
                    .foregroundStyle(Color.almostAquaDark)
                
                Text(viewModel.displayBrandName)
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                
                Spacer()
            }
            
            if !viewModel.displayProductName.isEmpty {
                Text(viewModel.displayProductName)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            if let stage = viewModel.selectedStage {
                HStack {
                    Text(stage.displayName)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.almostAquaDark)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 4)
                        .background(Color.almostAquaLight)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
        .padding(.horizontal, AppSpacing.lg)
    }
    
    private var notChosenCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(AppFont.sans(14))
                    .foregroundStyle(Color.orchidTintDark)
                
                Text("No brand selected yet")
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                
                Spacer()
            }
            
            Text("You can add this later in Settings whenever you're ready.")
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary)
        }
        .padding(AppSpacing.lg)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
        .padding(.horizontal, AppSpacing.lg)
    }
    
    private var addWeightPrompt: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "scalemass")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.almostAquaDark)
            
            Text("Add your baby's weight later for a more tailored estimate.")
                .font(AppFont.sans(11))
                .foregroundStyle(Color.almostAquaDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(Color.almostAquaLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .padding(.horizontal, AppSpacing.lg)
    }
}
