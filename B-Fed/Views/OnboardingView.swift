import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var ageUnit: AgeUnit = .weeks
    @State private var ageValue = 2
    @State private var weight: String = ""
    @State private var showWeightInput = false
    @State private var feedingType: FeedingType?
    @State private var feedingDetail: String?
    
    // Animation states
    @State private var slideOffset: CGFloat = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            WarmBackground()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressStepper(currentStep: currentStep, totalSteps: 4)
                    .padding(.top, 16)
                
                // Screen content with transitions
                ZStack {
                    Group {
                        switch currentStep {
                        case 0:
                            WelcomeScreen {
                                advanceToStep(1)
                            }
                        case 1:
                            AgeScreen(
                                ageUnit: $ageUnit,
                                ageValue: $ageValue,
                                weight: $weight,
                                showWeightInput: $showWeightInput,
                                onContinue: { advanceToStep(2) }
                            )
                        case 2:
                            FeedingScreen(
                                feedingType: $feedingType,
                                feedingDetail: $feedingDetail,
                                onContinue: { advanceToStep(3) }
                            )
                        case 3:
                            CompletionScreen {
                                completeOnboarding()
                            }
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
        
        let direction: CGFloat = step > currentStep ? -1 : 1
        
        // Slide out current
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = direction * -UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            currentStep = step
            slideOffset = direction * UIScreen.main.bounds.width
            
            // Slide in new
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                slideOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimating = false
            }
        }
    }
    
    private func completeOnboarding() {
        let ageInWeeks = ageUnit == .weeks ? ageValue : (ageUnit == .months ? ageValue * 4 : ageValue / 7)
        
        let profile = BabyProfile(
            babyName: "Baby",
            dateOfBirth: Calendar.current.date(byAdding: .weekOfYear, value: -ageInWeeks, to: Date()) ?? Date(),
            birthWeight: Double(weight).map { $0 * 1000 },
            feedingType: feedingType ?? .formula
        )
        
        feedStore.saveBabyProfile(profile)
        dismiss()
    }
}

enum AgeUnit: String, CaseIterable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
}

// MARK: - Warm Background
struct WarmBackground: View {
    var body: some View {
        ZStack {
            // Warm cream gradient
            LinearGradient(
                colors: [
                    Color(hex: "#FDFBF8"),
                    Color(hex: "#F8F5F1"),
                    Color(hex: "#F5F1EC")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Soft ambient glow
            RadialGradient(
                colors: [
                    Color.brandPrimary.opacity(0.06),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.28),
                startRadius: 60,
                endRadius: 280
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
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= currentStep ? Color.brandPrimary : Color.gray.opacity(0.15))
                        .frame(width: index == currentStep ? 28 : 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStep)
                }
                .frame(height: 8)
            }
        }
        .frame(maxWidth: 120)
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    
    @State private var appearPhase = 0
    @State private var bottleFill: CGFloat = 0
    @State private var bottleWave: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated bottle with wave
            ZStack {
                // Outer glow rings
                Circle()
                    .fill(Color.brandPrimary.opacity(0.04))
                    .frame(width: 220, height: 220)
                    .scaleEffect(appearPhase >= 1 ? 1.0 : 0.8)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .scaleEffect(appearPhase >= 1 ? 1.0 : 0.85)
                
                // Bottle container
                ZStack {
                    // Glass bottle
                    BottleWithWave(fillLevel: bottleFill, wavePhase: bottleWave)
                        .frame(width: 110, height: 150)
                }
            }
            .padding(.bottom, 52)
            .opacity(appearPhase >= 1 ? 1 : 0)
            .offset(y: appearPhase >= 1 ? 0 : 30)
            
            // Text content
            VStack(spacing: 14) {
                Text("Feel confident\nfeeding your baby")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .opacity(appearPhase >= 2 ? 1 : 0)
                    .offset(y: appearPhase >= 2 ? 0 : 20)
                
                Text("Track feeds, spot patterns, and know\nthey are getting enough — effortlessly")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(appearPhase >= 3 ? 1 : 0)
                    .offset(y: appearPhase >= 3 ? 0 : 15)
            }
            
            Spacer()
            
            // CTA Button
            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Get started")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                        .offset(x: appearPhase >= 4 ? 0 : -10)
                        .opacity(appearPhase >= 4 ? 1 : 0)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 16, x: 0, y: 6)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .opacity(appearPhase >= 4 ? 1 : 0)
            .offset(y: appearPhase >= 4 ? 0 : 20)
        }
        .padding(.horizontal, 24)
        .onAppear {
            // Staggered appearance
            withAnimation(.easeOut(duration: 0.5)) { appearPhase = 1 }
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) { 
                bottleFill = 0.65 
                appearPhase = 2 
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) { appearPhase = 3 }
            withAnimation(.spring(response: 0.5).delay(0.55)) { appearPhase = 4 }
            
            // Continuous wave animation
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                bottleWave = .pi * 2
            }
        }
    }
}

