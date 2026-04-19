import Foundation

// MARK: - Smart Feeding Intelligence
/// Provides intelligent feeding guidance based on baby profile and feeding history
class SmartFeedingIntelligence {
    
    // MARK: - Recommended Daily Intake
    
    /// Calculates recommended daily milk intake based on baby age and weight
    /// Uses pediatric guidelines: 150ml per kg of body weight per day
    static func recommendedDailyIntake(for profile: BabyProfile?) -> DailyIntakeGuide {
        guard let profile = profile else {
            return DailyIntakeGuide(typicalRange: (500, 750), optimalTarget: 600)
        }
        
        let days = profile.ageInDays
        let weight = profile.currentWeight ?? profile.birthWeight
        
        // Age-based calculation with weight adjustment
        let baseIntake: (min: Int, max: Int)
        
        switch days {
        case 0...3:
            // Newborn: small frequent feeds
            baseIntake = (30, 60)
        case 4...7:
            // First week: building up
            baseIntake = (150, 300)
        case 8...14:
            // Second week
            baseIntake = (300, 450)
        case 15...30:
            // First month
            baseIntake = (450, 600)
        case 31...60:
            // 1-2 months
            baseIntake = (500, 750)
        case 61...90:
            // 2-3 months
            baseIntake = (600, 900)
        case 91...180:
            // 3-6 months
            baseIntake = (750, 1050)
        case 181...365:
            // 6-12 months
            baseIntake = (600, 900)
        default:
            // Over 1 year
            baseIntake = (500, 750)
        }
        
        // Weight-based adjustment if available
        if let weightGrams = weight, days > 7 {
            let weightKg = Double(weightGrams) / 1000.0
            let weightBasedIntake = Int(weightKg * 150) // 150ml per kg
            
            // Blend age-based and weight-based recommendations
            let blendedMin = min(baseIntake.min, weightBasedIntake - 100)
            let blendedMax = max(baseIntake.max, weightBasedIntake + 100)
            
            return DailyIntakeGuide(
                typicalRange: (max(200, blendedMin), min(1200, blendedMax)),
                optimalTarget: weightBasedIntake
            )
        }
        
        return DailyIntakeGuide(
            typicalRange: baseIntake,
            optimalTarget: (baseIntake.min + baseIntake.max) / 2
        )
    }
    
    /// Calculates per-feed recommendation
    static func recommendedPerFeedAmount(for profile: BabyProfile?) -> FeedAmountGuide {
        guard let profile = profile else {
            return FeedAmountGuide(typicalRange: (60, 120), typicalCount: 8)
        }
        
        let days = profile.ageInDays
        let daily = recommendedDailyIntake(for: profile)
        
        // Typical feeds per day by age
        let feedsPerDay: Int
        switch days {
        case 0...7: feedsPerDay = 10
        case 8...30: feedsPerDay = 8
        case 31...60: feedsPerDay = 7
        case 61...120: feedsPerDay = 6
        case 121...180: feedsPerDay = 5
        default: feedsPerDay = 4
        }
        
        let avgFeed = daily.optimalTarget / feedsPerDay
        let minFeed = max(30, avgFeed - 30)
        let maxFeed = avgFeed + 40
        
        return FeedAmountGuide(
            typicalRange: (minFeed, maxFeed),
            typicalCount: feedsPerDay
        )
    }
    
    // MARK: - Contextual Guidance
    
    /// Provides contextual guidance message based on current progress
    static func contextualGuidance(
        currentAmount: Double,
        for profile: BabyProfile?
    ) -> String? {
        guard let profile = profile else { return nil }
        
        let guide = recommendedDailyIntake(for: profile)
        let percentage = (currentAmount / Double(guide.optimalTarget)) * 100
        let days = profile.ageInDays
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Morning guidance (before noon)
        if hour < 12 && percentage < 30 {
            return "Typical morning start: \(guide.typicalRange.min/4)–\(guide.typicalRange.max/4) ml"
        }
        
        // Progress-based guidance
        if percentage >= 80 && percentage < 100 {
            return "Almost there — you're doing great"
        } else if percentage >= 100 {
            return percentage > 120 ? "Well fed today — baby seems hungry!" : "Right on track for today"
        } else if percentage < 50 && hour > 18 {
            return "Evening top-up might help"
        }
        
        // Age-specific guidance
        if days <= 7 {
            return "Frequent small feeds are perfect right now"
        }
        
        return nil
    }
    
    // MARK: - Bottle Fill Level
    
    /// Calculates bottle fill percentage based on daily progress
    /// Caps at 85% to avoid "completion" anxiety
    static func bottleFillLevel(currentAmount: Double, for profile: BabyProfile?) -> CGFloat {
        guard let profile = profile else { return 0.3 }
        
        let guide = recommendedDailyIntake(for: profile)
        let target = Double(guide.optimalTarget)
        
        let rawPercentage = currentAmount / target
        let cappedPercentage = min(rawPercentage, 0.85)
        let displayFill = 0.1 + (cappedPercentage * 0.85)
        
        return CGFloat(min(displayFill, 0.9))
    }
    
    // MARK: - Smart Insights
    
