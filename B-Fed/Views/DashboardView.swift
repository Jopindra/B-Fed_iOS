import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var showingLogFeed = false
    @State private var selectedPeriod: TimePeriod = .today
    
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    private var hasFeeds: Bool {
        !allFeeds.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if hasFeeds {
                    PopulatedDashboardView(
                        selectedPeriod: $selectedPeriod,
                        showingLogFeed: $showingLogFeed
                    )
                } else {
                    FirstTimeDashboardView(showingLogFeed: $showingLogFeed)
                }
            }
            .navigationTitle("Today")
            
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(isPresented: $showingLogFeed) {
                LogFeedView()
            }
        }
    }
}

// MARK: - First Time Dashboard (Empty State)
struct FirstTimeDashboardView: View {
    @Binding var showingLogFeed: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(Color.backgroundBase)
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
        ScrollView(showsIndicators: false) {
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
                
                RecentFeedsSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.backgroundBase)
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
                .frame(width: 50)
            
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

#Preview {
    DashboardView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