// MARK: - Bottle with Wave
struct BottleWithWave: View {
    let fillLevel: CGFloat
    let wavePhase: CGFloat
    
    var body: some View {
        ZStack {
            // Bottle glass body
            BottleShape()
                .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 2.5)
            
            // Liquid with wave
            BottleShape()
                .fill(Color.brandPrimary.opacity(0.15))
                .overlay(
                    WaveLiquid(fillLevel: fillLevel, phase: wavePhase)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brandPrimaryLight.opacity(0.8),
                                    Color.brandPrimary.opacity(0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .clipShape(BottleShape())
            
            // Glass highlight
            BottleShape()
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
            
            // Teat
            Capsule()
                .fill(Color.brandPrimary.opacity(0.25))
                .frame(width: 22, height: 12)
                .offset(y: -78)
        }
    }
}

struct WaveLiquid: Shape {
    let fillLevel: CGFloat
    let phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterLevel = rect.height * (1 - fillLevel)
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        
        // Create gentle wave
        for x in stride(from: 0, to: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + phase)
            let y = waterLevel + sine * 4
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

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

// MARK: - Screen 2: Age
struct AgeScreen: View {
    @Binding var ageUnit: AgeUnit
    @Binding var ageValue: Int
    @Binding var weight: String
    @Binding var showWeightInput: Bool
    let onContinue: () -> Void
    
    @State private var appear = false
    @State private var showPicker = false
    @State private var cardScale: CGFloat = 1.0
    
    var ageDisplay: String {
        switch ageUnit {
        case .days:
            if ageValue == 0 { return "Newborn" }
            return ageValue == 1 ? "1 day old" : "\(ageValue) days old"
        case .weeks:
            return ageValue == 1 ? "1 week old" : "\(ageValue) weeks old"
        case .months:
            return ageValue == 1 ? "1 month old" : "\(ageValue) months old"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How old is your baby?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("This helps personalise everything")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.top, 20)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)
                    
                    // Age Card (Primary)
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.2)) {
                                cardScale = 0.97
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                cardScale = 1.0
                                showPicker = true
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Age")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.textMuted)
                                        .textCase(.uppercase)
                                    
                                    Text(ageDisplay)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.brandPrimary)
                                    .padding(10)
                                    .background(Color.brandPrimary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.brandPrimary.opacity(0.12), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(cardScale)
                        
                        // Helper text integrated
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.warmAccent)
                            Text("Personalised for \(ageDisplay.lowercased())")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.textMuted)
                        }
                        .padding(.leading, 4)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    
                    // Weight Section (Conditional)
                    if !showWeightInput {
                        WeightPromptCard {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showWeightInput = true
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom).combined(with: .scale(0.95))),
                            removal: .opacity
                        ))
                    } else {
                        WeightInputCard(weight: $weight)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .trailing)),
                                removal: .opacity
                            ))
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            
            // Continue Button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 16, x: 0, y: 6)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
        .sheet(isPresented: $showPicker) {
            AgePickerSheet(
                ageUnit: $ageUnit,
                ageValue: $ageValue,
                isPresented: $showPicker
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
        }
    }
}

