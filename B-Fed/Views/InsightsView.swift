import SwiftUI
import SwiftData
import Charts

// MARK: - Insights View (used by ContentView)
struct InsightsView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(ProfileStore.self) private var profileStore
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]

    // MARK: — Header data

    private var babyName: String {
        profileStore.fetchProfile()?.babyName ?? "Baby"
    }

    private var ageDescription: String {
        profileStore.fetchProfile()?.ageDescription ?? ""
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
        guard let dob = profileStore.fetchProfile()?.dateOfBirth else { return false }
        let ageDays = Calendar.current.dateComponents([.day], from: dob, to: Date()).day ?? 0
        let spurtAges = [14, 21, 42, 84, 112, 168]
        return spurtAges.contains { abs(ageDays - $0) <= 7 }
    }

    private var nearestSpurtAgeDays: Int? {
        guard let dob = profileStore.fetchProfile()?.dateOfBirth else { return nil }
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
        GeometryReader { geometry in
            ZStack {
                Color.surfaceCream.ignoresSafeArea()

                insightsBlobs(in: geometry)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                            .padding(.top, geometry.safeAreaInsets.top + 20)

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
    }

    // MARK: — Blobs

    private func insightsBlobs(in geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(Color(hex: "D4A898").opacity(0.35))
                .frame(width: 200, height: 200)
                .position(x: geometry.size.width + 60, y: geometry.size.height + 60)

            Circle()
                .fill(Color.accentLavender.opacity(0.38))
                .frame(width: 170, height: 170)
                .position(x: -70, y: 160)

            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.40))
                .frame(width: 110, height: 110)
                .position(x: geometry.size.width + 30, y: -30)

            Circle()
                .fill(Color(hex: "B0C4B0").opacity(0.32))
                .frame(width: 130, height: 130)
                .position(x: -40, y: -40)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea()
    }

    // MARK: — Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Insights")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color.textPrimary)

            Text("\(babyName) · \(ageDescription)")
                .font(AppFont.sans(13))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Empty state

    private var emptyState: some View {
        Text("Insights will appear as you log feeds.")
            .font(AppFont.sans(13))
            .foregroundColor(Color.textSecondary)
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
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(1.3 * 15 - 15)
                .padding(.top, 8)

            rhythmDotStrip
                .padding(.top, 14)

            Text(rhythmReassurance)
                .font(AppFont.sans(12).italic())
                .foregroundStyle(Color.textTertiary)
                .padding(.top, 8)
        }
        .padding(18)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }

    private var rhythmDotStrip: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "E8E6E1"))
                        .frame(height: 1)

                    ForEach(rhythmFeeds, id: \.id) { feed in
                        let fraction = hourFraction(from: feed.startTime)
                        Circle()
                            .fill(isGoodFeed(feed) ? Color(hex: "7B6A9A") : Color.accentLavender)
                            .frame(width: 8, height: 8)
                            .position(x: fraction * geo.size.width, y: geo.size.height / 2)
                    }
                }
            }
            .frame(height: 8)

            HStack {
                Text("6am")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text("12pm")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text("10pm")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color.textTertiary)
            }

            if todayFeeds.isEmpty && !yesterdayFeeds.isEmpty {
                Text("Yesterday")
                    .font(AppFont.sans(9))
                    .foregroundStyle(Color.textTertiary)
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
                    .foregroundStyle(Color.accentGreen)
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)

                Spacer()

                Circle()
                    .fill(Color(hex: "EEF4EE"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundStyle(Color.accentGreen)
                    )
            }

            Text(trendHeadline)
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(1.3 * 15 - 15)
                .padding(.top, 8)

            trendBarChart
                .padding(.top, 14)

            Text(trendReassurance)
                .font(AppFont.sans(12).italic())
                .foregroundStyle(Color.textTertiary)
                .padding(.top, 8)

            weightContextLine
                .padding(.top, 6)
        }
        .padding(18)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }

    private var weightContextLine: some View {
        Group {
            if let weightKg = profileStore.fetchProfile()?.weightInKg, weightKg > 0 {
                let rec = Int(weightKg * 150)
                Text("Based on \(String(format: "%.1f", weightKg)) kg · \(rec) ml recommended daily")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.textTertiary)
            } else {
                Button(action: {
                    NotificationCenter.default.post(name: .switchToSettingsTab, object: nil)
                }) {
                    Text("Add \(babyName)'s weight in Settings for a personalised daily guide")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color(hex: "B07850"))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Add weight in Settings for personalised daily guide")
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
            .foregroundStyle(item.isToday ? Color.accentGreen : (item.isFuture ? Color(hex: "EEF4EE") : Color(hex: "DCE9DC")))
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
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartYScale(domain: 0...yMax)
    }

    private var recommendedDailyForChart: Int {
        if let weightKg = profileStore.fetchProfile()?.weightInKg, weightKg > 0 {
            return Int(weightKg * 150)
        }
        guard let dob = profileStore.fetchProfile()?.dateOfBirth else { return 600 }
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
                .foregroundStyle(Color.textPrimary)
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
