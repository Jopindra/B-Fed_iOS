import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(SelectedFormulaStore.self) private var formulaStore
    @State private var showingLogFeed = false
    @State private var showingFormulaDetail = false
    @State private var selectedPeriod: TimePeriod = .today
    var onSwitchToHistoryTab: () -> Void = {}
    
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    // MARK: — Data
    
    private var hasFeeds: Bool {
        !allFeeds.isEmpty
    }
    
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
    
    // MARK: — Header
    
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
        if mins < 60 {
            return "\(babyName) · \(mins)min ago"
        } else {
            let h = mins / 60
            let m = mins % 60
            if m == 0 {
                return "\(babyName) · \(h)h ago"
            }
            return "\(babyName) · \(h)h \(m)min ago"
        }
    }
    
    // MARK: — Reassurance
    
    var reassuranceHeadline: String {
        guard let mins = lastFeedMinutesAgo else {
            return "Take your time"
        }
        switch mins {
        case 0..<20:
            return "Just finished"
        case 20..<90:
            return "Feeding well today"
        case 90..<180:
            return "A quiet spell"
        default:
            return "Take your time"
        }
    }
    
    var reassuranceSubtext: String {
        guard let mins = lastFeedMinutesAgo else {
            return "Log when you're ready"
        }
        if mins < 180 {
            return lastFeedFormulaAndAmount
        }
        return "Log when you're ready"
    }
    
    var lastFeedFormulaAndAmount: String {
        guard let last = todayFeeds.first else { return "" }
        let amount = Int(last.amount)
        if let brand = feedStore.babyProfile?.customFormulaBrand ?? feedStore.babyProfile?.formulaBrand {
            let stage = feedStore.babyProfile?.formulaStage?.displayName ?? ""
            if stage.isEmpty {
                return "\(brand) · \(amount)ml"
            }
            return "\(brand) \(stage) · \(amount)ml"
        }
        return "\(amount)ml last feed"
    }
    
    // MARK: — Bottle Timer
    
    private var bottleTimerActive: Bool {
        feedStore.isTimerRunning
    }
    
    private var bottleTimerRemainingMinutes: Int {
        let freshnessWindow: TimeInterval = 2 * 3600
        let remaining = freshnessWindow - feedStore.timerElapsed
        return max(0, Int(remaining / 60))
    }
    
    private var bottleTimerIsExpired: Bool {
        bottleTimerRemainingMinutes <= 0 && feedStore.isTimerRunning
    }
    
    private var bottleTimerIsUrgent: Bool {
        bottleTimerRemainingMinutes < 30 && bottleTimerRemainingMinutes > 0 && feedStore.isTimerRunning
    }
    
    private var bottleTimerSubtext: String {
        if bottleTimerIsExpired {
            return "Discard this bottle"
        }
        let useByDate = Date().addingTimeInterval(TimeInterval(bottleTimerRemainingMinutes * 60))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        let timeStr = formatter.string(from: useByDate).lowercased()
        return "Use by \(timeStr) · \(bottleTimerRemainingMinutes)min remaining"
    }
    
    private var bottleTimerShortDisplay: String {
        if bottleTimerRemainingMinutes >= 60 {
            let h = bottleTimerRemainingMinutes / 60
            let m = bottleTimerRemainingMinutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(bottleTimerRemainingMinutes)m"
    }
    
    // MARK: — Fill level for bottle illustration
    
    private var bottleFillLevel: Double {
        guard let weight = feedStore.babyProfile?.currentWeight, weight > 0 else { return 0 }
        let weightKg = Double(weight) / 1000.0
        let recommended = weightKg * 150
        guard recommended > 0 else { return 0 }
        return min(Double(totalMlToday) / recommended, 1.0)
    }
    
    // MARK: — Formula helper
    
    private var currentFormulaForHelper: Formula? {
        if let selected = formulaStore.selectedFormula { return selected }
        guard let profile = feedStore.babyProfile,
              let brand = profile.customFormulaBrand ?? profile.formulaBrand else { return nil }
        return FormulaService.allFormulas.first {
            $0.brand == brand || $0.displayName.contains(brand)
        }
    }
    
    // MARK: — Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1 — full bleed background
                Color(hex: "FAFAF8")
                    .ignoresSafeArea(.all)
                
                // Layer 2 — background blobs
                ZStack {
                    Ellipse()
                        .fill(Color(hex: "E8C4B0").opacity(0.55))
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.width * 0.97
                        )
                        .position(
                            x: geometry.size.width,
                            y: 0
                        )
                    Ellipse()
                        .fill(Color(hex: "EEE8C8").opacity(0.6))
                        .frame(
                            width: geometry.size.width * 0.55,
                            height: geometry.size.width * 0.55
                        )
                        .position(
                            x: geometry.size.width,
                            y: 0
                        )
                    Ellipse()
                        .fill(Color(hex: "DDE9DE").opacity(0.5))
                        .frame(
                            width: geometry.size.width * 0.86,
                            height: geometry.size.width * 0.86
                        )
                        .position(x: 0, y: geometry.size.height)
                    Ellipse()
                        .fill(Color(hex: "EEE8C8").opacity(0.38))
                        .frame(
                            width: geometry.size.width * 0.55,
                            height: geometry.size.width * 0.55
                        )
                        .position(
                            x: geometry.size.width,
                            y: geometry.size.height
                        )
                }
                .allowsHitTesting(false)
                .ignoresSafeArea(.all)
                
                // Layer 3 — content
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    summaryPill
                    Spacer().frame(height: 20)
                    if todayFeeds.isEmpty {
                        emptyStateView
                    } else {
                        last4HoursLabel
                        feedBubbleArc(geometry: geometry)
                        reassuranceSection
                        if bottleTimerActive {
                            bottleTimerCard
                        }
                    }
                    Spacer()
                    logFeedButton
                }
                .padding(.top, geometry.safeAreaInsets.top + 20)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showingLogFeed) {
            LogFeedSheet()
        }
        .sheet(isPresented: $showingFormulaDetail) {
            if let formula = currentFormulaForHelper {
                FormulaDetailView(formula: formula, volumeMl: Double(totalMlToday) / max(1, Double(todayFeeds.count)))
            }
        }
    }
    
    // MARK: — Header Section
    
    private var headerSection: some View {
        Text(headerText)
            .font(.custom("DMSerifDisplay-Regular", size: 24))
            .foregroundColor(Color(hex: "2E2929"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Summary Pill
    
    private var summaryPill: some View {
        HStack(spacing: 4) {
            if todayFeeds.isEmpty {
                Text("No feeds yet today")
                    .font(.custom("DMSans-Regular", size: 11))
                    .foregroundColor(Color(hex: "5A5555"))
            } else {
                Text("\(todayFeeds.count) feeds")
                    .font(.custom("DMSans-SemiBold", size: 11))
                    .foregroundColor(Color(hex: "2E2929"))
                Text("·")
                    .foregroundColor(Color(hex: "5A5555"))
                Text("\(totalMlToday)ml")
                    .font(.custom("DMSans-SemiBold", size: 11))
                    .foregroundColor(Color(hex: "2E2929"))
                Text("today")
                    .font(.custom("DMSans-Regular", size: 11))
                    .foregroundColor(Color(hex: "5A5555"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(
                Color.black.opacity(0.07),
                lineWidth: 0.5
            )
        )
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 12)
    }
    
    // MARK: — Last 4 Hours Label
    
    private var last4HoursLabel: some View {
        HStack {
            Text("LAST 4 HOURS")
                .font(.custom("DMSans-SemiBold", size: 9))
                .foregroundColor(Color(hex: "5A5555"))
                .tracking(0.4)
            Spacer()
            Button("see all") {
                onSwitchToHistoryTab()
            }
            .font(.custom("DMSans-Regular", size: 9))
            .foregroundColor(Color(hex: "8A7E96"))
        }
        .padding(.bottom, 8)
    }
    
    // MARK: — Feed Bubble Arc
    
    private func feedBubbleArc(geometry: GeometryProxy) -> some View {
        let recentFeeds = Array(feedsInLastFourHours.prefix(3))
        let slots: [Double] = [213, 270, 327]
        
        return ZStack {
            Canvas { context, size in
                let centreX = size.width / 2
                let centreY = size.height * 0.68
                let radius = size.width * 0.40
                
                // Arc track
                var arcPath = Path()
                arcPath.addArc(
                    center: CGPoint(x: centreX, y: centreY),
                    radius: radius,
                    startAngle: .degrees(200),
                    endAngle: .degrees(340),
                    clockwise: false
                )
                context.stroke(
                    arcPath,
                    with: .color(.black.opacity(0.08)),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                
                // Bubbles and ghosts
                for slotIndex in 0..<slots.count {
                    let angle = slots[slotIndex] * .pi / 180
                    let x = centreX + radius * CGFloat(cos(angle))
                    let y = centreY + radius * CGFloat(sin(angle))
                    
                    if let feed = feedForSlot(slotIndex: slotIndex, feeds: recentFeeds) {
                        let r = bubbleRadius(for: Int(feed.amount))
                        let rank = recencyRank(for: slotIndex, totalCount: recentFeeds.count)
                        let color = bubbleColor(for: rank)
                        let opacity = (slotIndex == recentFeeds.count - 1 && recentFeeds.count > 1) ? 0.9 : 0.85
                        let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(color.opacity(opacity))
                        )
                    } else if recentFeeds.count < 3 {
                        let r: CGFloat = 20
                        let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                        context.stroke(
                            Path(ellipseIn: rect),
                            with: .color(.black.opacity(0.07)),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 4])
                        )
                    }
                }
            }
            .frame(height: 240)
            
            // Text overlays
            GeometryReader { geo in
                let centreX = geo.size.width / 2
                let centreY = geo.size.height * 0.68
                let radius = geo.size.width * 0.40
                
                ForEach(Array(recentFeeds.enumerated()), id: \.element.id) { feedIndex, feed in
                    let slotIndex = slotIndexForFeed(feedIndex: feedIndex, totalCount: recentFeeds.count)
                    let angle = slots[slotIndex] * .pi / 180
                    let x = centreX + radius * CGFloat(cos(angle))
                    let y = centreY + radius * CGFloat(sin(angle))
                    let rank = recencyRank(for: slotIndex, totalCount: recentFeeds.count)
                    let r = bubbleRadius(for: Int(feed.amount))
                    let fontSize = max(9, r / 1.8)
                    
                    VStack(spacing: 1) {
                        Text("\(Int(feed.amount))")
                            .font(rank == 0 ? .custom("DMSerifDisplay-Regular", size: fontSize) : .custom("DMSans-SemiBold", size: fontSize))
                            .foregroundColor(textColorForRank(rank))
                        Text("ml")
                            .font(.custom("DMSans-Regular", size: max(7, fontSize * 0.55)))
                            .foregroundColor(textColorForRank(rank))
                    }
                    .position(x: x, y: y)
                }
                
                // Time labels below bubbles
                ForEach(Array(recentFeeds.enumerated()), id: \.element.id) { feedIndex, feed in
                    let slotIndex = slotIndexForFeed(feedIndex: feedIndex, totalCount: recentFeeds.count)
                    let angle = slots[slotIndex] * .pi / 180
                    let x = centreX + radius * CGFloat(cos(angle))
                    let y = centreY + radius * CGFloat(sin(angle)) + 36
                    
                    Text(timeString(for: feed.startTime))
                        .font(.custom("DMSans-Regular", size: 7))
                        .foregroundColor(Color(hex: "8A7E96"))
                        .position(x: x, y: y)
                }
            }
            .frame(height: 240)
            .allowsHitTesting(false)
        }
    }
    
    // MARK: — Reassurance Section
    
    private var reassuranceSection: some View {
        VStack(spacing: 6) {
            Text(reassuranceHeadline)
                .font(.custom("DMSerifDisplay-Regular", size: 15))
                .foregroundColor(Color(hex: "2E2929"))
            Text(reassuranceSubtext)
                .font(.custom("DMSans-Regular", size: 12))
                .foregroundColor(Color(hex: "5A5555"))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
    }
    
    // MARK: — Bottle Timer Card
    
    private var bottleTimerCard: some View {
        let bgColor = bottleTimerIsUrgent ? Color(hex: "E4DFE9") : Color(hex: "F5E6DE")
        let strokeColor = bottleTimerIsUrgent ? Color(hex: "C4BCCD") : Color(hex: "E8C4B0")
        let accentColor = bottleTimerIsUrgent ? Color(hex: "8A7E96") : Color(hex: "C49070")
        
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("BOTTLE TIMER")
                    .font(.custom("DMSans-SemiBold", size: 9))
                    .foregroundColor(accentColor)
                    .tracking(0.3)
                Text(bottleTimerSubtext)
                    .font(.custom("DMSans-Regular", size: 11))
                    .foregroundColor(Color(hex: "5A5555"))
            }
            Spacer()
            Text(bottleTimerShortDisplay)
                .font(.custom("DMSerifDisplay-Regular", size: 18))
                .foregroundColor(accentColor)
            
            Button(action: {
                feedStore.resetFeedTimer()
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: ["bottle-timer-notification"])
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "5A5555").opacity(0.6))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .background(bgColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(strokeColor, lineWidth: 0.5)
        )
        .padding(.top, 12)
    }
    
    // MARK: — Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
            BabyBottleView(fillLevel: bottleFillLevel)
                .frame(width: 60, height: 130)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer().frame(height: 20)
            Text("Log your first feed")
                .font(.custom("DMSans-Regular", size: 12))
                .foregroundColor(Color(hex: "5A5555"))
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }
    
    // MARK: — Log Feed Button
    
    private var logFeedButton: some View {
        Button(action: { showingLogFeed = true }) {
            HStack {
                Text("+")
                    .font(.custom("DMSans-SemiBold", size: 18))
                    .foregroundColor(Color(hex: "E8C4B0"))
                Text("Log a feed")
                    .font(.custom("DMSans-SemiBold", size: 16))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "2E2929"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: — Bubble Helpers
    
    private func feedForSlot(slotIndex: Int, feeds: [Feed]) -> Feed? {
        let count = feeds.count
        guard count > 0 else { return nil }
        switch count {
        case 1:
            return slotIndex == 1 ? feeds[0] : nil
        case 2:
            if slotIndex == 0 { return feeds[1] }
            if slotIndex == 2 { return feeds[0] }
            return nil
        case 3:
            if slotIndex == 0 { return feeds[2] }
            if slotIndex == 1 { return feeds[1] }
            if slotIndex == 2 { return feeds[0] }
            return nil
        default:
            return nil
        }
    }
    
    private func slotIndexForFeed(feedIndex: Int, totalCount: Int) -> Int {
        switch totalCount {
        case 1: return 1
        case 2: return feedIndex == 0 ? 2 : 0
        case 3: return 2 - feedIndex
        default: return 0
        }
    }
    
    private func recencyRank(for slotIndex: Int, totalCount: Int) -> Int {
        switch totalCount {
        case 1: return 0
        case 2:
            if slotIndex == 0 { return 1 }
            if slotIndex == 2 { return 0 }
            return 0
        case 3: return 2 - slotIndex
        default: return 0
        }
    }
    
    private func bubbleRadius(for ml: Int) -> CGFloat {
        switch ml {
        case ..<60:    return 18
        case 60..<100: return 20
        case 100..<140: return 23
        case 140..<180: return 26
        default:       return 29
        }
    }
    
    private func bubbleColor(for rank: Int) -> Color {
        // rank 0 = most recent, 1 = middle, 2 = oldest
        let colors = [
            Color(hex: "C49070"),   // most recent
            Color(hex: "E8C4B0"),   // middle
            Color(hex: "F5E6DE")    // oldest
        ]
        guard rank >= 0 && rank < colors.count else { return colors[0] }
        return colors[rank]
    }
    
    private func textColorForRank(_ rank: Int) -> Color {
        rank == 0 ? .white : Color(hex: "2E2929")
    }
    
    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: date).lowercased()
    }
}

// MARK: - Bottle Glass Shape (used by LogFeedView)
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

// MARK: - Liquid with Wave (used by LogFeedView)
struct LiquidWithWave: View {
    let fillLevel: CGFloat
    let phase: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.almostAquaDark)
                    .frame(height: geometry.size.height * fillLevel)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                DashboardWaveShape(fillLevel: fillLevel, phase: phase)
                    .fill(Color.almostAqua.opacity(0.9))
                    .frame(height: geometry.size.height)
            }
        }
    }
}

// MARK: - Wave Shape (used by LogFeedView)
struct DashboardWaveShape: Shape {
    let fillLevel: CGFloat
    let phase: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterLevel = rect.height * (1 - fillLevel)
        let width = rect.width
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
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

// MARK: - Insights View (used by ContentView)
struct InsightsView: View {
    @Environment(FeedStore.self) private var feedStore
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Insights")
                        .font(.custom("DMSerifDisplay-Regular", size: 28))
                        .foregroundColor(Color(hex: "2E2929"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Coming soon")
                        .font(.custom("DMSans-Regular", size: 15))
                        .foregroundColor(Color(hex: "5A5555"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 60)
            }
            .background(Color(hex: "FAFAF8"))
            .navigationTitle("Insights")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

#Preview {
    DashboardView()
        .environment(FeedStore())
        .environment(SelectedFormulaStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
