import Foundation
import Combine

// MARK: - Clock Protocol
/// Abstracts time updates for testability.
protocol Clock {
    var currentTime: Date { get }
}

// MARK: - Live Clock
/// Publishes time updates every second for live UI刷新.
@Observable
final class LiveClock: Clock {
    private(set) var currentTime = Date()
    private var timer: Timer?

    init(updateInterval: TimeInterval = 1.0) {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Static Clock
/// Fixed time for testing and previews.
struct StaticClock: Clock {
    let currentTime: Date

    init(time: Date = Date()) {
        self.currentTime = time
    }
}
