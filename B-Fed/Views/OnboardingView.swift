import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
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
        ZStack {
            WarmBackground()
            
            VStack(spacing: 0) {
                ProgressStepper(currentStep: currentStep, totalSteps: 4)
                    .padding(.top, 16)
                
                ZStack {
                    Group {
                        switch currentStep {
                        case 0:
                            WelcomeScreen { advanceToStep(1) }
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
                                onContinue: { validateAndProceed() },
                                onBack: { goBackToStep(0) }
                            )
                        case 2:
                            FeedingTypeScreen(
                                feedingType: $feedingType,
                                onContinue: { advanceToStep(3) },
                                onBack: { goBackToStep(1) }
                            )
                        case 3:
                            CompletionScreen(
                                onStart: { completeOnboarding() },
                                onBack: { goBackToStep(2) }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .offset(x: slideOffset)
                }
            }
        }
    }
    
    private func advanceToStep(_ step: Int) {
        guard !isAnimating else { return }
        isAnimating = true
        showingValidationErrors = false
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = -UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentStep = step
            slideOffset = UIScreen.main.bounds.width
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                slideOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }
    }
    
    private func goBackToStep(_ step: Int) {
        guard !isAnimating else { return }
        isAnimating = true
        showingValidationErrors = false
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentStep = step
            slideOffset = -UIScreen.main.bounds.width
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                slideOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }
    }
    
    private func validateAndProceed() {
        let isValid = !parentName.isEmpty &&
                     !parentEmail.isEmpty &&
                     parentEmail.contains("@") &&
                     !country.isEmpty &&
                     !babyName.isEmpty &&
                     !babyWeight.isEmpty
        
        if isValid {
            advanceToStep(2)
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
        dismiss()
    }
}

// MARK: - Background
struct WarmBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FDFCFA"), Color(hex: "FAF7F3"), Color(hex: "F7F3EE")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.brandPrimary.opacity(0.04), Color.clear],
                center: .init(x: 0.5, y: 0.3),
                startRadius: 80,
                endRadius: 240
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Progress Stepper
struct ProgressStepper: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.brandPrimary : Color.black.opacity(0.08))
                    .frame(width: index == currentStep ? 24 : 6, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentStep)
            }
        }
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appearPhase = 0
    @State private var haloScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)
            
            ZStack {
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.12), lineWidth: 1)
                    .frame(width: 200, height: 200)
                    .scaleEffect(haloScale)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.06))
                    .frame(width: 168, height: 168)
                    .scaleEffect(haloScale * 0.96)
                
                Circle()
                    .fill(RadialGradient(colors: [Color.brandPrimary.opacity(0.1), Color.clear], center: .center, startRadius: 40, endRadius: 80))
                    .frame(width: 140, height: 140)
                
                HeroBottle()
                    .frame(width: 100, height: 136)
            }
            .padding(.bottom, 36)
            .opacity(appearPhase >= 1 ? 1 : 0)
            .scaleEffect(appearPhase >= 1 ? 1 : 0.9)
            .offset(y: appearPhase >= 1 ? 0 : 20)
            
            VStack(spacing: 10) {
                Text("Feel confident\nfeeding your baby")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(0)
                    .opacity(appearPhase >= 2 ? 1 : 0)
                    .offset(y: appearPhase >= 2 ? 0 : 16)
                
                Text("Track feeds, spot patterns, and know\nthey're getting enough - effortlessly")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.textSecondary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, 4)
                    .opacity(appearPhase >= 3 ? 1 : 0)
                    .offset(y: appearPhase >= 3 ? 0 : 12)
            }
            
            Spacer()
            
            Button(action: onContinue) {
                HStack(spacing: 6) {
                    Text("Get started")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .offset(x: appearPhase >= 4 ? 0 : -8)
                        .opacity(appearPhase >= 4 ? 1 : 0)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(LinearGradient(colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.92)], startPoint: .top, endPoint: .bottom))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.brandPrimary.opacity(0.22), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(RefinedPressEffect())
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .opacity(appearPhase >= 4 ? 1 : 0)
            .offset(y: appearPhase >= 4 ? 0 : 16)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appearPhase = 1 }
            withAnimation(.easeOut(duration: 0.5).delay(0.12)) { appearPhase = 2 }
            withAnimation(.easeOut(duration: 0.4).delay(0.28)) { appearPhase = 3 }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.4)) { appearPhase = 4 }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { haloScale = 1.05 }
        }
    }
}

