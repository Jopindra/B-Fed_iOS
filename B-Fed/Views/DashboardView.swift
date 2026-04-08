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
            .navigationBarTitleDisplayMode(.large)
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
                Spacer().frame(height: 40)
                
                // Empty bottle (outline only)
                EmptyBottleView()
                    .frame(width: 120, height: 180)
                
                Spacer().frame(height: 48)
                
                // Primary message
                Text("Let's log your first feed")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Spacer().frame(height: 8)
                
                // Secondary reassurance
                Text("You're doing great already")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Spacer().frame(height: 32)
                
                // Log Feed Button
                Button(action: { showingLogFeed = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Log Feed")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.emerald)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.emerald.opacity(0.25), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Empty Bottle View (Outline only)
struct EmptyBottleView: View {
    var body: some View {
        ZStack {
            // Soft glow background
            RadialGradient(
                colors: [Color.emerald.opacity(0.05), Color.clear],
                center: .center,
                startRadius: 10,
                endRadius: 100
            )
            
            // Bottle outline
            BottleOutlineShape()
                .stroke(
                    Color.emerald.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
            
            // Subtle teat
            Ellipse()
                .fill(Color.emerald.opacity(0.2))
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
            .padding(.bottom, 100)
        }
        .background(Color(.systemGroupedBackground))
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
        .onChange(of: targetFillLevel) { newLevel in
            // Animate when level changes (new feed logged)
            if newLevel > bottleFillLevel {
                animateBottleFill(to: newLevel)
            }
        }
    }
    
    private func triggerFirstFeedExperience() {
        // Small delay to let view settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Animate bottle filling
            withAnimation(.easeOut(duration: 0.4)) {
                bottleFillLevel = targetFillLevel * 1.1 // Overshoot slightly
            }
            
            // Settle back
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    bottleFillLevel = targetFillLevel
                }
            }
            
            // Show reassurance message
            reassuranceMessage = ReassuranceEngine.postFeedEncouragement()
            
            withAnimation(.easeIn(duration: 0.4)) {
                showReassurance = true
            }
            
            // Fade out after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showReassurance = false
                }
            }
            
            // Animate stats appearing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animateStats = true
                }
            }
        }
    }
    
    private func animateBottleFill(to newLevel: CGFloat) {
        withAnimation(.easeOut(duration: 0.4)) {
            bottleFillLevel = newLevel * 1.08 // Subtle overshoot
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                bottleFillLevel = newLevel
            }
        }
        
        // Show reassurance
        reassuranceMessage = ReassuranceEngine.postFeedEncouragement()
        withAnimation(.easeIn(duration: 0.3)) {
            showReassurance = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
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
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
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
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Liquid with wave
            LiquidWithWave(fillLevel: fillLevel, phase: wavePhase)
                .clipShape(BottleGlassShape())
            
            // Glass highlights
            BottleGlassShape()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
        }
        .onAppear {
            // Continuous wave animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
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
                    .fill(
                        LinearGradient(
                            colors: [Color.emeraldLight, Color.emerald, Color.emeraldDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * fillLevel)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
                // Wave surface
                WaveShape(fillLevel: fillLevel, phase: phase)
                    .fill(Color.emeraldLight.opacity(0.9))
                    .frame(height: geometry.size.height)
            }
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
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
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 20)
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
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period == .today ? "Today" : "7 Days")
                        .font(.subheadline.weight(selectedPeriod == period ? .semibold : .medium))
                        .foregroundStyle(selectedPeriod == period ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(selectedPeriod == period ? Color.emerald : Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.emerald.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.emerald.opacity(0.1))
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
                tint: .blue
            )
            StatBox(
                icon: "drop.fill",
                value: "\(Int(stats.totalAmount))",
                label: "Total",
                sublabel: "ml",
                tint: Color.emerald
            )
            StatBox(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(Int(stats.averageAmount))",
                label: "Average",
                sublabel: "per feed",
                tint: .orange
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(sublabel)
                .font(.caption2)
                .foregroundStyle(tint.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(tint.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct InsightsSection: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var insights: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(insights.prefix(2), id: \.self) { insight in
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.emerald)
                        Text(insight)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                NavigationLink(destination: FeedHistoryView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.emerald)
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
                .font(.subheadline.weight(.semibold))
                .frame(width: 50)
            
            Circle()
                .fill(Color.emerald)
                .frame(width: 8, height: 8)
            
            Text(feed.formattedAmount)
                .font(.subheadline.weight(.medium))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

enum TimePeriod {
    case today, last7Days
}

// MARK: - Colors
private extension Color {
    static var emerald: Color {
        Color(red: 0.18, green: 0.44, blue: 0.37)
    }
    static var emeraldLight: Color {
        Color(red: 0.30, green: 0.55, blue: 0.48)
    }
    static var emeraldDeep: Color {
        Color(red: 0.10, green: 0.30, blue: 0.25)
    }
}

#Preview {
    DashboardView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
