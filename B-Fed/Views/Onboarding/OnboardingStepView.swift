import SwiftUI

// MARK: - Shared Onboarding Step Container
struct OnboardingStepView<Content: View, Background: View>: View {
    let stepNumber: Int
    let totalSteps: Int
    let question: String
    let onBack: () -> Void
    @ViewBuilder let content: Content
    let onContinue: () -> Void
    let continueEnabled: Bool
    let showSkip: Bool
    let skipAction: (() -> Void)?
    @ViewBuilder let background: Background

    init(
        stepNumber: Int,
        totalSteps: Int,
        question: String,
        onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        onContinue: @escaping () -> Void,
        continueEnabled: Bool,
        showSkip: Bool = false,
        skipAction: (() -> Void)? = nil,
        @ViewBuilder background: () -> Background
    ) {
        self.stepNumber = stepNumber
        self.totalSteps = totalSteps
        self.question = question
        self.onBack = onBack
        self.content = content()
        self.onContinue = onContinue
        self.continueEnabled = continueEnabled
        self.showSkip = showSkip
        self.skipAction = skipAction
        self.background = background()
    }

    private var progressRatio: Double {
        Double(stepNumber) / Double(totalSteps)
    }

    private var isLastStep: Bool {
        stepNumber == totalSteps
    }

    var body: some View {
        ZStack {
            Color.backgroundBase.ignoresSafeArea()
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: onBack) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.inkPrimary)
                        }
                        .frame(width: 36, height: 36)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Back")
                    .accessibilityIdentifier("onboarding-back-button")
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, 18)
                .padding(.top, 56)

                // Progress bar
                GeometryReader { progressGeo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.black.opacity(0.08))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.inkPrimary)
                            .frame(width: progressGeo.size.width * progressRatio)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Onboarding progress")
                .accessibilityValue("Step \(stepNumber) of \(totalSteps)")
                .accessibilityIdentifier("onboarding-progress-bar")

                // Question headline
                Text(question)
                    .font(AppFont.serif(26))
                    .foregroundColor(Color.inkPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 32)
                    .accessibilityIdentifier("onboarding-question-label")

                // Content area
                ScrollView(showsIndicators: false) {
                    content
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom CTA
                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text(isLastStep ? "Let's go →" : "Continue →")
                            .font(AppFont.sans(16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.inkPrimary)
                            )
                    }
                    .disabled(!continueEnabled)
                    .buttonStyle(.plain)
                    .opacity(continueEnabled ? 1.0 : 0.4)
                    .accessibilityIdentifier("onboarding-continue-button")

                    if showSkip {
                        Button(action: skipAction ?? onContinue) {
                            Text("Skip for now")
                                .font(AppFont.sans(12, weight: .regular))
                                .foregroundColor(Color.orchidTintDark)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Continues without saving this information")
                        .accessibilityIdentifier("onboarding-skip-button")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }
}

// Convenience init with no custom background
extension OnboardingStepView where Background == EmptyView {
    init(
        stepNumber: Int,
        totalSteps: Int,
        question: String,
        onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        onContinue: @escaping () -> Void,
        continueEnabled: Bool,
        showSkip: Bool = false,
        skipAction: (() -> Void)? = nil
    ) {
        self.stepNumber = stepNumber
        self.totalSteps = totalSteps
        self.question = question
        self.onBack = onBack
        self.content = content()
        self.onContinue = onContinue
        self.continueEnabled = continueEnabled
        self.showSkip = showSkip
        self.skipAction = skipAction
        self.background = EmptyView()
    }
}
