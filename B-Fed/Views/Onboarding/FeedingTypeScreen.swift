import SwiftUI
import SwiftData

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
            .padding(.horizontal, AppSpacing.xl)
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
                .padding(.horizontal, AppSpacing.xl)
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
            .buttonStyle(GentlePressEffect())
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

#Preview {
    FeedingTypeScreen(
        feedingType: .constant(nil),
        onContinue: {},
        onBack: {}
    )
}
