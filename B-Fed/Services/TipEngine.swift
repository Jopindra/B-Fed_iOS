import Foundation

// MARK: - Tip
struct Tip: Identifiable, Hashable {
    let id: String
    let text: String
    let category: TipCategory
}

enum TipCategory: String, CaseIterable {
    case reassurance
    case practical
    case night
    case formula
    case newborn
}

// MARK: - Tip Engine
/// Generates gentle, contextual tips based on baby profile and feeding patterns.
/// Anti-gamification: no streaks, no guilt, no pressure.
enum TipEngine {
    
    static func tips(for profile: BabyProfile?, feeds: [Feed]) -> [Tip] {
        var tips: [Tip] = []
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        // New parent tips (first 7 days)
        if let age = profile?.ageInDays, age < 7 {
            tips.append(Tip(
                id: "newborn-cluster",
                text: "Cluster feeding is normal in the first week — baby is building your supply and bonding.",
                category: .newborn
            ))
        }
        
        // Night feeding tips
        if hour >= 22 || hour < 6 {
            tips.append(Tip(
                id: "night-dim",
                text: "Keep lights dim during night feeds — it helps baby (and you) drift back to sleep.",
                category: .night
            ))
        }
        
        // Formula-specific tips
        if let type = profile?.feedingType, type == .formula || type == .mixed {
            tips.append(Tip(
                id: "formula-prep",
                text: "Prepared formula keeps for 2 hours at room temp, or 24 hours in the fridge.",
                category: .formula
            ))
        }
        
        // Low intake reassurance
        let todayFeeds = feeds.filter { calendar.isDateInToday($0.startTime) }
        let totalToday = todayFeeds.reduce(0) { $0 + $1.amount }
        if totalToday > 0 && totalToday < 400 {
            tips.append(Tip(
                id: "low-intake-okay",
                text: "Some days are lighter than others. Trust your baby — they know what they need.",
                category: .reassurance
            ))
        }
        
        // Partial feed tip
        let partialFeeds = todayFeeds.filter { !$0.completed }
        if partialFeeds.count >= 2 {
            tips.append(Tip(
                id: "partial-normal",
                text: "Leaving milk behind is common. Try offering the rest in 30 minutes if baby seems hungry.",
                category: .practical
            ))
        }
        
        // Growth spurt tip (around 3, 6 weeks)
        if let age = profile?.ageInWeeks, age == 3 || age == 6 {
            tips.append(Tip(
                id: "growth-spurt",
                text: "Around \(age) weeks, babies often feed more frequently. It usually passes in a few days.",
                category: .reassurance
            ))
        }
        
        // General reassurance if very few tips
        if tips.isEmpty {
            tips.append(Tip(
                id: "doing-great",
                text: "You're doing great. Every feed, cuddle, and moment of patience matters.",
                category: .reassurance
            ))
        }
        
        return Array(tips.prefix(2))
    }
}

// MARK: - Dismissed Tip Store
/// Simple UserDefaults-backed store for dismissed tip IDs.
enum DismissedTipStore {
    private static let key = "dismissed-tip-ids"
    private static let dateKey = "dismissed-tip-dates"
    
    static func isDismissed(_ tipId: String) -> Bool {
        guard let dates = UserDefaults.standard.dictionary(forKey: dateKey) as? [String: TimeInterval] else {
            return false
        }
        guard let dismissedAt = dates[tipId] else { return false }
        // Tips reappear after 7 days
        return Date().timeIntervalSince1970 - dismissedAt < 604_800
    }
    
    static func dismiss(_ tipId: String) {
        var dates = UserDefaults.standard.dictionary(forKey: dateKey) as? [String: TimeInterval] ?? [:]
        dates[tipId] = Date().timeIntervalSince1970
        UserDefaults.standard.set(dates, forKey: dateKey)
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: dateKey)
    }
}
