import XCTest
@testable import B_Fed

// MARK: - Mock Clock
private final class MockClock: Clock {
    var currentTime: Date
    init(currentTime: Date) {
        self.currentTime = currentTime
    }
}

// MARK: - Static Feed Timer Service Tests
final class FeedTimerServiceTests: XCTestCase {
    
    private var timer: StaticFeedTimerService!
    
    override func setUp() {
        super.setUp()
        timer = StaticFeedTimerService()
    }
    
    override func tearDown() {
        timer = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testStart() {
        timer.start()
        XCTAssertTrue(timer.isRunning)
    }
    
    func testStopReturnsElapsed() {
        timer.fixedElapsed = 125
        timer.start()
        let result = timer.stop()
        XCTAssertEqual(result, 125)
        XCTAssertFalse(timer.isRunning)
    }
    
    func testStopWhenNotRunning() {
        let result = timer.stop()
        XCTAssertEqual(result, 0)
    }
    
    func testReset() {
        timer.fixedElapsed = 60
        timer.start()
        timer.reset()
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
}

// MARK: - Live Feed Timer Service Tests
final class LiveFeedTimerServiceTests: XCTestCase {
    
    private var clock: MockClock!
    private var timer: LiveFeedTimerService!
    private var defaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        clock = MockClock(currentTime: Date())
        defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        timer = LiveFeedTimerService(clock: clock, defaults: defaults)
    }
    
    override func tearDown() {
        timer.reset()
        // Clean up the isolated UserDefaults suite
        for key in ["feedTimer.startTime", "feedTimer.accumulated", "feedTimer.isRunning"] {
            defaults.removeObject(forKey: key)
        }
        timer = nil
        clock = nil
        defaults = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testStartSetsRunning() {
        timer.start()
        XCTAssertTrue(timer.isRunning)
    }
    
    func testDoubleStartIsNoOp() {
        timer.start()
        timer.start()
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testElapsedIncreasesWithTime() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        
        clock.currentTime = start.addingTimeInterval(5)
        timer.tick()
        
        XCTAssertEqual(timer.elapsed, 5, accuracy: 0.1)
    }
    
    func testStopReturnsAccumulatedTime() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        
        clock.currentTime = start.addingTimeInterval(10)
        let result = timer.stop()
        
        XCTAssertEqual(result, 10, accuracy: 0.1)
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testStopWhenNotRunningReturnsZero() {
        let result = timer.stop()
        XCTAssertEqual(result, 0)
    }
    
    func testResetClearsEverything() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        clock.currentTime = start.addingTimeInterval(5)
        timer.tick()
        
        timer.reset()
        
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testElapsedNeverGoesNegative() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        
        // Simulate clock going backwards
        clock.currentTime = start.addingTimeInterval(-5)
        timer.tick()
        
        XCTAssertEqual(timer.elapsed, 0)
    }
    
    func testPersistAndRestoreState() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        
        clock.currentTime = start.addingTimeInterval(30)
        timer.tick()
        
        // Create a new timer instance — should restore from UserDefaults
        let restoredTimer = LiveFeedTimerService(clock: clock, defaults: defaults)
        XCTAssertTrue(restoredTimer.isRunning)
        XCTAssertEqual(restoredTimer.elapsed, 30, accuracy: 0.1)
        
        restoredTimer.reset()
    }
    
    func testDoesNotRestoreExpiredState() {
        let start = Date()
        clock.currentTime = start
        timer.start()
        
        // Simulate 25 hours passing
        clock.currentTime = start.addingTimeInterval(90000)
        
        // Create a new timer instance — should NOT restore expired state
        let restoredTimer = LiveFeedTimerService(clock: clock, defaults: defaults)
        XCTAssertFalse(restoredTimer.isRunning)
        XCTAssertEqual(restoredTimer.elapsed, 0)
    }
    
    func testDoesNotRestoreFutureStartTime() {
        let start = Date().addingTimeInterval(3600) // 1 hour in the future
        clock.currentTime = start
        timer.start()
        
        // Clock goes back to now
        clock.currentTime = Date()
        
        let restoredTimer = LiveFeedTimerService(clock: clock, defaults: defaults)
        XCTAssertFalse(restoredTimer.isRunning)
        XCTAssertEqual(restoredTimer.elapsed, 0)
    }
}
