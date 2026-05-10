import SwiftUI

struct ParentNameScreen: View {
    @Binding var parentName: String
    let onBack: () -> Void
    let onContinue: () -> Void

    @FocusState private var isFieldFocused: Bool

    var body: some View {
        OnboardingStepView(
            stepNumber: 1,
            totalSteps: 7,
            question: "What's your name?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    TextField("Your name", text: $parentName, prompt: Text("e.g. Sarah").foregroundColor(.orchidTint))
                        .font(AppFont.input)
                        .foregroundColor(.inkPrimary)
                        .keyboardType(.namePhonePad)
                        .submitLabel(.next)
                        .focused($isFieldFocused)
                        .accessibilityIdentifier("onboarding-parentName-field")
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

                    Text("This is how we'll greet you in the app")
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
            background: { OnboardingBackground.parentName() }
        )
        .onAppear { isFieldFocused = true }
    }
}

#Preview {
    ParentNameScreen(
        parentName: .constant(""),
        onBack: {},
        onContinue: {}
    )
}