// MARK: - Hero Bottle
struct HeroBottle: View {
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            BottleShape()
                .stroke(Color.brandPrimary.opacity(0.28), lineWidth: 2)
            
            BottleShape()
                .fill(Color.brandPrimary.opacity(0.08))
                .overlay(
                    WaveLiquid(fillLevel: 0.6, phase: wavePhase)
                        .fill(LinearGradient(colors: [Color.brandPrimary.opacity(0.5), Color.brandPrimary.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                )
                .clipShape(BottleShape())
            
            BottleShape()
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            
            Capsule()
                .fill(Color.brandPrimary.opacity(0.35))
                .frame(width: 20, height: 10)
                .offset(y: -70)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - Screen 2: Parent & Baby Form
struct ParentBabyFormScreen: View {
    @Binding var parentName: String
    @Binding var parentEmail: String
    @Binding var parentDOB: Date
    @Binding var country: String
    @Binding var babyName: String
    @Binding var babyDOB: Date
    @Binding var babyWeight: String
    @Binding var showingValidationErrors: Bool
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @FocusState private var focusedField: Field?
    @State private var appear = false
    
    enum Field: Hashable {
        case parentName, parentEmail, country, babyName, babyWeight
    }
    
    var isValid: Bool {
        !parentName.isEmpty &&
        !parentEmail.isEmpty &&
        parentEmail.contains("@") &&
        !country.isEmpty &&
        !babyName.isEmpty &&
        !babyWeight.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation header with back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About you")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        Text("This helps us personalise your experience")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    
                    // Parent section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Parent", icon: "person.fill")
                        
                        FormField(
                            label: "Your name",
                            text: $parentName,
                            placeholder: "e.g. Sarah",
                            isRequired: true,
                            showError: showingValidationErrors && parentName.isEmpty
                        )
                        .focused($focusedField, equals: .parentName)
                        
                        FormField(
                            label: "Email address",
                            text: $parentEmail,
                            placeholder: "e.g. sarah@email.com",
                            keyboard: .emailAddress,
                            isRequired: true,
                            showError: showingValidationErrors && (parentEmail.isEmpty || !parentEmail.contains("@"))
                        )
                        .focused($focusedField, equals: .parentEmail)
                        
                        DateField(
                            label: "Date of birth",
                            date: $parentDOB,
                            isRequired: false
                        )
                        
                        FormField(
                            label: "Country",
                            text: $country,
                            placeholder: "e.g. Australia",
                            isRequired: true,
                            showError: showingValidationErrors && country.isEmpty
                        )
                        .focused($focusedField, equals: .country)
                    }
                    
                    // Baby section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Baby", icon: "heart.fill")
                        
                        FormField(
                            label: "Name or nickname",
                            text: $babyName,
                            placeholder: "e.g. Lily",
                            isRequired: true,
                            showError: showingValidationErrors && babyName.isEmpty
                        )
                        .focused($focusedField, equals: .babyName)
                        
                        DateField(
                            label: "Date of birth",
                            date: $babyDOB,
                            isRequired: true
                        )
                        
                        FormField(
                            label: "Weight (kg)",
                            text: $babyWeight,
                            placeholder: "e.g. 3.5",
                            keyboard: .decimalPad,
                            isRequired: true,
                            showError: showingValidationErrors && babyWeight.isEmpty,
                            suffix: "kg"
                        )
                        .focused($focusedField, equals: .babyWeight)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // CTA
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isValid ? Color.brandPrimary : Color.brandPrimary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: isValid ? Color.brandPrimary.opacity(0.22) : Color.clear, radius: 12, x: 0, y: 4)
            }
            .buttonStyle(RefinedPressEffect())
            .disabled(!isValid && showingValidationErrors)
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .animation(.easeOut(duration: 0.2), value: isValid)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandPrimary)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Form Field
struct FormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboard: UIKeyboardType = .default
    var isRequired: Bool = false
    var showError: Bool = false
    var suffix: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.warmCoral)
                }
            }
            
            HStack {
                TextField(placeholder, text: $text)
                    .font(.system(size: 17, weight: .regular))
                    .keyboardType(keyboard)
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(showError ? Color.warmCoral.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
            
            if showError {
                Text("This field is required")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.warmCoral)
                    .padding(.leading, 4)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Date Field
struct DateField: View {
    let label: String
    @Binding var date: Date
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.warmCoral)
                }
            }
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(.system(size: 17))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                )
        }
    }
}

