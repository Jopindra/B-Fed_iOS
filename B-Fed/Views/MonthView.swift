import SwiftUI

struct MonthView: View {
    @Environment(FeedStore.self) private var store
    @State private var selectedDate: Date?
    @State private var monthData: [DayCompletion] = []
    @State private var currentMonth: Date = Date()
    
    struct DayCompletion: Identifiable {
        let id = UUID()
        let date: Date
        let isLogged: Bool
        let isToday: Bool
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            monthHeader
            
            // Clean completion calendar
            completionCalendar
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, AppSpacing.xl)
            
            // Single supportive insight
            insightSection
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, 32)
            
            Spacer()
        }
        .background(Color.backgroundCard)
    }
    
    // MARK: - Header
    private var monthHeader: some View {
        VStack(spacing: 4) {
            Text(monthTitle)
                .font(AppFont.screenTitle)
                .foregroundStyle(Color.inkPrimary)
        }
        .padding(.top, 12)
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: currentMonth)
    }
    
    // MARK: - Completion Calendar
    private var completionCalendar: some View {
        VStack(spacing: 16) {
            // Minimal weekday labels
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Clean grid with lots of spacing
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 7),
                spacing: 12
            ) {
                ForEach(monthData) { day in
                    CompletionDay(
                        isLogged: day.isLogged,
                        isToday: day.isToday
                    )
                }
            }
        }
    }
    
    // MARK: - Insight
    private var insightSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(AppFont.sans(12, weight: .regular))
                .foregroundStyle(Color.almostAquaDark.opacity(0.6))
            
            Text(insightText)
                .font(AppFont.bodyLarge)
                .foregroundStyle(Color.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var insightText: String {
        let loggedCount = monthData.filter { $0.isLogged }.count
        if loggedCount == monthData.count {
            return "Perfect month — you're building a beautiful routine"
        } else if loggedCount > monthData.count / 2 {
            return "You logged feeds on \(loggedCount) days this month"
        } else {
            return "Every day you log is a step forward"
        }
    }
    
    init() {
        _monthData = State(initialValue: generateSampleMonthData())
    }
    
    private func generateSampleMonthData() -> [DayCompletion] {
        let calendar = Calendar.current
        let today = Date()
        var data: [DayCompletion] = []
        
        // Generate ~30 days with realistic pattern
        let loggedPattern = [
            false, false, // prev month
            true, true, true, false, true,  // week 1
            true, true, true, true, false, true, // week 2
            true, true, false, true, true, true,  // week 3
            true, true, true, false, true, true,  // week 4
            false, true, true, false, false, false, // week 5
            false, false // next month
        ]
        
        for (index, isLogged) in loggedPattern.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: index - 2, to: today) else { continue }
            let isToday = calendar.isDateInToday(date)
            data.append(DayCompletion(date: date, isLogged: isLogged, isToday: isToday))
        }
        
        return data
    }
}

// MARK: - Completion Day
struct CompletionDay: View {
    let isLogged: Bool
    let isToday: Bool
    
    var body: some View {
        ZStack {
            // Base shape
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
            
            // Today indicator (subtle ring)
            if isToday {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.almostAquaDark.opacity(0.4), lineWidth: 2)
            }
            
            // Logged indicator (subtle inner mark)
            if isLogged {
                loggedIndicator
            }
        }
        .frame(height: 44)
    }
    
    private var loggedIndicator: some View {
        Circle()
            .fill(Color.almostAquaDark.opacity(0.5))
            .frame(width: 6, height: 6)
    }
}


#Preview {
    MonthView()
        .background(Color.backgroundCard)
        .environment(FeedStore())
}
