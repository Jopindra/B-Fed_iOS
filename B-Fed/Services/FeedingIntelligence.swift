import Foundation

// MARK: - Feeding Intelligence
/// Gentle, supportive feeding guidance without pressure
class FeedingIntelligence {
    
    // MARK: - Daily Intake Calculation
    
    /// Calculates daily intake range based on weight or age
    /// Uses 150ml per kg with ±15-20% range when weight available
    static func dailyIntakeGuide(for profile: BabyProfile?) -> DailyGuide {
        guard let profile = profile else {
            return DailyGuide(typical: (500, 750), display: "500–750")
        }
        
        // Priority 1: Weight-based calculation (if available)
        if let weightGrams = profile.currentWeight ?? profile.birthWeight {
            let weightKg = Double(weightGrams) / 1000.0
            let baseIntake = Int(weightKg * 150) // 150ml per kg
            
            // ±20% range for flexibility
            let minIntake = Int(Double(baseIntake) * 0.8)
            let maxIntake = Int(Double(baseIntake) * 1.2)
            
            return DailyGuide(
                typical: (minIntake, maxIntake),
                display: "\(minIntake)–\(maxIntake)"
            )
        }
        
        // Priority 2: Age-based ranges (when no weight)
        let days = profile.ageInDays
        
        switch days {
        case 0...14:
            // 0–2 weeks
            return DailyGuide(typical: (300, 500), display: "300–500")
        case 15...28:
            // 2–4 weeks
            return DailyGuide(typical: (400, 700), display: "400–700")
        case 29...60:
            // 1–2 months
            return DailyGuide(typical: (500, 900), display: "500–900")
        case 61...120:
            // 2–4 months
            return DailyGuide(typical: (600, 1000), display: "600–1000")
        case 121...180:
            // 4–6 months
            return DailyGuide(typical: (700, 1200), display: "700–1200")
        default:
            // 6+ months
            return DailyGuide(typical: (600, 900), display: "600–900")
        }
    }
    
    // MARK: - Per-Feed Guidance
    
    /// Calculates typical per-feed amount
    /// Divides daily intake by 6–8 feeds
    static func perFeedGuide(for profile: BabyProfile?) -> PerFeedGuide {
        let daily = dailyIntakeGuide(for: profile)
        let avgDaily = (daily.typical.min + daily.typical.max) / 2
        
        // Divide by 6-8 feeds
        let maxFeed = avgDaily / 6
        let minFeed = avgDaily / 8
        
        return PerFeedGuide(
            typical: (minFeed, maxFeed),
            display: "Typical feed: \(minFeed)–\(maxFeed) ml"
        )
    }
    
    // MARK: - Dashboard Display
    
    /// Formats intake display: "520 / 700 ml"
    static func intakeDisplay(current: Double, profile: BabyProfile?) -> String {
        let guide = dailyIntakeGuide(for: profile)
        let max = guide.typical.max
        return "\(Int(current)) / \(max) ml"
    }
    
    /// Calculates bottle fill as % of daily intake (capped at 85%)
    static func bottleFillLevel(current: Double, profile: BabyProfile?) -> CGFloat {
        let guide = dailyIntakeGuide(for: profile)
        let target = Double(guide.typical.max)
        
        let percentage = current / target
        let capped = min(percentage, 0.85) // Cap at 85%
        
        return CGFloat(0.1 + (capped * 0.85)) // Base 10% + progress
    }
    
    // MARK: - Supporting Messages
    
    /// Provides gentle, supportive message based on progress
    static func supportingMessage(current: Double, profile: BabyProfile?) -> String {
        let guide = dailyIntakeGuide(for: profile)
        let percentage = (current / Double(guide.typical.max)) * 100
        
        // On track
        if percentage >= 80 {
            return ["You're right on track", "Doing great today", "Perfect progress"].randomElement()!
        }
        
        // Getting there
        if percentage >= 50 {
            return ["Building steadily", "You're doing fine", "Gentle progress"].randomElement()!
        }
        
        // Lower intake - provide reassurance
        if percentage < 50 {
            let reassurances = [
                "Frequent small feeds are completely normal",
                "Every baby has lighter days",
                "Trust your baby's appetite",
                "You're responding perfectly to their needs",
                "Some days are simply lighter — that's okay"
            ]
            return reassurances.randomElement()!
        }
        
        return "You're doing great"
    }
    
    /// Contextual guidance based on time of day
    static func contextualGuidance(current: Double, profile: BabyProfile?) -> String? {
        guard let profile = profile else { return nil }
        
        let guide = dailyIntakeGuide(for: profile)
        let percentage = (current / Double(guide.typical.max)) * 100
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Morning context
        if hour < 12 && percentage < 30 {
            let perFeed = perFeedGuide(for: profile)
            return perFeed.display
        }
        
        // Evening context
        if hour > 18 && percentage < 60 {
            return "Evening feeds help settle for the night"
        }
        
        return nil
    }
    
