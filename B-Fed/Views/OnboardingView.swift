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
    @State private var direction: CGFloat = 0
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 0) {
                // Progress dots
                ProgressDots(currentStep: currentStep, totalSteps: 4)
                    .padding(.top, 16)
                
                // Content with transitions
                ZStack {
                    if currentStep == 0 {
                        WelcomeScreen {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                currentStep = 1
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(x: 0)),
                            removal: .opacity.combined(with: .offset(x: -50))
                        ))
                    }
                    
                    if currentStep == 1 {
                        AgeScreen(
                            ageUnit: $ageUnit,
                            ageValue: $ageValue,
                            weight: $weight,
                            showWeightInput: $showWeightInput,
                            onContinue: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    currentStep = 2
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(x: direction > 0 ? 50 : -50)),
                            removal: .opacity.combined(with: .offset(x: -50))
                        ))
                    }
                    
                    if currentStep == 2 {
                        FeedingSetupScreen(
                            feedingType: $feedingType,
                            feedingDetail: $feedingDetail,
                            onContinue: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                    currentStep = 3
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(x: 50)),
                            removal: .opacity.combined(with: .offset(x: -50))
                        ))
                    }
                    
                    if currentStep == 3 {
                        CompletionScreen {
                            completeOnboarding()
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(x: 50)),
                            removal: .opacity.combined(with: .offset(x: 0))
                        ))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.9), value: currentStep)
            }
        }
    }
    
    private func completeOnboarding() {
        let ageInWeeks = ageUnit == .weeks ? ageValue : ageValue * 4
        
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

enum AgeUnit {
    case days, weeks, months
}

// MARK: - Premium Background
struct PremiumBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#FAFBF9"),
                    Color(hex: "#F5F7F4"),
                    Color(hex: "#F0F2EE")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.brandPrimary.opacity(0.04),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.3),
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Progress Dots
struct ProgressDots: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.brandPrimary : Color.gray.opacity(0.2))
                    .frame(width: index == currentStep ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appear = false
    @State private var bottleFill: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated bottle
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.06))
                    .frame(width: 200, height: 200)
                
                GentleBottle(fillLevel: bottleFill)
                    .frame(width: 100, height: 140)
            }
            .padding(.bottom, 48)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            
            // Headline
            VStack(spacing: 12) {
                Text("Feel confident\nfeeding your baby")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Text("Track feeds, spot patterns, and know\nthey're getting enough")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 15)
            
            Spacer()
            
            // CTA
            Button(action: onContinue) {
                Text("Get started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.25), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appear = true }
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) { bottleFill = 0.6 }
        }
    }
}

// MARK: - Gentle Bottle
struct GentleBottle: View {
    let fillLevel: CGFloat
    
    var body: some View {
        ZStack {
            // Bottle outline
            BottleShape()
                .stroke(Color.brandPrimary.opacity(0.25), lineWidth: 2)
            
            // Liquid fill
            BottleShape()
                .fill(Color.brandPrimary.opacity(0.15))
                .mask(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 140 * fillLevel)
                    }
                )
            
            // Teat
            Capsule()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(width: 20, height: 10)
                .offset(y: -72)
        }
    }
}

struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.35))
        path.addCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.45),
            control1: CGPoint(x: w * 0.3, y: h * 0.4),
            control2: CGPoint(x: w * 0.2, y: h * 0.42)
        )
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.88))
        path.addCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.88),
            control1: CGPoint(x: w * 0.15, y: h * 0.98),
            control2: CGPoint(x: w * 0.85, y: h * 0.98)
        )
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.45))
        path.addCurve(
            to: CGPoint(x: w * 0.7, y: h * 0.35),
            control1: CGPoint(x: w * 0.8, y: h * 0.42),
            control2: CGPoint(x: w * 0.7, y: h * 0.4)
        )
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.25))
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
    
    @State private var showPicker = false
    @State private var appear = false
    
    var ageDisplay: String {
        switch ageUnit {
        case .days:
            return ageValue == 1 ? "1 day old" : "\(ageValue) days old"
        case .weeks:
            return ageValue == 1 ? "1 week old" : "\(ageValue) weeks old"
        case .months:
            return ageValue == 1 ? "1 month old" : "\(ageValue) months old"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            // Question card
            VStack(spacing: 24) {
                // Age card
                VStack(alignment: .leading, spacing: 8) {
                    Text("How old is your baby?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Button {
                        showPicker = true
                    } label: {
                        HStack {
                            Text(ageDisplay)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.textMuted)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Text("This helps personalise feeding patterns")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 10)
                
                // Weight prompt (conditional)
                if showWeightInput {
                    WeightPrompt(weight: $weight)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                } else {
                    WeightAskCard {
                        withAnimation(.spring(response: 0.4)) {
                            showWeightInput = true
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Continue
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.25), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showPicker) {
            AgePickerSheet(
                ageUnit: $ageUnit,
                ageValue: $ageValue,
                isPresented: $showPicker
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appear = true }
        }
    }
}

// MARK: - Weight Ask Card
struct WeightAskCard: View {
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Do you know your baby's weight?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            
            HStack(spacing: 12) {
                Button(action: onTap) {
                    Text("Yes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.brandPrimary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Button(action: onTap) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.7))
        )
    }
}

// MARK: - Weight Prompt
struct WeightPrompt: View {
    @Binding var weight: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Weight")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textPrimary.opacity(0.8))
            } icon: {
                Image(systemName: "scalemass")
                    .foregroundStyle(Color.textMuted)
            }
            
            HStack {
                TextField("0.0", text: $weight)
                    .font(.system(size: 20, weight: .semibold))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                
                Text("kg")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.8))
            )
            
            Text("If you know it — helps refine recommendations")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.textMuted.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.5))
        )
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
                
                // Unit selector
                Picker("Unit", selection: $ageUnit) {
                    Text("Days").tag(AgeUnit.days)
                    Text("Weeks").tag(AgeUnit.weeks)
                    Text("Months").tag(AgeUnit.months)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Value picker
                Picker("Value", selection: $ageValue) {
                    let maxValue = ageUnit == .days ? 30 : (ageUnit == .weeks ? 12 : 12)
                    let startValue = ageUnit == .days ? 0 : 1
                    ForEach(startValue...maxValue, id: \.self) { value in
                        Text(displayValue(value)).tag(value)
                    }
                }
                .pickerStyle(.wheel)
                
                Button("Done") {
                    isPresented = false
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .presentationDetents([.height(380)])
        .presentationCornerRadius(24)
    }
    
    private func displayValue(_ value: Int) -> String {
        switch ageUnit {
        case .days:
            return value == 0 ? "Newborn" : "\(value) day\(value == 1 ? "" : "s")"
        case .weeks:
            return "\(value) week\(value == 1 ? "" : "s")"
        case .months:
            return "\(value) month\(value == 1 ? "" : "s")"
        }
    }
}

// MARK: - Screen 3: Feeding Setup
struct FeedingSetupScreen: View {
    @Binding var feedingType: FeedingType?
    @Binding var feedingDetail: String?
    let onContinue: () -> Void
    
