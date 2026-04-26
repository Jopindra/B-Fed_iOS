import Foundation

// MARK: - Feed Timer Service
/// Abstracts feed duration tracking for testability.
protocol FeedTimerService {
    var isRunning: Bool { get }
    var elapsed: TimeInterval { get }
    func start()
    func stop() -> TimeInterval
    func reset()
}

// MARK: - Live Feed Timer Service
/// Tracks elapsed time for an active feed using a repeating timer.
@Observable
final class LiveFeedTimerService: FeedTimerService {
    private(set) var isRunning = false
    private(set) var elapsed: TimeInterval = 0
    
    private var startTime: Date?
    private var accumulated: TimeInterval = 0
    private var timer: Timer?
    private let clock: Clock
    
    init(clock: Clock = LiveClock()) {
        self.clock = clock
    }
    
    func start() {
        guard !isRunning else { return }
        startTime = clock.currentTime
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() -> TimeInterval {
        guard isRunning else { return accumulated }
        timer?.invalidate()
        timer = nil
        
        if let startTime = startTime {
            accumulated += clock.currentTime.timeIntervalSince(startTime)
        }
        startTime = nil
        isRunning = false
        
        let total = accumulated
        accumulated = 0
        elapsed = 0
        return total
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        accumulated = 0
        elapsed = 0
        isRunning = false
    }
    
    private func tick() {
        guard let startTime = startTime else { return }
        elapsed = accumulated + clock.currentTime.timeIntervalSince(startTime)
    }
}

// MARK: - Static Feed Timer Service
/// Fixed-state timer for testing.
@Observable
final class StaticFeedTimerService: FeedTimerService {
    var isRunning = false
    var elapsed: TimeInterval = 0
    var fixedElapsed: TimeInterval = 0
    
    func start() {
        isRunning = true
    }
    
    func stop() -> TimeInterval {
        isRunning = false
        let total = fixedElapsed
        elapsed = 0
        return total
    }
    
    func reset() {
        isRunning = false
        elapsed = 0
    }
}
