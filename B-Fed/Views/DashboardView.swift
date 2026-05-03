import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(SelectedFormulaStore.self) private var formulaStore
    @State private var showingLogFeed = false
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
    
    private var babyName: String {
        feedStore.babyProfile?.babyName ?? "Baby"
    }
    
    private var parentName: String {
        feedStore.babyProfile?.parentName ?? "there"
    }
    
    private var ageInMonths: Int? {
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return nil }
        return FormulaStageService.ageInMonths(from: dob)
    }
    
    private var guidance: DashboardGuidance? {
        guard let months = ageInMonths else { return nil }
        switch months {
        case 0..<1:
            return DashboardGuidance(dailyMin: 450, dailyMax: 600, feedMin: 60, feedMax: 90, feedsPerDayMin: 8, feedsPerDayMax: 12)
        case 1..<2:
            return DashboardGuidance(dailyMin: 500, dailyMax: 700, feedMin: 90, feedMax: 120, feedsPerDayMin: 6, feedsPerDayMax: 8)
        case 2..<4:
            return DashboardGuidance(dailyMin: 700, dailyMax: 900, feedMin: 120, feedMax: 180, feedsPerDayMin: 5, feedsPerDayMax: 6)
        case 4..<6:
            return DashboardGuidance(dailyMin: 800, dailyMax: 1000, feedMin: 150, feedMax: 210, feedsPerDayMin: 4, feedsPerDayMax: 6)
        case 6..<9:
            return DashboardGuidance(dailyMin: 600, dailyMax: 900, feedMin: 180, feedMax: 240, feedsPerDayMin: 3, feedsPerDayMax: 5)
        case 9..<12:
            return DashboardGuidance(dailyMin: 500, dailyMax: 800, feedMin: 180, feedMax: 240, feedsPerDayMin: 3, feedsPerDayMax: 4)
        case 12..<24:
            return DashboardGuidance(dailyMin: 350, dailyMax: 500, feedMin: 150, feedMax: 200, feedsPerDayMin: 2, feedsPerDayMax: 3)
        default:
            return DashboardGuidance(dailyMin: 300, dailyMax: 400, feedMin: 120, feedMax: 180, feedsPerDayMin: 2, feedsPerDayMax: 3)
        }
    }
    
    private var recommendedDailyMl: Int? {
        if let weightKg = feedStore.babyProfile?.weightInKg, weightKg > 0 {
            return Int(weightKg * 150)
        }
        return guidance?.dailyMax
    }
    
    private var recommendedFeedsPerDay: Int? {
        guard let g = guidance else { return nil }
        return Int(ceil(Double(g.feedsPerDayMin + g.feedsPerDayMax) / 2.0))
    }
    
    private var ringProgress: Double {
        guard let target = recommendedDailyMl, target > 0 else { return 0 }
        return min(Double(totalMlToday) / Double(target), 1.0)
    }
    
    private var avgPerFeedDisplay: String {
        guard !todayFeeds.isEmpty else { return "—" }
        let totalConsumed = todayFeeds.reduce(0) { $0 + Int($1.consumedMl ?? Int($1.amount)) }
        let avg = Double(totalConsumed) / Double(todayFeeds.count)
        return "\(Int(round(avg))) ml"
    }
    
    private var isEmptyState: Bool {
        todayFeeds.isEmpty
    }
    
    // MARK: — Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "F7F6F2").ignoresSafeArea()
                
                blobs(in: geometry)
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            headerSection
                            
                            progressRing
                                .padding(.top, 32)
                            
                            statCards
                                .padding(.top, 32)
                            
                            weekTracker
                                .padding(.top, 14)
                            
                            reassuranceLine
                                .padding(.top, 14)
                            
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                    }
                    
                    logFeedButton
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 64)
                }
            }
        }
        .sheet(isPresented: $showingLogFeed) {
            LogFeedSheet()
        }
    }
    
    // MARK: — Blobs
    
    private func blobs(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Blob 1 — Lavender, top right
            Circle()
                .fill(Color(hex: "C8C0D4").opacity(0.45))
                .frame(width: 180, height: 180)
                .position(x: geometry.size.width + 30, y: 30)
            
            // Blob 2 — Cream, top left
            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.35))
                .frame(width: 150, height: 150)
                .position(x: -25, y: 25)
            
            // Blob 3 — Terracotta, mid left
            Circle()
                .fill(Color(hex: "D4A898").opacity(0.32))
                .frame(width: 140, height: 140)
                .position(x: -10, y: 270)
            
            // Blob 4 — Sage, mid right
            Circle()
                .fill(Color(hex: "B0C4B0").opacity(0.32))
                .frame(width: 120, height: 120)
                .position(x: geometry.size.width + 10, y: 320)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEmptyState {
                Text("Good morning, \(parentName).")
                    .font(AppFont.sans(20, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                
                Text("\(babyName) hasn't fed yet today")
                    .font(AppFont.sans(13))
                    .foregroundColor(Color(hex: "888780"))
            } else {
                Text("Just finished.")
                    .font(AppFont.sans(20, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                
                if let mins = lastFeedMinutesAgo {
                    Text("\(babyName) · \(timeAgoString(minutes: mins))")
                        .font(AppFont.sans(13))
                        .foregroundColor(Color(hex: "888780"))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func timeAgoString(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min ago"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            if m == 0 { return "\(h)h ago" }
            return "\(h)h \(m)min ago"
        }
    }
    
    // MARK: — Progress Ring
    
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "C8C0D4"), lineWidth: 8)
                .frame(width: 140, height: 140)
            
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Color(hex: "7B6A9A"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                Text("\(totalMlToday)")
                    .font(AppFont.sans(28, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                
                Text("of \(recommendedDailyMl.map { "\($0)" } ?? "—") ml")
                    .font(AppFont.sans(11))
                    .foregroundColor(Color(hex: "888780"))
            }
            .background(
                Circle()
                    .fill(Color(hex: "F0EDF5"))
                    .frame(width: 120, height: 120)
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: — Stat Cards
    
    private var statCards: some View {
        HStack(spacing: 12) {
            // Feeds today
            VStack(alignment: .leading, spacing: 6) {
                Text("Feeds today")
                    .font(AppFont.sans(11, weight: .medium))
                    .foregroundColor(Color(hex: "5A8A5A"))
                    .tracking(0.04 * 11)
                    .textCase(.uppercase)
                
                Text("\(todayFeeds.count) of \(recommendedFeedsPerDay.map { "\($0)" } ?? "—")")
                    .font(AppFont.sans(22, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                
                Text("today")
                    .font(AppFont.sans(11))
                    .foregroundColor(Color(hex: "8AB48A"))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "EEF4EE"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(hex: "5A8A5A").opacity(0.15), lineWidth: 0.5)
            )
            
            // Avg per feed
            VStack(alignment: .leading, spacing: 6) {
                Text("Avg per feed")
                    .font(AppFont.sans(11, weight: .medium))
                    .foregroundColor(Color(hex: "7B6A9A"))
                    .tracking(0.04 * 11)
                    .textCase(.uppercase)
                
                Text(avgPerFeedDisplay)
                    .font(AppFont.sans(22, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                
                Text("consumed avg")
                    .font(AppFont.sans(11))
                    .foregroundColor(Color(hex: "A898C4"))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F0EDF5"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(hex: "7B6A9A").opacity(0.15), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — Week Tracker
    
    private var weekTracker: some View {
        WeekTrackerView(
            profileCreatedDate: feedStore.babyProfile?.createdAt,
            feeds: allFeeds
        )
    }
    
    // MARK: — Reassurance Line
    
    private var reassuranceLine: some View {
        Text(reassuranceText)
            .font(AppFont.sans(12).italic())
            .foregroundColor(Color(hex: "B4B2A9"))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var reassuranceText: String {
        if isEmptyState {
            return "When you're ready, log \(babyName)'s first feed"
        } else if todayFeeds.count < 3 {
            return "Today is just getting started"
        } else {
            return "\(babyName) is feeding well today"
        }
    }
    
    // MARK: — Log Feed Button
    
    private var logFeedButton: some View {
        Button(action: { showingLogFeed = true }) {
            Text("＋ Log a feed")
                .font(AppFont.sans(16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "1C2421"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

extension Notification.Name {
    static let switchToSettingsTab = Notification.Name("switchToSettingsTab")
}

// MARK: - Dashboard Guidance
private struct DashboardGuidance {
    let dailyMin: Int
    let dailyMax: Int
    let feedMin: Int
    let feedMax: Int
    let feedsPerDayMin: Int
    let feedsPerDayMax: Int
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
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    // MARK: — Header data
    
    private var babyName: String {
        feedStore.babyProfile?.babyName ?? "Baby"
    }
    
    private var ageDescription: String {
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return "" }
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfYear], from: dob, to: now)
        let months = (components.year ?? 0) * 12 + (components.month ?? 0)
        let weeks = components.weekOfYear ?? 0
        if months < 1 {
            return "\(weeks) week\(weeks == 1 ? "" : "s") old"
        } else if months < 24 {
            return "\(months) month\(months == 1 ? "" : "s") old"
        } else {
            let years = months / 12
            return "\(years) year\(years == 1 ? "" : "s") old"
        }
    }
    
    private var hasAnyFeeds: Bool {
        !allFeeds.isEmpty
    }
    
    // MARK: — Rhythm data
    
    private var todayFeeds: [Feed] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allFeeds.filter { $0.startTime >= startOfDay && $0.startTime < endOfDay }
    }
    
    private var yesterdayFeeds: [Feed] {
        let calendar = Calendar.current
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        let startOfToday = calendar.startOfDay(for: Date())
        return allFeeds.filter { $0.startTime >= startOfYesterday && $0.startTime < startOfToday }
    }
    
    private var rhythmFeeds: [Feed] {
        todayFeeds.isEmpty ? yesterdayFeeds : todayFeeds
    }
    
    private var rhythmDayLabel: String {
        todayFeeds.isEmpty ? "Yesterday" : "Today"
    }
    
    private var daysOfData: Int {
        let calendar = Calendar.current
        let dates = Set(allFeeds.map { calendar.startOfDay(for: $0.startTime) })
        return dates.count
    }
    
    private var rhythmHeadline: String {
        guard daysOfData >= 3 else { return "Feeding pattern is still forming" }
        let times = rhythmFeeds.map { hourFraction(from: $0.startTime) }
        guard times.count >= 2 else { return "Feeding pattern is still forming" }
        let mean = times.reduce(0, +) / Double(times.count)
        let variance = times.map { pow($0 - mean, 2) }.reduce(0, +) / Double(times.count)
        let sd = sqrt(variance)
        if sd < 0.15 {
            return "Morning feeds are becoming more regular"
        } else {
            return "Feeding is spread evenly through the day"
        }
    }
    
    private var rhythmReassurance: String {
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: Date()))!
        let recentFeeds = allFeeds.filter { $0.startTime >= threeDaysAgo }.sorted { $0.startTime < $1.startTime }
        guard recentFeeds.count >= 3 else { return "More feeds will reveal a pattern" }
        var gaps: [TimeInterval] = []
        for i in 1..<recentFeeds.count {
            gaps.append(recentFeeds[i].startTime.timeIntervalSince(recentFeeds[i-1].startTime))
        }
        let avgGap = gaps.reduce(0, +) / Double(gaps.count)
        let hours = Int(round(avgGap / 3600))
        return "\(babyName) tends to feed every \(hours) hour\(hours == 1 ? "" : "s")"
    }
    
    private func hourFraction(from date: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return Double(hour * 60 + minute) / 1440.0
    }
    
    private func isGoodFeed(_ feed: Feed) -> Bool {
        let prepared = Int(feed.amount)
        let consumed = feed.consumedMl ?? prepared
        return Double(consumed) >= Double(prepared) * 0.75
    }
    
    // MARK: — Trend data
    
    private struct WeekDayData: Identifiable {
        let id = UUID()
        let letter: String
        let amount: Double
        let isToday: Bool
        let isFuture: Bool
    }
    
    private var currentWeekData: [WeekDayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today))!
        let letters = ["M", "T", "W", "T", "F", "S", "S"]
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: monday)!
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            let dayFeeds = allFeeds.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            let total = dayFeeds.reduce(0.0) { $0 + Double($1.consumedMl ?? Int($1.amount)) }
            return WeekDayData(letter: letters[offset], amount: total, isToday: isToday, isFuture: isFuture)
        }
    }
    
    private var thisWeekTotal: Double {
        currentWeekData.filter { !$0.isFuture }.reduce(0) { $0 + $1.amount }
    }
    
    private var lastWeekTotal: Double {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let thisMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today))!
        let lastMonday = calendar.date(byAdding: .day, value: -7, to: thisMonday)!
        let lastSunday = calendar.date(byAdding: .day, value: 7, to: lastMonday)!
        let weekFeeds = allFeeds.filter { $0.startTime >= lastMonday && $0.startTime < lastSunday }
        return weekFeeds.reduce(0.0) { $0 + Double($1.consumedMl ?? Int($1.amount)) }
    }
    
    private var trendHeadline: String {
        guard daysOfData >= 7 else { return "Feeding is building a rhythm" }
        guard lastWeekTotal > 0 else { return "Feeding is building a rhythm" }
        let diff = (thisWeekTotal - lastWeekTotal) / lastWeekTotal
        if abs(diff) <= 0.10 {
            return "This week feels steady and consistent"
        } else if diff > 0 {
            return "\(babyName) is drinking a little more this week"
        } else {
            return "This week is a little lighter than last week"
        }
    }
    
    private var trendReassurance: String {
        guard lastWeekTotal > 0 else { return "Keep logging to see the full picture" }
        let diff = (thisWeekTotal - lastWeekTotal) / lastWeekTotal
        if abs(diff) <= 0.10 {
            return "Similar to last week. Feeding feels steady."
        } else if diff > 0 {
            return "A little more than usual — this can be normal."
        } else {
            return "A little lighter than usual — this can be normal."
        }
    }
    
    // MARK: — Growth spurt data
    
    private var showGrowthCard: Bool {
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return false }
        let ageDays = Calendar.current.dateComponents([.day], from: dob, to: Date()).day ?? 0
        let spurtAges = [14, 21, 42, 84, 112, 168]
        return spurtAges.contains { abs(ageDays - $0) <= 7 }
    }
    
    private var nearestSpurtAgeDays: Int? {
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return nil }
        let ageDays = Calendar.current.dateComponents([.day], from: dob, to: Date()).day ?? 0
        let spurtAges = [14, 21, 42, 84, 112, 168]
        return spurtAges.min { abs(ageDays - $0) < abs(ageDays - $1) }
    }
    
    private var growthSpurtLabel: String {
        guard let days = nearestSpurtAgeDays else { return "" }
        switch days {
        case 14: return "2-week"
        case 21: return "3-week"
        case 42: return "6-week"
        case 84: return "3-month"
        case 112: return "4-month"
        case 168: return "6-month"
        default: return ""
        }
    }
    
    // MARK: — Body
    
    var body: some View {
        ZStack {
            Color(hex: "F7F6F2").ignoresSafeArea()
            
            insightsBlobs
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, geometrySafeTop + 20)
                    
                    if hasAnyFeeds {
                        feedingRhythmCard
                            .padding(.top, 24)
                        
                        intakeTrendCard
                            .padding(.top, 12)
                        
                        if showGrowthCard {
                            growthStageCard
                                .padding(.top, 12)
                        }
                    } else {
                        emptyState
                            .padding(.top, 40)
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var geometrySafeTop: CGFloat {
        // Use a reasonable default; actual safe area handled by device
        0
    }
    
    // MARK: — Blobs
    
    private var insightsBlobs: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "D4A898").opacity(0.35))
                .frame(width: 200, height: 200)
                .position(x: UIScreen.main.bounds.width + 60, y: UIScreen.main.bounds.height + 60)
            
            Circle()
                .fill(Color(hex: "C8C0D4").opacity(0.38))
                .frame(width: 170, height: 170)
                .position(x: -70, y: 160)
            
            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.40))
                .frame(width: 110, height: 110)
                .position(x: UIScreen.main.bounds.width + 30, y: -30)
            
            Circle()
                .fill(Color(hex: "B0C4B0").opacity(0.32))
                .frame(width: 130, height: 130)
                .position(x: -40, y: -40)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Insights")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color(hex: "1C2421"))
            
            Text("\(babyName) · \(ageDescription)")
                .font(AppFont.sans(13))
                .foregroundColor(Color(hex: "888780"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Empty state
    
    private var emptyState: some View {
        Text("Insights will appear as you log feeds.")
            .font(AppFont.sans(13))
            .foregroundColor(Color(hex: "888780"))
            .italic()
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: — Card 1: Feeding rhythm
    
    private var feedingRhythmCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Feeding rhythm")
                    .font(AppFont.sans(10, weight: .medium))
                    .foregroundStyle(Color(hex: "7B6A9A"))
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: "F0EDF5"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "clock")
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundStyle(Color(hex: "7B6A9A"))
                    )
            }
            
            Text(rhythmHeadline)
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color(hex: "1C2421"))
                .lineSpacing(1.3 * 15 - 15)
                .padding(.top, 8)
            
            rhythmDotStrip
                .padding(.top, 14)
            
            Text(rhythmReassurance)
                .font(AppFont.sans(12).italic())
                .foregroundStyle(Color(hex: "B4B2A9"))
                .padding(.top, 8)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }
    
    private var rhythmDotStrip: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(hex: "E8E6E1"))
                    .frame(height: 1)
                
                ForEach(rhythmFeeds, id: \.id) { feed in
                    let fraction = hourFraction(from: feed.startTime)
                    Circle()
                        .fill(isGoodFeed(feed) ? Color(hex: "7B6A9A") : Color(hex: "C8C0D4"))
                        .frame(width: 8, height: 8)
                        .position(x: fraction * UIScreen.main.bounds.width * 0.85, y: 0.5)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("6am")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color(hex: "B4B2A9"))
                Spacer()
                Text("12pm")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color(hex: "B4B2A9"))
                Spacer()
                Text("10pm")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color(hex: "B4B2A9"))
            }
            
            if todayFeeds.isEmpty && !yesterdayFeeds.isEmpty {
                Text("Yesterday")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color(hex: "B4B2A9"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    // MARK: — Card 2: Intake trend
    
    private var intakeTrendCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Intake trend")
                    .font(AppFont.sans(10, weight: .medium))
                    .foregroundStyle(Color(hex: "5A8A5A"))
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: "EEF4EE"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundStyle(Color(hex: "5A8A5A"))
                    )
            }
            
            Text(trendHeadline)
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color(hex: "1C2421"))
                .lineSpacing(1.3 * 15 - 15)
                .padding(.top, 8)
            
            trendBarChart
                .padding(.top, 14)
            
            Text(trendReassurance)
                .font(AppFont.sans(12).italic())
                .foregroundStyle(Color(hex: "B4B2A9"))
                .padding(.top, 8)
            
            weightContextLine
                .padding(.top, 6)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }
    
    private var weightContextLine: some View {
        Group {
            if let weightKg = feedStore.babyProfile?.weightInKg, weightKg > 0 {
                let rec = Int(weightKg * 150)
                Text("Based on \(String(format: "%.1f", weightKg)) kg · \(rec) ml recommended daily")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color(hex: "B4B2A9"))
            } else {
                Button(action: {
                    NotificationCenter.default.post(name: .switchToSettingsTab, object: nil)
                }) {
                    Text("Add \(babyName)'s weight in Settings for a personalised daily guide")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color(hex: "B07850"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var trendBarChart: some View {
        let data = currentWeekData
        let maxAmount = data.map { $0.amount }.max() ?? 1
        let yMax = max(maxAmount * 1.2, Double(recommendedDailyForChart))
        return Chart(data) { item in
            BarMark(
                x: .value("Day", item.letter),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(item.isToday ? Color(hex: "5A8A5A") : (item.isFuture ? Color(hex: "EEF4EE") : Color(hex: "DCE9DC")))
            .cornerRadius(3)
        }
        .frame(height: 60)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
                            .font(AppFont.sans(9))
                            .foregroundStyle(Color(hex: "B4B2A9"))
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartYScale(domain: 0...yMax)
    }
    
    private var recommendedDailyForChart: Int {
        if let weightKg = feedStore.babyProfile?.weightInKg, weightKg > 0 {
            return Int(weightKg * 150)
        }
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return 600 }
        let months = FormulaStageService.ageInMonths(from: dob)
        switch months {
        case 0..<1: return 600
        case 1..<2: return 700
        case 2..<4: return 900
        case 4..<6: return 1000
        case 6..<9: return 900
        case 9..<12: return 800
        case 12..<24: return 500
        default: return 400
        }
    }
    
    // MARK: — Card 3: Growth stage nudge
    
    private var growthStageCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Growth stage")
                    .font(AppFont.sans(10, weight: .medium))
                    .foregroundStyle(Color(hex: "B07850"))
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: "F5EDE4"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundStyle(Color(hex: "C47B4A"))
                    )
            }
            
            Text("\(growthSpurtLabel) growth spurt is coming up")
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color(hex: "1C2421"))
                .lineSpacing(1.3 * 15 - 15)
                .padding(.top, 8)
            
            Text("\(babyName) may want to feed more often over the next few days. This is completely normal.")
                .font(AppFont.sans(12))
                .foregroundStyle(Color(hex: "9A8878"))
                .lineSpacing(1.5 * 12 - 12)
                .padding(.top, 6)
        }
        .padding(18)
        .background(Color(hex: "FBF5F0"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: "B48C6E").opacity(0.2), lineWidth: 0.5)
        )
    }
}

#Preview {
    DashboardView()
        .environment(FeedStore())
        .environment(SelectedFormulaStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
