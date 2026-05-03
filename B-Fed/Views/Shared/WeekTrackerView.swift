import SwiftUI

// MARK: - Week Tracker View
/// A 7-day feed tracker strip showing feed activity relative to the baby's profile creation date.
struct WeekTrackerView: View {
    let profileCreatedDate: Date?
    let feeds: [Feed]
    
    private var windowStart: Date {
        let anchor = profileCreatedDate ?? firstFeedDate ?? Date()
        let calendar = Calendar.current
        let daysSinceAnchor = calendar.dateComponents([.day], from: calendar.startOfDay(for: anchor), to: calendar.startOfDay(for: Date())).day ?? 0
        let windowNumber = max(0, daysSinceAnchor / 7)
        return calendar.date(byAdding: .day, value: windowNumber * 7, to: calendar.startOfDay(for: anchor)) ?? Date()
    }
    
    private var firstFeedDate: Date? {
        guard let earliest = feeds.min(by: { $0.startTime < $1.startTime }) else { return nil }
        return Calendar.current.startOfDay(for: earliest.startTime)
    }
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var windowDays: [WeekDay] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: windowStart) ?? Date()
            return WeekDay(
                date: date,
                hasFeeds: hasFeeds(on: date),
                isToday: calendar.isDate(date, inSameDayAs: today),
                isFuture: date > today,
                dayLetter: dayLetter(for: date)
            )
        }
    }
    
    private func hasFeeds(on date: Date) -> Bool {
        let calendar = Calendar.current
        return feeds.contains { feed in
            calendar.isDate(feed.startTime, inSameDayAs: date)
        }
    }
    
    private func dayLetter(for date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return "S" // Sunday
        case 2: return "M" // Monday
        case 3: return "T" // Tuesday
        case 4: return "W" // Wednesday
        case 5: return "T" // Thursday
        case 6: return "F" // Friday
        case 7: return "S" // Saturday
        default: return "?"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("This week")
                .font(AppFont.sans(9, weight: .medium))
                .foregroundStyle(Color(hex: "888780"))
                .tracking(0.05 * 9)
                .textCase(.uppercase)
                .padding(.bottom, 10)
            
            HStack(spacing: 0) {
                ForEach(Array(windowDays.enumerated()), id: \.element.id) { index, day in
                    DayDot(day: day)
                    if index < 6 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }
}

// MARK: - Week Day Model
private struct WeekDay: Identifiable {
    let id = UUID()
    let date: Date
    let hasFeeds: Bool
    let isToday: Bool
    let isFuture: Bool
    let dayLetter: String
}

// MARK: - Day Dot
private struct DayDot: View {
    let day: WeekDay
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(dotFill)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(dotStroke, lineWidth: dotStrokeWidth)
                    )
                
                if showCentreDot {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }
            }
            
            Text(day.dayLetter)
                .font(AppFont.sans(9, weight: dayLetterWeight))
                .foregroundStyle(dayLetterColor)
        }
    }
    
    // MARK: State
    
    private var showCentreDot: Bool {
        day.hasFeeds && !day.isFuture
    }
    
    private var dotFill: Color {
        if day.isToday && day.hasFeeds {
            return Color(hex: "5A8A5A")
        } else if day.isToday && !day.hasFeeds {
            return Color(hex: "EEF4EE")
        } else if day.isFuture {
            return Color(hex: "F0EDF5")
        } else if day.hasFeeds {
            return Color(hex: "7B6A9A")
        } else {
            return Color(hex: "F5F5F5")
        }
    }
    
    private var dotStroke: Color {
        if day.isToday && !day.hasFeeds {
            return Color(hex: "5A8A5A")
        } else if day.isFuture {
            return Color(hex: "C8C0D4")
        } else if !day.hasFeeds && !day.isFuture {
            return Color(hex: "E0E0E0")
        } else {
            return Color.clear
        }
    }
    
    private var dotStrokeWidth: CGFloat {
        if day.isToday && !day.hasFeeds {
            return 1.5
        } else if day.isFuture {
            return 1.5
        } else if !day.hasFeeds && !day.isFuture {
            return 1.0
        } else {
            return 0
        }
    }
    
    private var dayLetterColor: Color {
        if day.isToday {
            return Color(hex: "5A8A5A")
        } else if day.hasFeeds && !day.isFuture {
            return Color(hex: "7B6A9A")
        } else {
            return Color(hex: "B4B2A9")
        }
    }
    
    private var dayLetterWeight: Font.Weight {
        day.isToday ? .semibold : .medium
    }
}
