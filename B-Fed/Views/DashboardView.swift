import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(ProfileStore.self) private var profileStore
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
        profileStore.fetchProfile()?.babyName ?? "Baby"
    }

    private var parentName: String {
        profileStore.fetchProfile()?.parentName ?? "there"
    }

    private var ageInMonths: Int? {
        guard let dob = profileStore.fetchProfile()?.dateOfBirth else { return nil }
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
        if let weightKg = profileStore.fetchProfile()?.weightInKg, weightKg > 0 {
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
                Color.surfaceCream.ignoresSafeArea()

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
                .fill(Color.accentLavender.opacity(0.45))
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
        .accessibilityHidden(true)
        .ignoresSafeArea()
    }

    // MARK: — Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEmptyState {
                Text("Good morning, \(parentName).")
                    .font(AppFont.sans(20, weight: .semibold))
                    .foregroundColor(Color.textPrimary)

                Text("\(babyName) hasn't fed yet today")
                    .font(AppFont.sans(13))
                    .foregroundColor(Color.textSecondary)
            } else {
                Text("Just finished.")
                    .font(AppFont.sans(20, weight: .semibold))
                    .foregroundColor(Color.textPrimary)

                if let mins = lastFeedMinutesAgo {
                    Text("\(babyName) · \(timeAgoString(minutes: mins))")
                        .font(AppFont.sans(13))
                        .foregroundColor(Color.textSecondary)
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
                .stroke(Color.accentLavender, lineWidth: 8)
                .frame(width: 140, height: 140)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Color(hex: "7B6A9A"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(totalMlToday)")
                    .font(AppFont.sans(28, weight: .semibold))
                    .foregroundColor(Color.textPrimary)

                if let target = recommendedDailyMl {
                    Text("of \(target) ml")
                        .font(AppFont.sans(11))
                        .foregroundColor(Color.textSecondary)
                } else {
                    Text("ml")
                        .font(AppFont.sans(11))
                        .foregroundColor(Color.textSecondary)
                }
            }
            .background(
                Circle()
                    .fill(Color(hex: "F0EDF5"))
                    .frame(width: 120, height: 120)
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily intake progress")
        .accessibilityValue("\(totalMlToday) millilitres \(recommendedDailyMl.map { "of \($0) millilitres" } ?? "logged")")
    }

    // MARK: — Stat Cards

    private var statCards: some View {
        HStack(spacing: 12) {
            // Feeds today
            VStack(alignment: .leading, spacing: 6) {
                Text("Feeds today")
                    .font(AppFont.sans(11, weight: .medium))
                    .foregroundColor(Color.accentGreen)
                    .tracking(0.04 * 11)
                    .textCase(.uppercase)

                if let target = recommendedFeedsPerDay {
                    Text("\(todayFeeds.count) of \(target)")
                        .font(AppFont.sans(22, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                } else {
                    Text("\(todayFeeds.count)")
                        .font(AppFont.sans(22, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                }

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
                    .stroke(Color.accentGreen.opacity(0.15), lineWidth: 0.5)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Feeds today: \(todayFeeds.count) \(recommendedFeedsPerDay.map { "of \($0)" } ?? "logged")")

            // Avg per feed
            VStack(alignment: .leading, spacing: 6) {
                Text("Avg per feed")
                    .font(AppFont.sans(11, weight: .medium))
                    .foregroundColor(Color(hex: "7B6A9A"))
                    .tracking(0.04 * 11)
                    .textCase(.uppercase)

                Text(avgPerFeedDisplay)
                    .font(AppFont.sans(22, weight: .semibold))
                    .foregroundColor(Color.textPrimary)

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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Average per feed: \(avgPerFeedDisplay)")
        }
    }

    // MARK: — Week Tracker

    private var weekTracker: some View {
        WeekTrackerView(
            profileCreatedDate: profileStore.fetchProfile()?.createdAt,
            feeds: allFeeds
        )
    }

    // MARK: — Reassurance Line

    private var reassuranceLine: some View {
        Text(reassuranceText)
            .font(AppFont.sans(12).italic())
            .foregroundColor(Color.textTertiary)
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
                .background(Color.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log a feed")
    }
}

extension Notification.Name {
    static let switchToSettingsTab = Notification.Name("switchToSettingsTab")
    static let returnToOnboarding = Notification.Name("returnToOnboarding")
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

#Preview {
    DashboardView()
        .environment(FeedStore())
        .environment(ProfileStore())
        .environment(SelectedFormulaStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
