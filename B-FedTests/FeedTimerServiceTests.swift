import XCTest
@testable import B_Fed

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