// MARK: - Screen 3: Feeding Type
struct FeedingTypeScreen: View {
    @Binding var feedingType: FeedingType?
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var appear = false
    @State private var selectedDetail: String?
    @State private var showDetail = false
    
    let options: [(type: FeedingType, icon: String, title: String, subtitle: String, color: Color)] = [
        (.breast, "drop.fill", "Breastfeeding", "Nursing directly", Color.warmCoral),
        (.formula, "fork.knife", "Formula", "Bottle feeding", Color.brandPrimary),
        (.mixed, "arrow.triangle.2.circlepath", "Mixed", "Both methods", Color.warmLavender)
    ]
    
    var isComplete: Bool {
        feedingType != nil && selectedDetail != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How are you feeding?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    
                    // Feeding options
                    VStack(spacing: 12) {
                        ForEach(options, id: \.type) { option in
                            FeedingOptionCard(
                                icon: option.icon,
                                title: option.title,
                                subtitle: option.subtitle,
                                color: option.color,
                                isSelected: feedingType == option.type
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    feedingType = option.type
                                    selectedDetail = nil
                                    showDetail = true
                                }
                            }
                        }
                    }
                    
                    // Conditional follow-up
                    if showDetail, let type = feedingType {
                        FollowUpSection(
                            type: type,
                            selectedDetail: $selectedDetail
                        )
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity))
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // Continue button (only when complete)
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isComplete ? Color.brandPrimary : Color.brandPrimary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: isComplete ? Color.brandPrimary.opacity(0.22) : Color.clear, radius: 12, x: 0, y: 4)
            }
            .buttonStyle(RefinedPressEffect())
            .disabled(!isComplete)
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .opacity(showDetail ? 1 : 0)
            .offset(y: showDetail ? 0 : 20)
            .animation(.spring(response: 0.3), value: isComplete)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
        }
    }
}

