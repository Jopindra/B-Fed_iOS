import Foundation

// MARK: - Widget Data Store
/// Syncs key metrics to shared UserDefaults for widget access.
enum WidgetDataStore {
    private static let suiteName = "group.com.bfed.B-Fed"
    
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    static func update(feedCount: Int, totalAmount: Double, babyName: String) {
        guard let defaults = defaults else { return }
        defaults.set(feedCount, forKey: "widget-feed-count")
        defaults.set(totalAmount, forKey: "widget-total-amount")
        defaults.set(babyName, forKey: "widget-baby-name")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget-last-updated")
    }
    
    static func feedCount() -> Int {
        defaults?.integer(forKey: "widget-feed-count") ?? 0
    }
    
    static func totalAmount() -> Double {
        defaults?.double(forKey: "widget-total-amount") ?? 0
    }
    
    static func babyName() -> String {
        defaults?.string(forKey: "widget-baby-name") ?? "Baby"
    }
    
    static func lastUpdated() -> Date {
        let timestamp = defaults?.double(forKey: "widget-last-updated") ?? 0
        return Date(timeIntervalSince1970: timestamp)
    }
}
