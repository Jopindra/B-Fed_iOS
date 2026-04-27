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
                        countryCode: $viewModel.countryCode,
                        onBack: { viewModel.goBackToStep(2) },
                        onContinue: {
                            viewModel.formulaSetupViewModel.countryCode = viewModel.countryCode
                            viewModel.advanceToStep(4)
                        }
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
                    FeedingTypeSelectionScreen(
                        feedingType: mappedFeedingTypeBinding,
                        stepNumber: 6,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(5) },
                        onContinue: {
                            viewModel.formulaSetupViewModel.feedingType = mappedFeedingType
                            if viewModel.showsFormulaSetup {
                                viewModel.advanceToStep(7)
                            } else {
                                viewModel.advanceToStep(10)
                            }
                        }
                    )

                case 7:
                    BrandSelectionScreen(
                        viewModel: viewModel.formulaSetupViewModel,
                        stepNumber: 7,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(6) },
                        onContinue: { viewModel.advanceToStep(8) }
                    )

                case 8:
                    ProductStageSelectionScreen(
                        viewModel: viewModel.formulaSetupViewModel,
                        stepNumber: 8,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(7) },
                        onContinue: { viewModel.advanceToStep(9) }
                    )

                case 9:
                    GentleGuideScreen(
                        babyProfile: previewProfile,
                        viewModel: viewModel.formulaSetupViewModel,
                        stepNumber: 9,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(8) },
                        onContinue: { viewModel.advanceToStep(10) }
                    )

                case 10:
                    BabyWeightScreen(
                        birthWeight: $viewModel.birthWeight,
                        currentWeight: $viewModel.currentWeight,
                        weightUnit: $viewModel.weightUnit,
                        stepNumber: viewModel.totalSteps,
                        totalSteps: viewModel.totalSteps,
                        onContinue: completeOnboarding,
                        onBack: {
                            if viewModel.showsFormulaSetup {
                                viewModel.goBackToStep(9)
                            } else {
                                viewModel.goBackToStep(6)
                            }
                        }
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
    
    private var mappedFeedingType: FeedingType {
        switch viewModel.feedingType.lowercased() {
        case "breast": return .breast
        case "formula": return .formula
        case "both": return .mixed
        default: return .formula
        }
    }
    
    private var mappedFeedingTypeBinding: Binding<FeedingType> {
        Binding(
            get: { mappedFeedingType },
            set: { newValue in
                switch newValue {
                case .breast: viewModel.feedingType = "breast"
                case .formula: viewModel.feedingType = "formula"
                case .mixed: viewModel.feedingType = "both"
                }
            }
        )
    }
    
    /// Temporary profile for guidance preview during onboarding
    private var previewProfile: BabyProfile {
        let weightGrams = viewModel.isKg
            ? Double(viewModel.currentWeight).map { $0 * 1000 }
            : nil
        
        let profile = BabyProfile(
            country: viewModel.country,
            babyName: viewModel.babyName.isEmpty ? "Baby" : viewModel.babyName,
            dateOfBirth: viewModel.babyDOB,
            birthWeight: weightGrams,
            currentWeight: weightGrams,
            feedingType: mappedFeedingType
        )
        return profile
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
