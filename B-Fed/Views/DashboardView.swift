import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var showingLogFeed = false
    @State private var selectedPeriod: TimePeriod = .today
    var onSwitchToHistoryTab: () -> Void = {}
    
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    private var hasFeeds: Bool {
        !allFeeds.isEmpty
    }
    
    // MARK: - Today Feeds
    private var todayFeeds: [Feed] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allFeeds.filter { $0.startTime >= startOfDay && $0.startTime < endOfDay }
    }
    
    var totalMlToday: Int {
        Int(todayFeeds.reduce(0) { $0 + $1.amount })
    }
    
    var lastFeedMinutesAgo: Int? {
        guard let last = todayFeeds.first else { return nil }
        return Int(Date().timeIntervalSince(last.startTime) / 60)
    }
    
    var feedsInLastFourHours: [Feed] {
        let cutoff = Date().addingTimeInterval(-4 * 3600)
        return todayFeeds.filter { $0.startTime >= cutoff }
    }
    
    private var babyName: String {
        feedStore.babyProfile?.babyName ?? "Baby"
    }
    
    // MARK: - Greeting
    var headerText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 0 && hour < 5 {
            return "You're doing great tonight"
        }
        if todayFeeds.isEmpty {
            return "Ready when you are, \(babyName)"
        }
        guard let mins = lastFeedMinutesAgo else {
            return "\(babyName) is doing well"
        }
        switch mins {
        case 0..<10:
            return "\(babyName) just had a feed"
        case 10..<120:
            let h = mins / 60
            let m = mins % 60
            if h > 0 {
                return "\(babyName) fed \(h)h \(m)min ago"
            } else {
                return "\(babyName) fed \(m)min ago"
            }
        case 120..<180:
            return "\(babyName) is due a feed soon"
        default:
            return "It's been a while for \(babyName)"
        }
    }
    
    var dailySummaryText: String {
        if todayFeeds.isEmpty {
            return "No feeds logged yet today"
        }
        return "\(todayFeeds.count) feeds · \(totalMlToday)ml today"
    }
    
    // MARK: - Reassurance Text
    var reassuranceText: (headline: String, subtext: String) {
        if todayFeeds.isEmpty {
            return ("When you log a feed", "it will appear here")
        }
        guard let mins = lastFeedMinutesAgo else {
            return ("Take your time", "Log when ready")
        }
        switch mins {
        case 0..<30:
            return ("Just finished", "Nice work")
        case 30..<90:
            return ("Feeding well today", "Next feed in around \(90 - mins) minutes")
        case 90..<150:
            return ("Due a feed soon", "Last feed \(mins)min ago")
        default:
            return ("Take your time", "Log when ready")
        }
    }
    
    // MARK: - Bottle Timer
    private var bottleTimerRemainingMinutes: Int {
        let freshnessWindow: TimeInterval = 2 * 3600 // 2 hours
        let remaining = freshnessWindow - feedStore.timerElapsed
        return max(0, Int(remaining / 60))
    }
    
    private var bottleTimerIsExpired: Bool {
        bottleTimerRemainingMinutes <= 0 && feedStore.isTimerRunning
    }
    
    private var bottleTimerIsUrgent: Bool {
        bottleTimerRemainingMinutes < 30 && bottleTimerRemainingMinutes > 0 && feedStore.isTimerRunning
    }
    
    private var bottleTimerUseByTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        let useByDate = Date().addingTimeInterval(TimeInterval(bottleTimerRemainingMinutes * 60))
        return formatter.string(from: useByDate).lowercased()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(hex: "FAFAF8").ignoresSafeArea(.all)
                
                // Background blobs
                ZStack {
                    // Subtle peach top-right
                    Ellipse()
                        .fill(Color.peachDust)
                        .opacity(0.40)
                        .frame(
                            width: geometry.size.width * 0.90,
                            height: geometry.size.width * 0.90
                        )
                        .position(
                            x: geometry.size.width * 0.85,
                            y: geometry.size.width * 0.10
                        )
                    
                    // Lemon icing smaller top-right
                    Ellipse()
                        .fill(Color.lemonIcing)
                        .opacity(0.45)
                        .frame(
                            width: geometry.size.width * 0.48,
                            height: geometry.size.width * 0.48
                        )
                        .position(
                            x: geometry.size.width * 0.88,
                            y: geometry.size.width * 0.08
                        )
                    
                    // Aqua bottom-left
                    Ellipse()
                        .fill(Color.almostAquaLight)
                        .opacity(0.40)
                        .frame(
                            width: geometry.size.width * 0.80,
                            height: geometry.size.width * 0.80
                        )
                        .position(
                            x: geometry.size.width * 0.10,
                            y: geometry.size.height * 0.90
                        )
                }
                .allowsHitTesting(false)
                .ignoresSafeArea(.all)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header zone
                        VStack(alignment: .leading, spacing: 12) {
                            Text(headerText)
                                .font(AppFont.serif(24))
                                .foregroundStyle(Color.inkPrimary)
                            
                            DailySummaryPill(
                                feedCount: todayFeeds.count,
                                totalMl: totalMlToday,
                                hasFeeds: !todayFeeds.isEmpty
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                        
                        // Feed bubble arc
                        FeedBubbleArcView(
                            feeds: feedsInLastFourHours,
                            geometry: geometry,
                            onSeeAllTapped: onSwitchToHistoryTab
                        )
                        .padding(.top, 20)
                        
                        // Bottle timer card (if active)
                        if feedStore.isTimerRunning {
                            BottleTimerCard(
                                useByTime: bottleTimerUseByTime,
                                remainingMinutes: bottleTimerRemainingMinutes,
                                isUrgent: bottleTimerIsUrgent,
                                isExpired: bottleTimerIsExpired
                            )
                            .padding(.horizontal, 18)
                            .padding(.top, 20)
                        }
                        
                        // Reassurance zone
                        VStack(spacing: 8) {
                            Text(reassuranceText.headline)
                                .font(AppFont.serif(15))
                                .foregroundStyle(Color.inkPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(reassuranceText.subtext)
                                .font(AppFont.sans(12, weight: .regular))
                                .foregroundStyle(Color.inkSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        
                        // Existing dashboard content
                        if hasFeeds {
                            PopulatedDashboardView(
                                selectedPeriod: $selectedPeriod,
                                showingLogFeed: $showingLogFeed
                            )
                        } else {
                            FirstTimeDashboardView(showingLogFeed: $showingLogFeed)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showingLogFeed) {
            LogFeedSheet()
        }
    }
    

}

// MARK: - Daily Summary Pill
struct DailySummaryPill: View {
    let feedCount: Int
    let totalMl: Int
    let hasFeeds: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if hasFeeds {
                Text("\(feedCount)")
                    .font(AppFont.sans(11, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                Text(" feeds · ")
                    .font(AppFont.sans(11, weight: .regular))
                    .foregroundStyle(Color.inkSecondary)
                Text("\(totalMl)ml")
                    .font(AppFont.sans(11, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                Text(" today")
                    .font(AppFont.sans(11, weight: .regular))
                    .foregroundStyle(Color.inkSecondary)
            } else {
                Text("No feeds logged yet today")
                    .font(AppFont.sans(11, weight: .regular))
                    .foregroundStyle(Color.inkSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white)
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Bottle Timer Card
struct BottleTimerCard: View {
    let useByTime: String
    let remainingMinutes: Int
    let isUrgent: Bool
    let isExpired: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("BOTTLE TIMER")
                    .font(AppFont.sans(9, weight: .semibold))
                    .foregroundStyle(Color.peachDustDark)
                    .tracking(0.3)
                
                if isExpired {
                    Text("Bottle should be discarded")
                        .font(AppFont.sans(12, weight: .regular))
                        .foregroundStyle(Color.orchidTintDark)
                } else {
                    Text("Use by \(useByTime) · \(remainingMinutes) min remaining")
                        .font(AppFont.sans(12, weight: .regular))
                        .foregroundStyle(Color.inkSecondary)
                }
            }
            
            Spacer()
            
            if !isExpired {
                Text(remainingTimeString)
                    .font(AppFont.serif(18))
                    .foregroundStyle(isUrgent ? Color.peachDustDark : Color.peachDustDark)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isExpired ? Color.orchidTintLight : Color.peachDustLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isUrgent || isExpired ? Color.peachDustDark : Color.peachDust, lineWidth: 0.5)
        )
    }
    
    private var remainingTimeString: String {
        if remainingMinutes >= 60 {
            let h = remainingMinutes / 60
            let m = remainingMinutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(remainingMinutes)m"
    }
}

// MARK: - First Time Dashboard (Empty State)
struct FirstTimeDashboardView: View {
    @Binding var showingLogFeed: Bool
    
    @Environment(FeedStore.self) private var feedStore
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: AppSpacing.xxl)
            
            // Empty bottle (outline only)
            EmptyBottleView()
                .frame(width: 120, height: 180)
            
            Spacer().frame(height: AppSpacing.xxl)
            
            // Primary message
            Text("Let's log your first feed")
                .font(AppFont.heroTitle)
                .foregroundStyle(Color.inkPrimary)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 8)
            
            // Secondary reassurance
            Text("You're doing great already")
                .font(AppFont.bodyLarge)
                .foregroundStyle(Color.inkSecondary)
            
            Spacer().frame(height: 32)
            
            // Log Feed Button
            Button(action: { showingLogFeed = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(AppFont.bodyLarge)
                    Text("Log Feed")
                        .font(AppFont.bodyLarge)
                }
                .frame(maxWidth: .infinity)
                .primaryButton()
            }
            .buttonStyle(GentlePressEffect())
            .padding(.horizontal, AppSpacing.xl)
            
            // Formula info card (if applicable)
            if let profile = feedStore.babyProfile,
               profile.showsFormulaInfo {
                FormulaInfoCard(profile: profile)
                    .padding(.top, AppSpacing.xl)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer().frame(height: 100)
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Empty Bottle View (Outline only)
struct EmptyBottleView: View {
    var body: some View {
        ZStack {
            // Soft glow background
            Circle()
                .fill(Color.almostAquaDark.opacity(0.05))
                .frame(width: 200, height: 200)
            
            // Bottle outline
            BottleOutlineShape()
                .stroke(
                    Color.almostAquaDark.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
            
            // Subtle teat
            Ellipse()
                .fill(Color.almostAquaDark.opacity(0.2))
                .frame(width: 20, height: 12)
                .offset(y: -82)
        }
    }
}

// MARK: - Bottle Outline Shape
struct BottleOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.35
        let bodyWidth = width * 0.75
        let neckHeight = height * 0.25
        let shoulderHeight = height * 0.35
        
        // Start at bottom left
        path.move(to: CGPoint(x: (width - bodyWidth) / 2, y: height - 20))
        
        // Bottom curve
        path.addCurve(
            to: CGPoint(x: (width + bodyWidth) / 2, y: height - 20),
            control1: CGPoint(x: (width - bodyWidth) / 2 + 10, y: height - 5),
            control2: CGPoint(x: (width + bodyWidth) / 2 - 10, y: height - 5)
        )
        
        // Right side
        path.addLine(to: CGPoint(x: (width + bodyWidth) / 2, y: shoulderHeight))
        
        // Right shoulder
        path.addCurve(
            to: CGPoint(x: (width + neckWidth) / 2, y: neckHeight),
            control1: CGPoint(x: (width + bodyWidth) / 2 - 5, y: shoulderHeight - 10),
            control2: CGPoint(x: (width + neckWidth) / 2 + 5, y: neckHeight + 10)
        )
        
        // Right neck
        path.addLine(to: CGPoint(x: (width + neckWidth) / 2, y: 25))
        
        // Top rim
        path.addCurve(
            to: CGPoint(x: (width - neckWidth) / 2, y: 25),
            control1: CGPoint(x: (width + neckWidth) / 2 - 3, y: 20),
            control2: CGPoint(x: (width - neckWidth) / 2 + 3, y: 20)
        )
        
        // Left neck
        path.addLine(to: CGPoint(x: (width - neckWidth) / 2, y: neckHeight))
        
        // Left shoulder
        path.addCurve(
            to: CGPoint(x: (width - bodyWidth) / 2, y: shoulderHeight),
            control1: CGPoint(x: (width - neckWidth) / 2 - 5, y: neckHeight + 10),
            control2: CGPoint(x: (width - bodyWidth) / 2 + 5, y: shoulderHeight - 10)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Populated Dashboard (After First Feed)
struct PopulatedDashboardView: View {
    @Binding var selectedPeriod: TimePeriod
    @Binding var showingLogFeed: Bool
    
    @Environment(FeedStore.self) private var feedStore
    
    // Animation states
    @State private var bottleFillLevel: CGFloat = 0
    @State private var showReassurance = false
    @State private var reassuranceMessage = ""
    @State private var animateStats = false
    
    // Target fill level
    private var targetFillLevel: CGFloat {
        feedStore.getBottleFillLevel()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeroCardPopulated(
                selectedPeriod: $selectedPeriod,
                bottleFillLevel: bottleFillLevel,
                showReassurance: $showReassurance,
                reassuranceMessage: reassuranceMessage,
                showingLogFeed: $showingLogFeed,
                animateStats: animateStats
            )
            
            if selectedPeriod == .last7Days {
                InsightsSection()
            }
            
            // Formula info card (if applicable)
            if let profile = feedStore.babyProfile,
               profile.showsFormulaInfo {
                FormulaInfoCard(profile: profile)
            }
            
            PrepGuideLink()
            
            TipsSection()
            
            RecentFeedsSection()
            
            // Log Feed Button
            Button(action: { showingLogFeed = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(AppFont.bodyLarge)
                    Text("Log Feed")
                        .font(AppFont.bodyLarge)
                }
                .frame(maxWidth: .infinity)
                .primaryButton()
            }
            .buttonStyle(GentlePressEffect())
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, AppSpacing.xxl)
        .onAppear {
            // Check if this is the first feed (bottle was empty)
            let isFirstFeed = bottleFillLevel == 0 && targetFillLevel > 0
            
            if isFirstFeed {
                // Trigger first-feed experience
                triggerFirstFeedExperience()
            } else {
                // Just set the level without animation
                bottleFillLevel = targetFillLevel
            }
        }
        .onChange(of: targetFillLevel) { _, newLevel in
            // Animate when level changes (new feed logged)
            if newLevel > bottleFillLevel {
                animateBottleFill(to: newLevel)
            }
        }
    }
    
    private func triggerFirstFeedExperience() {
        // Liquid rise animation - smooth upward fill
        withAnimation(MotionCurve.liquid) {
            bottleFillLevel = targetFillLevel
        }
        
        // Show reassurance message
        reassuranceMessage = ReassuranceEngine.postFeedEncouragement()
        
        withAnimation(MotionCurve.standard.delay(0.3)) {
            showReassurance = true
        }
        
        // Fade out gently after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(MotionCurve.standard) {
                showReassurance = false
            }
        }
        
        // Animate stats appearing with stagger
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(MotionCurve.gentleReturn) {
                animateStats = true
            }
        }
    }
    
    private func animateBottleFill(to newLevel: CGFloat) {
        // Liquid rise - smooth upward fill
        withAnimation(MotionCurve.liquid) {
            bottleFillLevel = newLevel
        }
        
        // Show reassurance with gentle fade
        reassuranceMessage = ReassuranceEngine.postFeedEncouragement()
        withAnimation(MotionCurve.standard) {
            showReassurance = true
        }
        
        // Fade out gently
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(MotionCurve.standard) {
                showReassurance = false
            }
        }
    }
}

// MARK: - Hero Card (Populated State)
struct HeroCardPopulated: View {
    @Binding var selectedPeriod: TimePeriod
    let bottleFillLevel: CGFloat
    @Binding var showReassurance: Bool
    let reassuranceMessage: String
    @Binding var showingLogFeed: Bool
    let animateStats: Bool
    
    @Environment(FeedStore.self) private var feedStore
    
    var body: some View {
        VStack(spacing: 20) {
            PeriodSelector(selectedPeriod: $selectedPeriod)
            
            ZStack {
                VStack(spacing: 12) {
                    // Contextual guidance (if needed)
                    if let guidance = feedStore.getContextualGuidance() {
                        GuidanceBubble(text: guidance)
                    }
                    
                    // Animated bottle
                    FillingBottleView(fillLevel: bottleFillLevel)
                        .frame(width: 100, height: 160)
                    
                    // Intake display
                    Text(feedStore.getIntakeDisplay())
                        .font(AppFont.serif(20))
                        .foregroundStyle(Color.inkPrimary)
                        .monospacedDigit()
                }
                
                // Reassurance message overlay
                if showReassurance {
                    ReassuranceBubble(message: reassuranceMessage)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            
            // Stats grid with animation
            if animateStats {
                StatsGrid()
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .cardStyle()
    }
}

// MARK: - Filling Bottle View (with wave animation)
struct FillingBottleView: View {
    let fillLevel: CGFloat
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Bottle glass
            BottleGlassShape()
                .fill(Color.white.opacity(0.6))
            
            // Liquid with wave
            LiquidWithWave(fillLevel: fillLevel, phase: wavePhase)
                .clipShape(BottleGlassShape())
            
            // Glass highlights
            BottleGlassShape()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
        }
        .onAppear {
            // Continuous gentle wave animation
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - Liquid with Wave
struct LiquidWithWave: View {
    let fillLevel: CGFloat
    let phase: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base liquid
                Rectangle()
                    .fill(Color.almostAquaDark)
                    .frame(height: geometry.size.height * fillLevel)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
                // Wave surface
                DashboardWaveShape(fillLevel: fillLevel, phase: phase)
                    .fill(Color.almostAqua.opacity(0.9))
                    .frame(height: geometry.size.height)
            }
        }
    }
}

// MARK: - Wave Shape
struct DashboardWaveShape: Shape {
    let fillLevel: CGFloat
    let phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waterLevel = rect.height * (1 - fillLevel)
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        
        // Create wave
        for x in stride(from: 0, to: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 3 + phase)
            let y = waterLevel + sine * 3
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Bottle Glass Shape
struct BottleGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.35
        let bodyWidth = width * 0.75
        
        path.move(to: CGPoint(x: (width - bodyWidth) / 2, y: height - 15))
        
        path.addCurve(
            to: CGPoint(x: (width + bodyWidth) / 2, y: height - 15),
            control1: CGPoint(x: (width - bodyWidth) / 2 + 8, y: height),
            control2: CGPoint(x: (width + bodyWidth) / 2 - 8, y: height)
        )
        
        path.addLine(to: CGPoint(x: (width + bodyWidth) / 2, y: height * 0.35))
        
        path.addCurve(
            to: CGPoint(x: (width + neckWidth) / 2, y: height * 0.25),
            control1: CGPoint(x: (width + bodyWidth) / 2 - 4, y: height * 0.35 - 8),
            control2: CGPoint(x: (width + neckWidth) / 2 + 4, y: height * 0.25 + 8)
        )
        
        path.addLine(to: CGPoint(x: (width + neckWidth) / 2, y: 20))
        
        path.addCurve(
            to: CGPoint(x: (width - neckWidth) / 2, y: 20),
            control1: CGPoint(x: (width + neckWidth) / 2 - 2, y: 16),
            control2: CGPoint(x: (width - neckWidth) / 2 + 2, y: 16)
        )
        
        path.addLine(to: CGPoint(x: (width - neckWidth) / 2, y: height * 0.25))
        
        path.addCurve(
            to: CGPoint(x: (width - bodyWidth) / 2, y: height * 0.35),
            control1: CGPoint(x: (width - neckWidth) / 2 - 4, y: height * 0.25 + 8),
            control2: CGPoint(x: (width - bodyWidth) / 2 + 4, y: height * 0.35 - 8)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Reassurance Bubble
struct ReassuranceBubble: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, AppSpacing.lg)
        }
        .frame(height: 180)
    }
}

// MARK: - Supporting Views
struct PeriodSelector: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach([TimePeriod.today, .last7Days], id: \.self) { period in
                Button {
                    withAnimation(MotionCurve.interaction) {
                        selectedPeriod = period
                    }
                } label: {
                    if selectedPeriod == period {
                        Text(period == .today ? "Today" : "7 Days")
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .tagActive()
                    } else {
                        Text(period == .today ? "Today" : "7 Days")
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(Color.inkPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .tagInactive()
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct GuidanceBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(AppFont.body)
            .foregroundStyle(Color.almostAquaDark.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.almostAquaDark.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct StatsGrid: View {
    @Environment(FeedStore.self) private var feedStore
    
    var body: some View {
        let stats = feedStore.getStatistics(for: Date())
        
        HStack(spacing: 12) {
            StatBox(
                icon: "number",
                value: "\(stats.totalFeeds)",
                label: "Feeds",
                sublabel: "today",
                tint: Color.peachDustDark
            )
            StatBox(
                icon: "drop.fill",
                value: "\(Int(stats.totalAmount))",
                label: "Total",
                sublabel: "ml",
                tint: Color.almostAquaDark
            )
            StatBox(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(Int(stats.averageAmount))",
                label: "Average",
                sublabel: "per feed",
                tint: Color.orchidTintDark
            )
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let sublabel: String
    let tint: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(AppFont.sans(16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            Text(value)
                .font(AppFont.serif(20))
                .foregroundStyle(Color.inkPrimary)
            
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(Color.inkSecondary)
            
            Text(sublabel)
                .font(AppFont.caption)
                .foregroundStyle(tint.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

struct InsightsSection: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var insights: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(AppFont.sectionTitle)
                .foregroundStyle(Color.inkSecondary)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(insights.prefix(2), id: \.self) { insight in
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle")
                            .font(AppFont.sans(11, weight: .regular))
                            .foregroundStyle(Color.almostAquaDark)
                        Text(insight)
                            .font(AppFont.body)
                            .foregroundStyle(Color.inkSecondary)
                        Spacer()
                    }
                }
            }
            .cardStyle()
        }
        .onAppear { insights = feedStore.getInsights() }
    }
}

struct RecentFeedsSection: View {
    @Query(sort: \Feed.startTime, order: .reverse) private var recentFeeds: [Feed]
    
    private var lastTwoFeeds: [Feed] {
        Array(recentFeeds.prefix(2))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(AppFont.sectionTitle)
                    .foregroundStyle(Color.inkSecondary)
                Spacer()
                NavigationLink(destination: FeedHistoryView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                            .font(AppFont.caption)
                    }
                    .foregroundStyle(Color.almostAquaDark)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(lastTwoFeeds) { feed in
                    FeedRow(feed: feed)
                }
            }
        }
    }
}

struct FeedRow: View {
    let feed: Feed
    
    var body: some View {
        HStack(spacing: 12) {
            Text(feed.startTime, style: .time)
                .font(AppFont.bodyLarge)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 58, alignment: .leading)
            
            Circle()
                .fill(feed.completed ? Color.almostAquaDark : Color.peachDustDark.opacity(0.6))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feed.formattedAmount)
                    .font(AppFont.body)
                
                if !feed.completed {
                    Text("Left some")
                        .font(AppFont.caption)
                        .foregroundStyle(Color.peachDustDark.opacity(0.9))
                }
            }
            
            Spacer()
        }
        .cardStyle()
    }
}

// MARK: - Formula Info Card
struct FormulaInfoCard: View {
    let profile: BabyProfile
    @State private var showingGuide = false
    
    private var displayBrand: String {
        profile.customFormulaBrand ?? profile.formulaBrand ?? "Formula"
    }
    
    private var displayStage: String? {
        profile.formulaStage?.displayName
    }
    
    private var displayProduct: String? {
        profile.customFormulaProduct
    }
    
    var body: some View {
        Button {
            showingGuide = true
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "drop.fill")
                    .font(AppFont.sans(14, weight: .medium))
                    .foregroundStyle(Color.almostAquaDark)
                    .frame(width: 32, height: 32)
                    .background(Color.almostAquaDark.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayBrand)
                        .font(AppFont.body)
                        .foregroundStyle(Color.inkPrimary)
                    
                    if let stage = displayStage {
                        Text(stage)
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary)
                    } else if let product = displayProduct {
                        Text(product)
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary.opacity(0.5))
            }
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Formula: \(displayBrand)")
        .sheet(isPresented: $showingGuide) {
            FormulaGuideSheet(profile: profile)
        }
    }
}

// MARK: - Formula Guide Sheet
struct FormulaGuideSheet: View {
    let profile: BabyProfile
    @Environment(\.dismiss) private var dismiss
    
    private var guidance: FormulaGuidanceResult {
        FormulaGuidanceService.guidance(for: profile)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // Brand summary
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(AppFont.sans(14))
                                .foregroundStyle(Color.almostAquaDark)
                            
                            Text(profile.customFormulaBrand ?? profile.formulaBrand ?? "Formula")
                                .font(AppFont.sans(15, weight: .semibold))
                                .foregroundStyle(Color.inkPrimary)
                            
                            Spacer()
                        }
                        
                        if let stage = profile.formulaStage {
                            Text(stage.displayName)
                                .font(AppFont.caption)
                                .foregroundStyle(Color.almostAquaDark)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, 4)
                                .background(Color.almostAquaLight)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Guidance cards
                    HStack(spacing: AppSpacing.md) {
                        GentleGuideCard(
                            title: "Estimated daily",
                            value: "\(guidance.suggestedDailyMin)–\(guidance.suggestedDailyMax) ml",
                            subtitle: guidance.weightBased ? "Based on weight" : "Based on age",
                            tint: Color.almostAquaDark
                        )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    HStack(spacing: AppSpacing.md) {
                        GentleGuideCard(
                            title: "Typical feed size",
                            value: "\(guidance.estimatedFeedSizeMin)–\(guidance.estimatedFeedSizeMax) ml",
                            subtitle: "Per feed",
                            tint: Color.peachDustDark
                        )
                        
                        GentleGuideCard(
                            title: "Feeds per day",
                            value: "\(guidance.estimatedFeedsPerDay.lowerBound)–\(guidance.estimatedFeedsPerDay.upperBound)",
                            subtitle: "Times",
                            tint: Color.orchidTintDark
                        )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Stage guidance
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Usually suited to this age")
                            .font(AppFont.sans(12, weight: .semibold))
                            .foregroundStyle(Color.inkSecondary)
                            .padding(.horizontal, AppSpacing.sm)
                        
                        Text(guidance.applicableStageLabel)
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(Color.inkPrimary)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.backgroundCard)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                    .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                            )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Explanation
                    Text(guidance.explanationText)
                        .font(AppFont.body)
                        .foregroundStyle(Color.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    // Disclaimer
                    FormulaDisclaimerView()
                        .padding(.horizontal, AppSpacing.lg)
                    
                    if !guidance.weightBased {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "scalemass")
                                .font(AppFont.sans(12))
                                .foregroundStyle(Color.almostAquaDark)
                            
                            Text("Add your baby's weight in Settings for a more tailored estimate.")
                                .font(AppFont.sans(11))
                                .foregroundStyle(Color.almostAquaDark)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(AppSpacing.md)
                        .background(Color.almostAquaLight.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(Color.backgroundBase)
            .navigationTitle("Feeding Guide")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Prep Guide Link
struct PrepGuideLink: View {
    @State private var showingPrepGuide = false
    
    var body: some View {
        Button {
            showingPrepGuide = true
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "drop.fill")
                    .font(AppFont.sans(14, weight: .medium))
                    .foregroundStyle(Color.almostAquaDark)
                    .frame(width: 32, height: 32)
                    .background(Color.almostAquaDark.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bottle Prep Guide")
                        .font(AppFont.body)
                        .foregroundStyle(Color.inkPrimary)
                    Text("Step-by-step safety guide")
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary.opacity(0.5))
            }
            .padding(AppSpacing.md)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open bottle preparation guide")
        .sheet(isPresented: $showingPrepGuide) {
            BottlePrepGuideView()
        }
    }
}

// MARK: - Tips Section
struct TipsSection: View {
    @Environment(FeedStore.self) private var feedStore
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    @State private var dismissedIds: Set<String> = []
    
    private var tips: [Tip] {
        let allTips = TipEngine.tips(for: feedStore.babyProfile, feeds: feeds)
        return allTips.filter { !dismissedIds.contains($0.id) && !DismissedTipStore.isDismissed($0.id) }
    }
    
    var body: some View {
        if !tips.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("A gentle note")
                    .font(AppFont.sectionTitle)
                    .foregroundStyle(Color.inkSecondary)
                
                VStack(spacing: AppSpacing.md) {
                    ForEach(tips) { tip in
                        TipBubble(tip: tip) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                DismissedTipStore.dismiss(tip.id)
                                dismissedIds.insert(tip.id)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Tip Bubble
struct TipBubble: View {
    let tip: Tip
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: iconName)
                .font(AppFont.sans(14, weight: .medium))
                .foregroundStyle(tintColor)
                .frame(width: 32, height: 32)
                .background(tintColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.text)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(AppFont.sans(12, weight: .medium))
                    .foregroundStyle(Color.inkSecondary.opacity(0.5))
                    .frame(width: 28, height: 28)
            }
            .accessibilityLabel("Dismiss tip")
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(tintColor.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch tip.category {
        case .reassurance: return "heart.fill"
        case .practical: return "lightbulb.fill"
        case .night: return "moon.fill"
        case .formula: return "drop.fill"
        case .newborn: return "sparkles"
        }
    }
    
    private var tintColor: Color {
        switch tip.category {
        case .reassurance: return Color.peachDustDark
        case .practical: return Color.almostAquaDark
        case .night: return Color.orchidTintDark
        case .formula: return Color.almostAquaDark
        case .newborn: return Color.peachDustDark
        }
    }
}

#Preview {
    DashboardView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}


// MARK: - Insights Placeholder
struct InsightsView: View {
    @Environment(FeedStore.self) private var feedStore
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Insights")
                        .font(AppFont.heroTitle)
                        .foregroundStyle(Color.inkPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Coming soon")
                        .font(AppFont.bodyLarge)
                        .foregroundStyle(Color.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 60)
            }
            .background(Color.backgroundBase)
            .navigationTitle("Insights")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