    /// Generates intelligent insights from feeding history
    static func generateInsights(from feeds: [Feed], profile: BabyProfile?) -> [String] {
        guard !feeds.isEmpty, let profile = profile else { return [] }
        
        var insights: [String] = []
        let sortedFeeds = feeds.sorted { $0.startTime < $1.startTime }
        
        if let timeInsight = analyzeTimePattern(from: sortedFeeds) {
            insights.append(timeInsight)
        }
        
        if let trendInsight = analyzeTrend(from: sortedFeeds, profile: profile) {
            insights.append(trendInsight)
        }
        
        if let consistencyInsight = analyzeConsistency(from: sortedFeeds) {
            insights.append(consistencyInsight)
        }
        
        return insights.isEmpty ? ["You're building a beautiful routine"] : insights
    }
    
    // MARK: - Private Analysis Methods
    
    private static func analyzeTimePattern(from feeds: [Feed]) -> String? {
        guard feeds.count >= 5 else { return nil }
        
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        
        for feed in feeds {
            let hour = calendar.component(.hour, from: feed.startTime)
            hourCounts[hour, default: 0] += 1
        }
        
        let sortedHours = hourCounts.sorted { $0.value > $1.value }.prefix(2)
        
        if let peakHour = sortedHours.first {
            let timeOfDay: String
            switch peakHour.key {
            case 5...11: timeOfDay = "morning"
            case 12...16: timeOfDay = "afternoon"
            case 17...21: timeOfDay = "evening"
            default: timeOfDay = "night"
            }
            return "Most feeds happen in the \(timeOfDay)"
        }
        
        return nil
    }
    
    private static func analyzeTrend(from feeds: [Feed], profile: BabyProfile) -> String? {
        guard feeds.count >= 10 else { return nil }
        
        let calendar = Calendar.current
        var dailyTotals: [Date: Double] = [:]
        
        for feed in feeds {
            let day = calendar.startOfDay(for: feed.startTime)
            dailyTotals[day, default: 0] += feed.amount
        }
        
        let sortedDays = dailyTotals.keys.sorted()
        guard sortedDays.count >= 3 else { return nil }
        
        let recentDays = Array(sortedDays.suffix(3))
        let olderDays = Array(sortedDays.prefix(sortedDays.count - 3).suffix(3))
        
        let recentAvg = recentDays.compactMap { dailyTotals[$0] }.reduce(0, +) / Double(recentDays.count)
        let olderAvg = olderDays.compactMap { dailyTotals[$0] }.reduce(0, +) / Double(olderDays.count)
        
        if recentAvg > olderAvg * 1.15 {
            return "Average intake is increasing — great growth!"
        } else if abs(recentAvg - olderAvg) < olderAvg * 0.1 {
            return "Feeds are becoming more consistent"
        }
        
        return nil
    }
    
    private static func analyzeConsistency(from feeds: [Feed]) -> String? {
        guard feeds.count >= 7 else { return nil }
        
        let sortedFeeds = feeds.sorted { $0.startTime < $1.startTime }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedFeeds.count {
            let interval = sortedFeeds[i].startTime.timeIntervalSince(sortedFeeds[i-1].startTime)
            if interval > 300 && interval < 14400 {
                intervals.append(interval)
            }
        }
        
        guard intervals.count >= 5 else { return nil }
        
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.map { pow($0 - avgInterval, 2) }.reduce(0, +) / Double(intervals.count)
        let cv = sqrt(variance) / avgInterval
        
        if cv < 0.3 {
            let hours = Int(avgInterval / 3600)
            return "Beautiful \(hours)-hour rhythm emerging"
        }
        
        return nil
    }
}

// MARK: - Supporting Types

struct DailyIntakeGuide {
    let typicalRange: (min: Int, max: Int)
    let optimalTarget: Int
    
    var formattedRange: String {
        "\(typicalRange.min)–\(typicalRange.max) ml"
    }
}

struct FeedAmountGuide {
    let typicalRange: (min: Int, max: Int)
    let typicalCount: Int
    
    var formattedRange: String {
        "\(typicalRange.min)–\(typicalRange.max) ml"
    }
}

enum IntakeStatus {
    case low, normal, optimal, high, unknown
    
    var color: String {
        switch self {
        case .low: return "orange"
        case .normal, .optimal: return "emerald"
        case .high: return "blue"
        case .unknown: return "gray"
        }
    }
}

// MARK: - Reassurance Messages

struct ReassuranceMessages {
    static func forProgress(percentage: Double, profile: BabyProfile?) -> String {
        if percentage >= 100 {
            return ["You're right on track", "Perfect day of feeding", "Well done today"].randomElement()!
        } else if percentage >= 70 {
            return ["Almost there — you're doing great", "So close to target"].randomElement()!
        } else if percentage < 50 {
            return [
                "Frequent small feeds are completely normal",
                "Every baby has lighter days",
                "Trust your baby's appetite"
            ].randomElement()!
        }
        return ["You're doing great", "Every feed matters", "You're nourishing them well"].randomElement()!
    }
    
    static func afterFeed() -> String {
        ["Nice one", "That feed counts", "Keep it up", "Well done"].randomElement()!
    }
}
