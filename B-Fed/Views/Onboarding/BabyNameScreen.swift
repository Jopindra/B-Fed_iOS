import SwiftUI

struct BabyNameScreen: View {
    @Binding var babyName: String
    let onBack: () -> Void
    let onContinue: () -> Void

    @FocusState private var isFieldFocused: Bool

    var body: some View {
        OnboardingStepView(
            stepNumber: 4,
            totalSteps: 7,
            question: "What's your baby's name?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("Or a nickname — whatever feels right")
                        .font(AppFont.body)
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)

                    TextField("Baby's name", text: $babyName, prompt: Text("e.g. Lily").foregroundColor(.orchidTint))
                        .font(AppFont.input)
                        .foregroundColor(.inkPrimary)
                        .keyboardType(.namePhonePad)
                        .submitLabel(.next)
                        .focused($isFieldFocused)
                        .accessibilityIdentifier("onboarding-babyName-field")
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(height: AppMetrics.inputHeight)
                        .background(Color.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                        )
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.xl)

                    Text("This is just for you")
                        .font(AppFont.caption)
                        .foregroundColor(.orchidTintDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: true,
            showSkip: true,
            background: { OnboardingBackground.babyName() }
        )
        .onAppear { isFieldFocused = true }
    }
}

#Preview {
    BabyNameScreen(
        babyName: .constant(""),
        onBack: {},
        onContinue: {}
    )
}
