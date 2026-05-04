import Foundation
import SwiftData

@Model
class Feed {
    var id: UUID = UUID()
    var startTime: Date = Date()
    var endTime: Date? = nil
    var amount: Double = 0
    var consumedMl: Int? = nil
    var unit: FeedUnit = FeedUnit.milliliters
    var notes: String = ""
    var createdAt: Date = Date()
    var completed: Bool = true
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        amount: Double,
        consumedMl: Int? = nil,
        unit: FeedUnit = .milliliters,
        notes: String = "",
        completed: Bool = true
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.amount = amount
        self.consumedMl = consumedMl
        self.unit = unit
        self.notes = notes
        self.createdAt = Date()
        self.completed = completed
    }
    
    /// Returns the duration of the feed in minutes
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Returns duration in minutes as a formatted string
    var durationInMinutes: String {
        guard let duration = duration else { return "In progress" }
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Returns true if the feed is currently active (no end time)
    var isActive: Bool {
        return endTime == nil
    }
    
    /// Formatted amount string with unit
    var formattedAmount: String {
        let unitString = unit == .milliliters ? "ml" : "oz"
        return String(format: "%.1f %@", amount, unitString)
    }
}

enum FeedUnit: String, Codable, CaseIterable {
    case milliliters = "ml"
    case ounces = "oz"
    
    var displayName: String {
        switch self {
        case .milliliters:
            return "Milliliters (ml)"
        case .ounces:
            return "Ounces (oz)"
        }
    }
    
    var shortName: String {
        switch self {
        case .milliliters:
            return "ml"
        case .ounces:
            return "oz"
        }
    }
}

// MARK: - Feed Statistics
struct FeedStatistics {
    let feeds: [Feed]
    let dateRange: DateInterval
    var babyProfile: BabyProfile?
    
    /// Total number of feeds in the date range
    var totalFeeds: Int {
        feeds.count
    }
    
    /// Total amount consumed in the date range
    var totalAmount: Double {
        feeds.reduce(0) { $0 + $1.amount }
    }
    
    /// Average amount per feed
    var averageAmount: Double {
        guard !feeds.isEmpty else { return 0 }
        return totalAmount / Double(feeds.count)
    }
    
    /// Average duration per feed in seconds
    var averageDuration: TimeInterval? {
        let completedFeeds = feeds.compactMap { $0.duration }
        guard !completedFeeds.isEmpty else { return nil }
        return completedFeeds.reduce(0, +) / Double(completedFeeds.count)
    }
    
    /// Average duration formatted as string
    var averageDurationFormatted: String {
        guard let avgDuration = averageDuration else { return "N/A" }
        let minutes = Int(avgDuration / 60)
        let seconds = Int(avgDuration.truncatingRemainder(dividingBy: 60))
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Feeds per day average
    var feedsPerDay: Double {
        let calendar = Calendar.current
        let dayCount = calendar.dateComponents([.day], from: dateRange.start, to: dateRange.end).day ?? 0
        guard dayCount > 0 else { return 0 }
        return Double(feeds.count) / Double(dayCount)
    }
    
    /// Maximum single feed amount
    var maxFeedAmount: Double {
        feeds.map { $0.amount }.max() ?? 0
    }
    
    /// Minimum single feed amount
    var minFeedAmount: Double {
        feeds.map { $0.amount }.min() ?? 0
    }
}