// MARK: - Feeding Option Card
struct FeedingOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : color.opacity(0.1))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? color : color.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? color : Color.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(isSelected ? color.opacity(0.7) : Color.textMuted)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? color.opacity(0.06) : Color.white)
                    .shadow(color: isSelected ? color.opacity(0.12) : Color.black.opacity(0.04), radius: isSelected ? 12 : 8, x: 0, y: isSelected ? 4 : 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? color.opacity(0.25) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

// MARK: - Follow Up Section
struct FollowUpSection: View {
    let type: FeedingType
    @Binding var selectedDetail: String?
    
    var question: String {
        switch type {
        case .formula: return "How do you measure feeds?"
        case .breast: return "Do you want to track duration?"
        case .mixed: return "What do you use more often?"
        default: return ""
        }
    }
    
    var options: [(id: String, icon: String, title: String)] {
        switch type {
        case .formula:
            return [("bottle", "drop.fill", "Bottle (ml)"), ("approx", "eye", "Approximate")]
        case .breast:
            return [("timer", "stopwatch", "Yes, with timer"), ("simple", "checkmark", "Simple tracking")]
        case .mixed:
            return [("breast", "drop.fill", "Breastfeeding"), ("formula", "fork.knife", "Formula")]
        default:
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 8)
            
            VStack(spacing: 10) {
                ForEach(options, id: \.id) { option in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            selectedDetail = option.id
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.icon)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(selectedDetail == option.id ? .white : Color.brandPrimary)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(selectedDetail == option.id ? Color.white.opacity(0.2) : Color.brandPrimary.opacity(0.1))
                                )
                            
                            Text(option.title)
                                .font(.system(size: 16, weight: selectedDetail == option.id ? .semibold : .medium))
                                .foregroundStyle(selectedDetail == option.id ? .white : Color.textPrimary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedDetail == option.id ? Color.brandPrimary : Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                        )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selectedDetail == option.id ? 1.01 : 1.0)
                    .animation(.spring(response: 0.15), value: selectedDetail)
                }
            }
        }
    }
}

// MARK: - Screen 4: Completion
struct CompletionScreen: View {
    let onStart: () -> Void
    let onBack: () -> Void
    
    @State private var appear = false
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1 + (pulse ? 0.1 : 0))
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1 + (pulse ? 0.08 : 0))
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.08))
                    .frame(width: 140, height: 140)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color.white, Color.white.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.brandPrimary.opacity(0.25), radius: 20, x: 0, y: 8)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color.brandPrimary)
                }
                .scaleEffect(appear ? 1 : 0)
            }
            .padding(.bottom, 48)
            
            // Text
            VStack(spacing: 12) {
                Text("You're all set")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Let's start tracking your\nbaby's next feed")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)
            }
            
            Spacer()
            
            // CTA
            Button(action: onStart) {
                HStack(spacing: 10) {
                    Text("Start tracking")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.brandPrimary.opacity(0.35), radius: 20, x: 0, y: 8)
            }
            .buttonStyle(RefinedPressEffect())
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appear = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) { pulse = true }
        }
    }
}

// MARK: - Shapes
struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.35))
        path.addCurve(
            to: CGPoint(x: w * 0.18, y: h * 0.45),
            control1: CGPoint(x: w * 0.32, y: h * 0.4),
            control2: CGPoint(x: w * 0.22, y: h * 0.42)
        )
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.88))
        path.addCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.88),
            control1: CGPoint(x: w * 0.18, y: h * 0.98),
            control2: CGPoint(x: w * 0.82, y: h * 0.98)
        )
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.45))
        path.addCurve(
            to: CGPoint(x: w * 0.68, y: h * 0.35),
            control1: CGPoint(x: w * 0.78, y: h * 0.42),
            control2: CGPoint(x: w * 0.68, y: h * 0.4)
        )
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.22))
        path.addCurve(
            to: CGPoint(x: w * 0.32, y: h * 0.22),
            control1: CGPoint(x: w * 0.68, y: h * 0.15),
            control2: CGPoint(x: w * 0.32, y: h * 0.15)
        )
        path.closeSubpath()
        return path
    }
}

struct WaveLiquid: Shape {
    let fillLevel: CGFloat
    let wavePhase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterLevel = rect.height * (1 - fillLevel)
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        
        for x in stride(from: 0, to: width, by: 3) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 3 + wavePhase)
            let y = waterLevel + sine * 3
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Button Style
struct RefinedPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Colors
private extension Color {
    static var brandPrimary: Color { Color(hex: "2D6A5E") }
    static var warmCoral: Color { Color(hex: "D4897A") }
    static var warmLavender: Color { Color(hex: "9B8CB5") }
    static var textPrimary: Color { Color(hex: "1A1A1A") }
    static var textSecondary: Color { Color(hex: "5A5A5A") }
    static var textMuted: Color { Color(hex: "7A7A7A") }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
        .environment(FeedStore())
}
