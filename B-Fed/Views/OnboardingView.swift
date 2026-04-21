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
        GeometryReader { geometry in
            ZStack {
                WarmBackground()
                
                VStack(spacing: 0) {
                    ProgressStepper(currentStep: currentStep, totalSteps: 4)
                    
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
                    }
                }
            }
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
        let isValid = !parentName.isEmpty &&
                     !parentEmail.isEmpty &&
                     parentEmail.contains("@") &&
                     !country.isEmpty &&
                     !babyName.isEmpty &&
                     !babyWeight.isEmpty
        
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
        dismiss()
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
        .padding(.top, 48)
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appearPhase = 0
    
    let tags: [(text: String, rotation: Double, xOffset: CGFloat, yOffset: CGFloat)] = [
        ("TRACKING", -2.0, -70, -10),
        ("INSIGHTS", 3.0, 60, -28),
        ("GROWTH", -1.0, 90, 5),
        ("PATTERNS", 2.0, -20, 25)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Top-right organic blob — bleeds off corner, ~60% visible
                OrganicBlobShape()
                    .fill(Color.peachDust)
                    .frame(width: 280, height: 280)
                    .position(x: geometry.size.width + 20, y: -20)
                    .zIndex(0)
                    .opacity(appearPhase >= 1 ? 1 : 0)
                
                // Orchid accent blob — sits behind floating tags
                Circle()
                    .fill(Color.orchidTint.opacity(0.6))
                    .frame(width: 110, height: 110)
                    .position(x: geometry.size.width - 60, y: geometry.size.height * 0.18 + 45)
                    .zIndex(0)
                    .opacity(appearPhase >= 1 ? 1 : 0)
                
                VStack(spacing: 0) {
                    Spacer().frame(height: geometry.size.height * 0.18)
                    
                    // Floating topic tags
                    ZStack {
                        ForEach(tags.indices, id: \.self) { i in
                            Text(tags[i].text)
                                .font(AppFont.sans(12, weight: .bold))
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(Color.backgroundCard)
                                .clipShape(Capsule())
                                .rotationEffect(.degrees(tags[i].rotation))
                                .offset(x: tags[i].xOffset, y: tags[i].yOffset)
                        }
                    }
                    .frame(height: 90)
                    .zIndex(2)
                    .opacity(appearPhase >= 2 ? 1 : 0)
                    .offset(y: appearPhase >= 2 ? 0 : 14)
                    
                    Spacer().frame(height: 36)
                    
                    // Headline with decorative star
                    ZStack(alignment: .topTrailing) {
                        Text("Feel confident\nfeeding your baby")
                            .font(AppFont.serif(38))
                            .foregroundStyle(Color.inkPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        StarShape()
                            .fill(Color.orchidTintDark.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .offset(x: 10, y: -18)
                    }
                    .zIndex(2)
                    .opacity(appearPhase >= 3 ? 1 : 0)
                    .offset(y: appearPhase >= 3 ? 0 : 16)
                    
                    Spacer()
                    
                    // CTA — 88% width, centred
                    Button(action: onContinue) {
                        HStack(spacing: 10) {
                            Text("Get started")
                                .font(AppFont.bodyLarge)
                            Image(systemName: "arrow.right")
                                .font(AppFont.bodyLarge)
                        }
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width * 0.88)
                    }
                    .primaryButton()
                    .padding(.bottom, AppSpacing.xxl)
                    .opacity(appearPhase >= 4 ? 1 : 0)
                    .offset(y: appearPhase >= 4 ? 0 : 16)
                }
                .zIndex(1)
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appearPhase = 1 }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appearPhase = 2 }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { appearPhase = 3 }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82).delay(0.45)) { appearPhase = 4 }
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
                            .font(AppFont.bodyLarge)
                        Text("Back")
                            .font(AppFont.bodyLarge)
                    }
                }
                .ghostButton()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About you")
                            .font(AppFont.heroTitle)
                            .foregroundStyle(Color.inkPrimary)
                        Text("This helps us personalise your experience")
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(Color.inkSecondary)
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
                            isRequired: true,
                            showError: showingValidationErrors && babyWeight.isEmpty,
                            suffix: "kg"
                        )
                        .focused($focusedField, equals: .babyWeight)
                    }
                    
                    Spacer().frame(height: AppSpacing.xxl)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // CTA
            Button(action: onContinue) {
                Text("Continue")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .opacity(isValid ? 1.0 : 0.4)
            .buttonStyle(RefinedPressEffect())
            .disabled(!isValid && showingValidationErrors)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
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
                .font(AppFont.body)
                .foregroundStyle(Color.almostAquaDark)
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(Color.inkPrimary)
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
    var isRequired: Bool = false
    var showError: Bool = false
    var suffix: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkPrimary)
                if isRequired {
                    Text("*")
                        .font(AppFont.sectionTitle)
                        .foregroundStyle(Color.peachDustDark)
                }
            }
            
            HStack {
                TextField(placeholder, text: $text)
                    .font(AppFont.bodyLarge)
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(AppFont.bodyLarge)
                        .foregroundStyle(Color.inkSecondary.opacity(0.6))
                }
            }
            .cardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(showError ? Color.peachDustDark.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
            
            if showError {
                Text("This field is required")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.peachDustDark)
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
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkPrimary)
                if isRequired {
                    Text("*")
                        .font(AppFont.sectionTitle)
                        .foregroundStyle(Color.peachDustDark)
                }
            }
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(AppFont.bodyLarge)
                .cardStyle()
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
        (.breast, "drop.fill", "Breastfeeding", "Nursing directly", Color.peachDustDark),
        (.formula, "fork.knife", "Formula", "Bottle feeding", Color.almostAquaDark),
        (.mixed, "arrow.triangle.2.circlepath", "Mixed", "Both methods", Color.orchidTintDark)
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
                            .font(AppFont.bodyLarge)
                        Text("Back")
                            .font(AppFont.bodyLarge)
                    }
                }
                .ghostButton()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How are you feeding?")
                            .font(AppFont.heroTitle)
                            .foregroundStyle(Color.inkPrimary)
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
                    
                    Spacer().frame(height: AppSpacing.xxl)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // Continue button (only when complete)
            Button(action: onContinue) {
                Text("Continue")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .opacity(isComplete ? 1.0 : 0.4)
            .buttonStyle(RefinedPressEffect())
            .disabled(!isComplete)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
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
                        .font(AppFont.screenTitle)
                        .foregroundStyle(isSelected ? color : color.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyLarge)
                        .foregroundStyle(isSelected ? color : Color.inkPrimary)
                    
                    Text(subtitle)
                        .font(AppFont.body)
                        .foregroundStyle(isSelected ? color.opacity(0.7) : Color.inkSecondary.opacity(0.6))
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? color : Color.inkSecondary.opacity(0.25), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(AppFont.caption)
                            .foregroundStyle(.white)
                    }
                }
            }
            .cardStyle()
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
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(AppFont.sectionTitle)
                .foregroundStyle(Color.inkPrimary)
                .padding(.top, 8)
            
            VStack(spacing: 10) {
                ForEach(options, id: \.id) { option in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            selectedDetail = option.id
                        }
                    } label: {
                        if selectedDetail == option.id {
                            Text(option.title)
                                .font(AppFont.bodyLarge)
                                .tagActive()
                        } else {
                            Text(option.title)
                                .font(AppFont.bodyLarge)
                                .tagInactive()
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selectedDetail == option.id ? 1.01 : 1.0)
                    .animation(.spring(response: 0.15), value: selectedDetail)
                }
            }
        }
        .cardStyle()
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
                            .font(AppFont.bodyLarge)
                        Text("Back")
                            .font(AppFont.bodyLarge)
                    }
                }
                .ghostButton()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .stroke(Color.almostAquaDark.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1 + (pulse ? 0.1 : 0))
                
                Circle()
                    .fill(Color.almostAquaDark.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1 + (pulse ? 0.08 : 0))
                
                Circle()
                    .fill(Color.almostAquaDark.opacity(0.08))
                    .frame(width: 140, height: 140)
                
                ZStack {
                    Circle()
                        .fill(Color.backgroundCard)
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "checkmark")
                        .font(AppFont.serif(38))
                        .foregroundStyle(Color.almostAquaDark)
                }
                .scaleEffect(appear ? 1 : 0)
            }
            .padding(.bottom, AppSpacing.xxl)
            
            // Text
            VStack(spacing: 12) {
                Text("You're all set")
                    .font(AppFont.heroTitle)
                    .foregroundStyle(Color.inkPrimary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Let's start tracking your\nbaby's next feed")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(Color.inkSecondary)
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
                        .font(AppFont.bodyLarge)
                    Image(systemName: "arrow.right")
                        .font(AppFont.bodyLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .buttonStyle(RefinedPressEffect())
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appear = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) { pulse = true }
        }
    }
}

// MARK: - Decorative Shapes

struct OrganicBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * 0.85, y: 0),
            control2: CGPoint(x: w, y: h * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h),
            control1: CGPoint(x: w, y: h * 0.8),
            control2: CGPoint(x: w * 0.75, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.6),
            control1: CGPoint(x: w * 0.25, y: h),
            control2: CGPoint(x: 0, y: h * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * 0.15, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.4
        
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            let r = i % 2 == 0 ? outer : inner
            let pt = CGPoint(x: c.x + r * cos(angle), y: c.y + r * sin(angle))
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Button Style
struct GlassPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct RefinedPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}



#Preview {
    OnboardingView()
        .environment(FeedStore())
}