// MARK: - Weight Prompt Card
struct WeightPromptCard: View {
    let onTapYes: () -> Void
    @State private var isPressedYes = false
    @State private var isPressedSkip = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Do you know your baby's weight?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.2)) { isPressedYes = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressedYes = false
                        onTapYes()
                    }
                } label: {
                    Text("Yes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.brandPrimary.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressedYes ? 0.96 : 1.0)
                
                Button {
                    withAnimation(.spring(response: 0.2)) { isPressedSkip = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressedSkip = false
                        // Skip logic
                    }
                } label: {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gray.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressedSkip ? 0.96 : 1.0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.5))
        )
    }
}

// MARK: - Weight Input Card
struct WeightInputCard: View {
    @Binding var weight: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("Weight")
                        .font(.system(size: 17, weight: .semibold))
                } icon: {
                    Image(systemName: "scalemass.fill")
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
                
                Text("Optional")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textMuted.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 8) {
                TextField("0.0", text: $weight)
                    .font(.system(size: 22, weight: .semibold))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                
                Text("kg")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textMuted.opacity(0.6))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
            )
            
            Text("Helps refine recommendations")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.textMuted.opacity(0.7))
                .padding(.leading, 4)
        }
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Age Picker Sheet
struct AgePickerSheet: View {
    @Binding var ageUnit: AgeUnit
    @Binding var ageValue: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Select age")
                    .font(.headline.weight(.semibold))
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                
                // Unit selector
                Picker("Unit", selection: $ageUnit) {
                    ForEach(AgeUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                // Value picker with larger text
                Picker("Value", selection: $ageValue) {
                    let range = ageUnit == .days ? 0...30 : (ageUnit == .weeks ? 1...12 : 1...12)
                    ForEach(range, id: \.self) { value in
                        Text(displayValue(value))
                            .tag(value)
                            .font(.system(size: 22, weight: .medium))
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                Button("Done") {
                    isPresented = false
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.height(400)])
        .presentationCornerRadius(28)
        .presentationBackgroundInteraction(.enabled)
    }
    
    private func displayValue(_ value: Int) -> String {
        switch ageUnit {
        case .days:
            if value == 0 { return "Newborn" }
            return "\(value) day\(value == 1 ? "" : "s")"
        case .weeks:
            return "\(value) week\(value == 1 ? "" : "s")"
        case .months:
            return "\(value) month\(value == 1 ? "" : "s")"
        }
    }
}

// MARK: - Screen 3: Feeding
struct FeedingScreen: View {
    @Binding var feedingType: FeedingType?
    @Binding var feedingDetail: String?
    let onContinue: () -> Void
    
    @State private var showDetail = false
    @State private var confirmationScale: CGFloat = 0
    @State private var selectedType: FeedingType?
    
    let options: [(type: FeedingType, icon: String, title: String, subtitle: String, color: Color)] = [
        (.breast, "drop.fill", "Breastfeeding", "Nursing directly", Color.warmCoral),
        (.formula, "fork.knife", "Formula", "Bottle feeding", Color.brandPrimary),
        (.mixed, "arrow.triangle.2.circlepath", "Mixed", "Both methods", Color.warmLavender)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How are you feeding?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        
                        if !showDetail {
                            Text("Select one to continue")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Main feeding selection
                    if !showDetail {
                        VStack(spacing: 14) {
                            ForEach(options, id: \.type) { option in
                                FeedingTypeButton(
                                    icon: option.icon,
                                    title: option.title,
                                    subtitle: option.subtitle,
                                    color: option.color,
                                    isSelected: feedingType == option.type
                                ) {
                                    selectType(option.type, color: option.color)
                                }
                            }
                        }
                        
                        // Integrated micro-feedback
                        if let type = selectedType, let message = confirmationMessage(for: type) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.warmAccent)
                                Text(message)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.warmAccent.opacity(0.12))
                            )
                            .scaleEffect(confirmationScale)
                            .padding(.top, 8)
                        }
                    }
                    
                    // Follow-up question (conditional)
                    if showDetail, let type = feedingType {
                        FollowUpSection(
                            type: type,
                            detail: $feedingDetail,
                            onContinue: onContinue
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            
            // Continue button (only shown after follow-up completed)
            if showDetail && feedingDetail != nil {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(
                                colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.brandPrimary.opacity(0.3), radius: 16, x: 0, y: 6)
                }
                .buttonStyle(PremiumPressEffect())
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func selectType(_ type: FeedingType, color: Color) {
        feedingType = type
        selectedType = type
        
        // Animate confirmation
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            confirmationScale = 1.0
        }
        
        // Show follow-up after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showDetail = true
            }
        }
    }
    
    private func confirmationMessage(for type: FeedingType) -> String? {
        switch type {
        case .breast: return "Perfect for breastfeeding"
        case .formula: return "Tailored for formula feeding"
        case .mixed: return "Great — we'll track both"
        default: return nil
        }
    }
}

