import ActivityKit

// MARK: - Feed Activity Attributes
/// Live Activity attributes for tracking an active feed.
struct FeedActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var amount: Double
    }
    
    var babyName: String
}
