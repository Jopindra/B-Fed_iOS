import SwiftUI

struct ParentEmailScreen: View {
    @Binding var parentEmail: String
    let onBack: () -> Void
    let onContinue: () -> Void

    @FocusState private var isFieldFocused: Bool

    private var isEmailValid: Bool {
        OnboardingValidation.isValidEmail(parentEmail)
    }

    var body: some View {
        OnboardingStepView(
            stepNumber: 2,
            totalSteps: 7,
            question: "What's your email?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    TextField("Your email address", text: $parentEmail, prompt: Text("e.g. sarah@email.com").foregroundColor(.orchidTint))
                        .font(AppFont.sans(17))
                        .foregroundColor(.inkPrimary)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.next)
                        .focused($isFieldFocused)
                        .accessibilityIdentifier("onboarding-parentEmail-field")
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(height: AppMetrics.inputHeight)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                        )
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.xl)

                    Text("We'll only use this for your account")
                        .font(AppFont.sans(11))
                        .foregroundColor(.orchidTintDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: isEmailValid,
            showSkip: true,
            background: { OnboardingBackground.parentEmail() }
        )
        .onAppear { isFieldFocused = true }
    }
}

#Preview {
    ParentEmailScreen(
        parentEmail: .constant(""),
        onBack: {},
        onContinue: {}
    )
}
