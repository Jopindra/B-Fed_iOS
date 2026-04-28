import SwiftUI

struct BabyDOBScreen: View {
    @Binding var babyDOB: Date
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepView(
            stepNumber: 5,
            totalSteps: 7,
            question: "When were they born?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("We use this to personalise your feeding guidance")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)

                    DatePicker("Baby's date of birth", selection: $babyDOB, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(.inkPrimary)
                        .accessibilityIdentifier("onboarding-babyDOB-picker")
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.xl)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: true,
            showSkip: true,
            background: { OnboardingBackground.babyDOB() }
        )
    }
}

#Preview {
    BabyDOBScreen(
        babyDOB: .constant(Date()),
        onBack: {},
        onContinue: {}
    )
}
