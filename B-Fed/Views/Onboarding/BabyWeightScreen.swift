import SwiftUI

struct BabyWeightScreen: View {
    @Binding var birthWeight: String
    @Binding var currentWeight: String
    @Binding var weightUnit: String

    let onContinue: () -> Void
    let onBack: () -> Void

    private var isKg: Bool {
        weightUnit == "kg"
    }

    private var birthPlaceholder: String {
        isKg ? "e.g. 3.4 kg" : "e.g. 7 lb 8 oz"
    }

    private var currentPlaceholder: String {
        isKg ? "e.g. 4.2 kg" : "e.g. 9 lb 4 oz"
    }

    var body: some View {
        OnboardingStepView(
            stepNumber: 7,
            totalSteps: 7,
            question: "What's their weight?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("Helps us guide feeding amounts")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)

                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        UnitToggle(
                            unit: $weightUnit,
                            options: [
                                (label: "kg", value: "kg"),
                                (label: "lb / oz", value: "lb_oz")
                            ]
                        )

                        OnboardingInputField(
                            label: "Birth weight",
                            placeholder: birthPlaceholder,
                            text: $birthWeight,
                            keyboardType: .decimalPad,
                            submitLabel: .next,
                            accessibilityIdentifier: "onboarding-birthWeight-field"
                        )

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            OnboardingInputField(
                                label: "Current weight",
                                placeholder: currentPlaceholder,
                                text: $currentWeight,
                                keyboardType: .decimalPad,
                                submitLabel: .done,
                                accessibilityIdentifier: "onboarding-currentWeight-field"
                            )

                            Text("You can update weight anytime in the app")
                                .font(AppFont.sans(11))
                                .foregroundColor(.orchidTintDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: true,
            showSkip: true,
            background: { OnboardingBackground.babyWeight() }
        )
    }
}

#Preview {
    BabyWeightScreen(
        birthWeight: .constant(""),
        currentWeight: .constant(""),
        weightUnit: .constant("kg"),
        onContinue: {},
        onBack: {}
    )
}
