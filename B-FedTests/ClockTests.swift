import XCTest
@testable import B_Fed

final class ClockTests: XCTestCase {

    func testStaticClockReturnsFixedTime() {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let clock = StaticClock(time: fixedDate)
        XCTAssertEqual(clock.currentTime, fixedDate)
    }

    func testStaticClockDefaultTime() {
        let before = Date()
        let clock = StaticClock()
        let after = Date()
        XCTAssertGreaterThanOrEqual(clock.currentTime, before)
        XCTAssertLessThanOrEqual(clock.currentTime, after)
    }
}