    @State private var showDetail = false
    @State private var confirmationText = ""
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Main question
                    if !showDetail {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How are you feeding?")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                            
                            VStack(spacing: 12) {
                                FeedingCard(
                                    icon: "drop.fill",
                                    title: "Breastfeeding",
                                    subtitle: "Nursing directly",
                                    color: .warmCoral,
                                    isSelected: feedingType == .breast
                                ) {
                                    selectType(.breast, confirmation: "Got it — we'll help track feeding sessions")
                                }
                                
                                FeedingCard(
                                    icon: "fork.knife",
                                    title: "Formula",
                                    subtitle: "Bottle feeding",
                                    color: .brandPrimary,
                                    isSelected: feedingType == .formula
                                ) {
                                    selectType(.formula, confirmation: "Got it — we'll tailor tracking to formula")
                                }
                                
                                FeedingCard(
                                    icon: "arrow.triangle.2.circlepath",
                                    title: "Mixed",
                                    subtitle: "Both methods",
                                    color: .warmPurple,
                                    isSelected: feedingType == .mixed
                                ) {
                                    selectType(.mixed, confirmation: "Got it — we'll track both methods")
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                    
                    // Follow-up question
                    if showDetail, let type = feedingType {
                        FollowUpQuestion(
                            type: type,
                            detail: $feedingDetail,
                            onContinue: onContinue
                        )
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                    }
                    
                    // Confirmation bubble
                    if showConfirmation && !showDetail {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.warmGold)
                            Text(confirmationText)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.warmGold.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func selectType(_ type: FeedingType, confirmation: String) {
        feedingType = type
        confirmationText = confirmation
        
        withAnimation(.spring(response: 0.35)) {
            showConfirmation = true
        }
        
        // Show detail question after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4)) {
                showDetail = true
            }
        }
    }
}

// MARK: - Feeding Card
struct FeedingCard: View {
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
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : color)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? color.opacity(0.3) : color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : Color.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(isSelected ? color.opacity(0.3) : Color.textMuted)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? color : Color.white)
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.04),
                        radius: isSelected ? 16 : 10,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : (isSelected ? 1.02 : 1.0))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Follow Up Question
struct FollowUpQuestion: View {
    let type: FeedingType
    @Binding var detail: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch type {
            case .formula:
                Text("How do you usually measure feeds?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                VStack(spacing: 12) {
                    DetailButton(title: "Bottle (ml)", icon: "drop.fill", isSelected: detail == "bottle") {
                        detail = "bottle"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                    
                    DetailButton(title: "Approximate", icon: "eye", isSelected: detail == "approx") {
                        detail = "approx"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                }
                
            case .breast:
                Text("Do you want to track duration?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                VStack(spacing: 12) {
                    DetailButton(title: "Yes, with timer", icon: "stopwatch", isSelected: detail == "timer") {
                        detail = "timer"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                    
                    DetailButton(title: "No, simple tracking", icon: "checkmark", isSelected: detail == "simple") {
                        detail = "simple"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                }
                
            case .mixed:
                Text("What do you use more often?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                VStack(spacing: 12) {
                    DetailButton(title: "Breastfeeding", icon: "drop.fill", isSelected: detail == "breast") {
                        detail = "breast"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                    
                    DetailButton(title: "Formula", icon: "fork.knife", isSelected: detail == "formula") {
                        detail = "formula"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onContinue() }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Detail Button
struct DetailButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .white : Color.brandPrimary)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? Color.white.opacity(0.2) : Color.brandPrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : Color.textPrimary)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.brandPrimary : Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

// MARK: - Screen 4: Completion
struct CompletionScreen: View {
    let onStart: () -> Void
    @State private var appear = false
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success icon with pulse
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.05 : 1.0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.brandPrimary)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: Color.brandPrimary.opacity(0.2), radius: 12, x: 0, y: 4)
                    )
            }
            .padding(.bottom, 40)
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.8)
            
            // Text
            VStack(spacing: 12) {
                Text("You're all set")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Let's start tracking your baby's next feed")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 15)
            
            Spacer()
            
            // Start button
            Button(action: onStart) {
                Text("Start tracking")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.25), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(PremiumPressEffect())
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3)) {
                pulse = true
            }
        }
    }
}

// MARK: - Press Effect
struct PremiumPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Press Events
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
    static var warmCoral: Color { Color(hex: "#E8A598") }
    static var warmPurple: Color { Color(hex: "#A895C7") }
    static var warmGold: Color { Color(hex: "#D4B896") }
    
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
