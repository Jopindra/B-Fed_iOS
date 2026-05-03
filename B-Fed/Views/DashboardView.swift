import SwiftUI
import SwiftData

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
        guidance?.dailyMax
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
                            
                            reassuranceLine
                                .padding(.top, 20)
                            
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
