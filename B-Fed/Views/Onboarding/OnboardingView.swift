import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext

    var onComplete: (() -> Void)?

    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            Color.backgroundBase.ignoresSafeArea()

            Group {
                switch viewModel.currentStep {
                case 0:
                    WelcomeScreen { viewModel.advanceToStep(1) }

                case 1:
                    ParentNameScreen(
                        parentName: $viewModel.parentName,
                        onBack: { viewModel.goBackToStep(0) },
                        onContinue: { viewModel.advanceToStep(2) }
                    )

                case 2:
                    ParentEmailScreen(
                        parentEmail: $viewModel.parentEmail,
                        onBack: { viewModel.goBackToStep(1) },
                        onContinue: { viewModel.advanceToStep(3) }
                    )

                case 3:
                    CountryScreen(
                        country: $viewModel.country,
                        onBack: { viewModel.goBackToStep(2) },
                        onContinue: { viewModel.advanceToStep(4) }
                    )

                case 4:
                    BabyNameScreen(
                        babyName: $viewModel.babyName,
                        onBack: { viewModel.goBackToStep(3) },
                        onContinue: { viewModel.advanceToStep(5) }
                    )

                case 5:
                    BabyDOBScreen(
                        babyDOB: $viewModel.babyDOB,
                        onBack: { viewModel.goBackToStep(4) },
                        onContinue: { viewModel.advanceToStep(6) }
                    )

                case 6:
                    FeedingTypeScreen(
                        feedingType: $viewModel.feedingType,
                        formulaBrand: $viewModel.formulaBrand,
                        formulaStage: $viewModel.formulaStage,
                        onBack: { viewModel.goBackToStep(5) },
                        onContinue: { viewModel.advanceToStep(7) }
                    )

                case 7:
                    BabyWeightScreen(
                        birthWeight: $viewModel.birthWeight,
                        currentWeight: $viewModel.currentWeight,
                        weightUnit: $viewModel.weightUnit,
                        onContinue: completeOnboarding,
                        onBack: { viewModel.goBackToStep(6) }
                    )

                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            feedStore.setModelContext(modelContext)
        }
    }

    private func completeOnboarding() {
        let profile = viewModel.createProfile()
        feedStore.saveBabyProfile(profile)
        onComplete?()
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .environment(FeedStore())
}
