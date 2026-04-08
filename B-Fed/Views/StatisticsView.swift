import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var selectedPeriod: TimePeriod = .last7Days
    @State private var stats: FeedStatistics?
    @State private var dailyData: [(date: Date, feeds: Int, amount: Double)] = []
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case allTime = "All Time"
        
        var dateInterval: DateInterval {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                let start = calendar.startOfDay(for: now)
                return DateInterval(start: start, end: now)
            case .last7Days:
                let start = calendar.date(byAdding: .day, value: -7, to: now)!
                return DateInterval(start: start, end: now)
            case .last30Days:
                let start = calendar.date(byAdding: .day, value: -30, to: now)!
                return DateInterval(start: start, end: now)
            case .allTime:
                let start = calendar.date(byAdding: .year, value: -10, to: now)!
                return DateInterval(start: start, end: now)
            }
        }
    }
    
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
            .background(Color(.systemGroupedBackground))
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
                        withAnimation(.spring(response: 0.3)) {
                            selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedPeriod == period ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedPeriod == period ? Color.blue : Color(.secondarySystemFill))
                            )
                            .foregroundStyle(selectedPeriod == period ? .white : .primary)
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
                color: .blue
            )
            
            StatCard(
                title: "Total Amount",
                value: String(format: "%.0f", stats.totalAmount),
                subtitle: "milliliters",
                icon: "drop.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Average Feed",
                value: String(format: "%.0f", stats.averageAmount),
                subtitle: "per feed",
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Avg Duration",
                value: stats.averageDurationFormatted,
                subtitle: "per feed",
                icon: "clock.circle.fill",
                color: .purple
            )
        }
    }
    
    private var amountChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Amount")
                .font(.headline)
            
            Chart(dailyData, id: \.date) { data in
                BarMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Amount", data.amount)
                )
                .foregroundStyle(Color.blue.gradient)
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
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var feedsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Feed Count")
                .font(.headline)
            
            Chart(dailyData, id: \.date) { data in
                LineMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.green.opacity(0.1))
                
                PointMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Feeds", data.feeds)
                )
                .foregroundStyle(Color.green)
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
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func detailedStats(stats: FeedStatistics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 0) {
                StatRow(title: "Largest Feed", value: String(format: "%.0f ml", stats.maxFeedAmount))
                Divider()
                StatRow(title: "Smallest Feed", value: String(format: "%.0f ml", stats.minFeedAmount))
                Divider()
                StatRow(title: "Total Duration", value: formatTotalDuration(stats))
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start logging feeds to see your statistics here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
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
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
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
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
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
