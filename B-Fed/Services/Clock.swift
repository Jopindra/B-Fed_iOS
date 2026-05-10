import Foundation
import Combine

// MARK: - Clock Protocol
/// Abstracts time updates for testability.
protocol Clock {
    var currentTime: Date { get }
}

// MARK: - Live Clock
/// Returns the current system time on demand. No background timer.
final class LiveClock: Clock {
    var currentTime: Date { Date() }
}

// MARK: - Static Clock
/// Fixed time for testing and previews.
struct StaticClock: Clock {
    let currentTime: Date

    init(time: Date = Date()) {
        self.currentTime = time
    }
}
