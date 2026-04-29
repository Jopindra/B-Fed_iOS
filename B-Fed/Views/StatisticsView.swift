import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var selectedPeriod: TimePeriod = .last7Days
    @State private var stats: FeedStatistics?
    @State private var dailyData: [(date: Date, feeds: Int, amount: Double)] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    periodSelector
                    
                    if let stats = stats, !stats.feeds.isEmpty {
                        // Summary Cards
                        summaryCards(stats: stats)
                        
                        // Charts
                        if !dailyData.isEmpty {
                            amountChart
                            feedsChart
                        }
                        
                        // Detailed Stats
                        detailedStats(stats: stats)
                    } else {
                        // Empty State
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .background(Color.backgroundBase)
            .onAppear {
                updateStats()
            }
            .onChange(of: selectedPeriod) {
                updateStats()
            }
        }
    }
    
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button {
                        selectedPeriod = period
                    } label: {
                        if selectedPeriod == period {
                            Text(period.rawValue)
                                .tagActive()
                        } else {
                            Text(period.rawValue)
                                .tagInactive()
                        }
                    }
                }
            }
        }
    }
    
    private func summaryCards(stats: FeedStatistics) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Feeds",
                value: "\(stats.totalFeeds)",
                subtitle: String(format: "%.1f per day", stats.feedsPerDay),
                icon: "number.circle.fill",
                color: Color.peachDustDark
            )
            
            StatCard(
                title: "Total Amount",
                value: String(format: "%.0f", stats.totalAmount),
                subtitle: "milliliters",
                icon: "drop.circle.fill",
                color: Color.almostAquaDark
            )
            
            StatCard(
                title: "Average Feed",
                value: String(format: "%.0f", stats.averageAmount),
                subtitle: "per feed",
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                color: Color.orchidTintDark
            )
            
            StatCard(
                title: "Avg Duration",
                value: stats.averageDurationFormatted,
                subtitle: "per feed",
                icon: "clock.circle.fill",
                color: Color.orchidTintDark
            )
        }
    }
    
    private var amountChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Amount")
                .font(AppFont.sectionTitle)
            
            Chart(dailyData, id: \.date) { data in
                BarMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Amount", data.amount)
                )
                .foregroundStyle(Color.peachDustDark)
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
        }
        .cardStyle()
    }
    
    private var feedsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Feed Count")
                .font(AppFont.sectionTitle)
            
            Chart(dailyData, id: \.date) { data in
                LineMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.almostAquaDark)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.almostAquaDark.opacity(0.1))
                
                PointMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.almostAquaDark)
                .symbolSize(50)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
        }
        .cardStyle()
    }
    
    private func detailedStats(stats: FeedStatistics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(AppFont.sectionTitle)
                .foregroundStyle(Color.inkSecondary)
            
            VStack(spacing: 0) {
                StatRow(title: "Largest Feed", value: String(format: "%.0f ml", stats.maxFeedAmount))
                Divider()
                StatRow(title: "Smallest Feed", value: String(format: "%.0f ml", stats.minFeedAmount))
                Divider()
                StatRow(title: "Total Duration", value: formatTotalDuration(stats))
            }
            .cardStyle()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(AppFont.display)
                .foregroundStyle(Color.inkSecondary)
            
            Text("No Data Yet")
                .font(AppFont.screenTitle)
            
            Text("Start logging feeds to see your statistics here.")
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppSpacing.xxl)
    }
    
    private func updateStats() {
        let interval = selectedPeriod.dateInterval
        stats = feedStore.getStatistics(from: interval.start, to: interval.end)
        
        // Calculate daily data
        if let stats = stats {
            dailyData = calculateDailyData(feeds: stats.feeds, interval: interval)
        }
    }
    
    private func calculateDailyData(feeds: [Feed], interval: DateInterval) -> [(Date, Int, Double)] {
        let calendar = Calendar.current
        var data: [(Date, Int, Double)] = []
        
        var currentDate = calendar.startOfDay(for: interval.start)
        let endDate = calendar.startOfDay(for: interval.end)
        
        while currentDate <= endDate {
            let dayFeeds = feeds.filter {
                calendar.isDate($0.startTime, inSameDayAs: currentDate)
            }
            
            let totalAmount = dayFeeds.reduce(0) { $0 + $1.amount }
            data.append((currentDate, dayFeeds.count, totalAmount))
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return data
    }
    
    private func formatTotalDuration(_ stats: FeedStatistics) -> String {
        let totalSeconds = stats.feeds.compactMap { $0.duration }.reduce(0, +)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppFont.serif(28))
                
                Text(subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(Color.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.body)
            
            Spacer()
            
            Text(value)
                .font(AppFont.sectionTitle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    StatisticsView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