// MARK: - Feeding Type Button
struct FeedingTypeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with dynamic background
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isSelected ? color : color.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
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
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? color.opacity(0.08) : Color.white)
                    .shadow(
                        color: isSelected ? color.opacity(0.15) : Color.black.opacity(0.04),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 4 : 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : (isSelected ? 1.02 : 1.0))
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
        .pressEvents {
            withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
        } onRelease: {
            withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
        }
    }
}

// MARK: - Follow Up Section
struct FollowUpSection: View {
    let type: FeedingType
    @Binding var detail: String?
    let onContinue: () -> Void
    
    var question: String {
        switch type {
        case .formula: return "How do you measure feeds?"
        case .breast: return "Track feeding duration?"
        case .mixed: return "What do you use more?"
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
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 8)
            
            VStack(spacing: 12) {
                ForEach(options, id: \.id) { option in
                    DetailSelectionButton(
                        icon: option.icon,
                        title: option.title,
                        isSelected: detail == option.id
                    ) {
                        withAnimation(.spring(response: 0.25)) {
                            detail = option.id
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Detail Selection Button
struct DetailSelectionButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color.brandPrimary)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.brandPrimary.opacity(0.1))
                    )
                
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : Color.textPrimary)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.brandPrimary : Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : (isSelected ? 1.01 : 1.0))
        .animation(.spring(response: 0.2), value: isSelected)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Screen 4: Completion
struct CompletionScreen: View {
    let onStart: () -> Void
    
    @State private var appearPhase = 0
    @State private var ringScale: CGFloat = 0
    @State private var checkScale: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated success rings
            ZStack {
                // Outer pulsing ring
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1 + ringScale * 0.15)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .scaleEffect(appearPhase >= 1 ? 1 : 0.5)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(appearPhase >= 1 ? 1 : 0.6)
                
                // Checkmark
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.brandPrimary.opacity(0.25), radius: 20, x: 0, y: 8)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color.brandPrimary)
                }
                .scaleEffect(checkScale)
            }
            .padding(.bottom, 48)
            
            // Text
            VStack(spacing: 12) {
                Text("You are all set")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .opacity(appearPhase >= 2 ? 1 : 0)
                    .offset(y: appearPhase >= 2 ? 0 : 20)
                
                Text("Let's start tracking your\nbaby's next feed")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(appearPhase >= 3 ? 1 : 0)
                    .offset(y: appearPhase >= 3 ? 0 : 15)
            }
            
            Spacer()
            
            // Start button
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
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.brandPrimary.opacity(0.35), radius: 20, x: 0, y: 8)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .opacity(appearPhase >= 4 ? 1 : 0)
            .offset(y: appearPhase >= 4 ? 0 : 20)
        }
        .onAppear {
            // Staggered entrance animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appearPhase = 1
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.15)) {
                checkScale = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.35)) { appearPhase = 2 }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) { appearPhase = 3 }
            withAnimation(.spring(response: 0.4).delay(0.7)) { appearPhase = 4 }
            
            // Continuous pulse
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                ringScale = 1
            }
        }
    }
}

// MARK: - Effects
struct PremiumPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Colors
private extension Color {
    static var brandPrimary: Color { Color(hex: "#2D6A5E") }
    static var brandPrimaryLight: Color { Color(hex: "#4A8B7C") }
    static var warmCoral: Color { Color(hex: "#D4897A") }
    static var warmLavender: Color { Color(hex: "#9B8CB5") }
    static var warmAccent: Color { Color(hex: "#C4A574") }
    
    static var textPrimary: Color { Color(hex: "#1A1A1A") }
    static var textSecondary: Color { Color(hex: "#5A5A5A") }
    static var textMuted: Color { Color(hex: "#7A7A7A") }
    
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