    // MARK: - Insights
    
    /// Generates simple, helpful observations from feeding data
    static func insights(from feeds: [Feed], profile: BabyProfile?) -> [String] {
        guard !feeds.isEmpty else { return [] }
        
        var insights: [String] = []
        let sortedFeeds = feeds.sorted { $0.startTime < $1.startTime }
        
        // Time pattern
        if let timeInsight = timePatternInsight(from: sortedFeeds) {
            insights.append(timeInsight)
        }
        
        // Trend insight
        if let trendInsight = trendInsight(from: sortedFeeds) {
            insights.append(trendInsight)
        }
        
        // Consistency insight
        if let consistencyInsight = consistencyInsight(from: sortedFeeds) {
            insights.append(consistencyInsight)
        }
        
        return insights.isEmpty ? ["You're building a beautiful routine"] : insights
    }
    
    // MARK: - Private Insight Methods
    
    private static func timePatternInsight(from feeds: [Feed]) -> String? {
        guard feeds.count >= 5 else { return nil }
        
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        
        for feed in feeds {
            let hour = calendar.component(.hour, from: feed.startTime)
            hourCounts[hour, default: 0] += 1
        }
        
        guard let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        let timeOfDay: String
        switch peakHour {
        case 5...11: timeOfDay = "morning"
        case 12...16: timeOfDay = "afternoon"
        case 17...21: timeOfDay = "evening"
        default: timeOfDay = "night"
        }
        
        return "Most feeds happen in the \(timeOfDay)"
    }
    
    private static func trendInsight(from feeds: [Feed]) -> String? {
        guard feeds.count >= 10 else { return nil }
        
        let calendar = Calendar.current
        var dailyTotals: [Date: Double] = [:]
        
        for feed in feeds {
            let day = calendar.startOfDay(for: feed.startTime)
            dailyTotals[day, default: 0] += feed.amount
        }
        
        let sortedDays = dailyTotals.keys.sorted()
        guard sortedDays.count >= 5 else { return nil }
        
        // Compare recent 3 days vs previous 3 days
        let recent = Array(sortedDays.suffix(3))
        let previous = Array(sortedDays.dropLast(3).suffix(3))
        
        let recentAvg = recent.compactMap { dailyTotals[$0] }.reduce(0, +) / Double(recent.count)
        let previousAvg = previous.compactMap { dailyTotals[$0] }.reduce(0, +) / Double(previous.count)
        
        if recentAvg > previousAvg * 1.1 {
            return "Average intake is increasing"
        }
        
        if abs(recentAvg - previousAvg) < previousAvg * 0.1 {
            return "Feeds are becoming more consistent"
        }
        
        return nil
    }
    
    private static func consistencyInsight(from feeds: [Feed]) -> String? {
        guard feeds.count >= 7 else { return nil }
        
        let sorted = feeds.sorted { $0.startTime < $1.startTime }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sorted.count {
            let interval = sorted[i].startTime.timeIntervalSince(sorted[i-1].startTime)
            if interval > 300 && interval < 14400 { // 5 min to 4 hours
                intervals.append(interval)
            }
        }
        
        guard intervals.count >= 5 else { return nil }
        
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.map { pow($0 - avg, 2) }.reduce(0, +) / Double(intervals.count)
        let cv = sqrt(variance) / avg
        
        if cv < 0.35 {
            let hours = Int(avg / 3600)
            if hours >= 2 && hours <= 4 {
                return "Beautiful \(hours)-hour rhythm emerging"
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Types

struct DailyGuide {
    let typical: (min: Int, max: Int)
    let display: String
}

struct PerFeedGuide {
    let typical: (min: Int, max: Int)
    let display: String
}

// MARK: - Reassurance Engine

struct ReassuranceEngine {
    
    /// Messages for low intake days
    static func lowIntakeReassurance() -> String {
        [
            "Frequent small feeds are completely normal",
            "Every baby has lighter days",
            "Trust your baby's appetite",
            "You're responding perfectly to their needs",
            "Some days are simply lighter — that's okay",
            "Baby leads, you follow — you're doing it right"
        ].randomElement()!
    }
    
    /// Messages for consistent logging
    static func consistencyReinforcement() -> String {
        [
            "You're building a beautiful routine",
            "Great rhythm developing",
            "Consistency is emerging naturally",
            "You're finding your groove"
        ].randomElement()!
    }
    
    /// Messages for improving intake
    static func improvementEncouragement() -> String {
        [
            "Great growth happening",
            "Baby is thriving",
            "Wonderful progress together",
            "You're both doing beautifully"
        ].randomElement()!
    }
    
    /// Messages after logging a feed
    static func postFeedEncouragement() -> String {
        [
            "Nice one",
            "That feed counts",
            "Keep it up",
            "Well done",
            "Perfect"
        ].randomElement()!
    }
}
