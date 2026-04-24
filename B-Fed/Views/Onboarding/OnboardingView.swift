import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext
    
    var onComplete: (() -> Void)?
    
    // Form Data
    @State private var parentName: String = ""
    @State private var parentEmail: String = ""
    @State private var parentDOB: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var country: String = ""
    @State private var babyName: String = ""
    @State private var babyDOB: Date = Date()
    @State private var babyWeight: String = ""
    @State private var feedingType: FeedingType?
    
    // Navigation
    @State private var currentStep = 0
    @State private var slideOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var showingValidationErrors = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                WarmBackground()
                
                ZStack {
                    Group {
                        switch currentStep {
                        case 0:
                            WelcomeScreen { advanceToStep(1, width: geometry.size.width) }
                        case 1:
                            ParentBabyFormScreen(
                                parentName: $parentName,
                                parentEmail: $parentEmail,
                                parentDOB: $parentDOB,
                                country: $country,
                                babyName: $babyName,
                                babyDOB: $babyDOB,
                                babyWeight: $babyWeight,
                                showingValidationErrors: $showingValidationErrors,
                                onContinue: { validateAndProceed(width: geometry.size.width) },
                                onBack: { goBackToStep(0, width: geometry.size.width) }
                            )
                        case 2:
                            FeedingTypeScreen(
                                feedingType: $feedingType,
                                onContinue: { advanceToStep(3, width: geometry.size.width) },
                                onBack: { goBackToStep(1, width: geometry.size.width) }
                            )
                        case 3:
                            CompletionScreen(
                                onStart: { completeOnboarding() },
                                onBack: { goBackToStep(2, width: geometry.size.width) }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .offset(x: slideOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(.all)
                
                // Progress stepper overlay (hidden on welcome screen)
                if currentStep > 0 {
                    VStack {
                        ProgressStepper(currentStep: currentStep, totalSteps: 4)
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            feedStore.setModelContext(modelContext)
        }
    }
    
    private func advanceToStep(_ step: Int, width: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        showingValidationErrors = false
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = -width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentStep = step
            slideOffset = width
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                slideOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }
    }
    
    private func goBackToStep(_ step: Int, width: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        showingValidationErrors = false
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentStep = step
            slideOffset = -width
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                slideOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }
    }
    
    private func validateAndProceed(width: CGFloat) {
        let isValid = !parentEmail.isEmpty && parentEmail.contains("@")
        
        if isValid {
            advanceToStep(2, width: width)
        } else {
            withAnimation(.spring(response: 0.3)) {
                showingValidationErrors = true
            }
        }
    }
    
    private func completeOnboarding() {
        let profile = BabyProfile(
            parentName: parentName,
            parentEmail: parentEmail,
            parentDOB: parentDOB,
            country: country,
            babyName: babyName,
            dateOfBirth: babyDOB,
            birthWeight: Double(babyWeight).map { $0 * 1000 },
            feedingType: feedingType ?? .formula
        )
        feedStore.saveBabyProfile(profile)
        onComplete?()
    }
}


// MARK: - Background
struct WarmBackground: View {
    var body: some View {
        Color.backgroundBase
            .ignoresSafeArea()
    }
}

// MARK: - Progress Stepper
struct ProgressStepper: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                if index == currentStep {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.inkPrimary)
                        .frame(width: 24, height: 6)
                } else {
                    Circle()
                        .fill(Color.inkSecondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}


#Preview {
    OnboardingView(onComplete: {})
        .environment(FeedStore())
}
