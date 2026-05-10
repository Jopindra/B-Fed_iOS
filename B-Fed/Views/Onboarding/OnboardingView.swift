import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext
    @AppStorage("onboarding.currentStep") private var savedStep: Int = 0

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
                    CountryScreen(
                        country: $viewModel.country,
                        countryCode: $viewModel.countryCode,
                        onBack: { viewModel.goBackToStep(1) },
                        onContinue: {
                            viewModel.formulaSetupViewModel.countryCode = viewModel.countryCode
                            viewModel.advanceToStep(3)
                        }
                    )

                case 3:
                    BabyNameScreen(
                        babyName: $viewModel.babyName,
                        onBack: { viewModel.goBackToStep(2) },
                        onContinue: { viewModel.advanceToStep(4) }
                    )

                case 4:
                    BabyDOBScreen(
                        babyDOB: $viewModel.babyDOB,
                        onBack: { viewModel.goBackToStep(3) },
                        onContinue: { viewModel.advanceToStep(5) }
                    )

                case 5:
                    FeedingTypeSelectionScreen(
                        feedingType: mappedFeedingTypeBinding,
                        stepNumber: 5,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(4) },
                        onContinue: {
                            if let type = mappedFeedingType {
                                viewModel.formulaSetupViewModel.feedingType = type
                            }
                            if viewModel.showsFormulaSetup {
                                viewModel.advanceToStep(6)
                            } else {
                                viewModel.advanceToStep(9)
                            }
                        }
                    )

                case 6:
                    BrandSelectionScreen(
                        viewModel: viewModel.formulaSetupViewModel,
                        stepNumber: 6,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(5) },
                        onContinue: { viewModel.advanceToStep(7) }
                    )

                case 7:
                    ProductStageSelectionScreen(
                        viewModel: viewModel.formulaSetupViewModel,
                        babyDOB: viewModel.babyDOB,
                        babyName: viewModel.babyName.isEmpty ? "your baby" : viewModel.babyName,
                        stepNumber: 7,
                        totalSteps: viewModel.totalSteps,
                        onBack: { viewModel.goBackToStep(6) },
                        onContinue: { viewModel.advanceToStep(8) }
                    )

                case 8:
                    GentleGuideScreen(
                        babyProfile: previewProfile,
                        viewModel: viewModel.formulaSetupViewModel,
                        onContinue: completeOnboarding
                    )

                case 9:
                    BabyWeightScreen(
                        birthWeight: $viewModel.birthWeight,
                        currentWeight: $viewModel.currentWeight,
                        weightUnit: $viewModel.weightUnit,
                        stepNumber: viewModel.totalSteps,
                        totalSteps: viewModel.totalSteps,
                        onContinue: completeOnboarding,
                        onBack: {
                            if viewModel.showsFormulaSetup {
                                viewModel.goBackToStep(8)
                            } else {
                                viewModel.goBackToStep(5)
                            }
                        }
                    )

                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            feedStore.setModelContext(modelContext)
            viewModel.currentStep = savedStep
        }
        .onChange(of: viewModel.currentStep) { _, newStep in
            savedStep = newStep
        }
    }
    
    private var mappedFeedingType: FeedingType? {
        switch viewModel.feedingType.lowercased() {
        case "breast": return .breast
        case "formula": return .formula
        case "both": return .mixed
        default: return nil
        }
    }
    
    private var mappedFeedingTypeBinding: Binding<FeedingType?> {
        Binding(
            get: { mappedFeedingType },
            set: { newValue in
                guard let newValue else { return }
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
        let weightGrams = Double(viewModel.currentWeight).flatMap {
            viewModel.isKg ? $0 * 1000 : $0 * 453.592
        }
        
        let profile = BabyProfile(
            parentName: viewModel.parentName,
            country: viewModel.country,
            babyName: viewModel.babyName.isEmpty ? "Baby" : viewModel.babyName,
            dateOfBirth: viewModel.babyDOB,
            birthWeight: weightGrams,
            currentWeight: weightGrams,
            feedingType: mappedFeedingType ?? .formula
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
