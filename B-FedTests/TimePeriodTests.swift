import XCTest
@testable import B_Fed

final class TimePeriodTests: XCTestCase {

    func testAllCases() {
        XCTAssertEqual(TimePeriod.allCases.count, 4)
        XCTAssertTrue(TimePeriod.allCases.contains(.today))
        XCTAssertTrue(TimePeriod.allCases.contains(.last7Days))
        XCTAssertTrue(TimePeriod.allCases.contains(.last30Days))
        XCTAssertTrue(TimePeriod.allCases.contains(.allTime))
    }

    func testRawValues() {
        XCTAssertEqual(TimePeriod.today.rawValue, "Today")
        XCTAssertEqual(TimePeriod.last7Days.rawValue, "Last 7 Days")
        XCTAssertEqual(TimePeriod.last30Days.rawValue, "Last 30 Days")
        XCTAssertEqual(TimePeriod.allTime.rawValue, "All Time")
    }

    func testTodayInterval() {
        let interval = TimePeriod.today.dateInterval
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        XCTAssertEqual(calendar.startOfDay(for: interval.start), startOfDay)
        XCTAssertLessThanOrEqual(interval.duration, 86400)
    }

    func testLast7DaysInterval() {
        let interval = TimePeriod.last7Days.dateInterval
        let calendar = Calendar.current
        let expectedStart = calendar.date(byAdding: .day, value: -7, to: Date())!
        XCTAssertLessThan(abs(interval.start.timeIntervalSince(expectedStart)), 2)
    }

    func testLast30DaysInterval() {
        let interval = TimePeriod.last30Days.dateInterval
        let calendar = Calendar.current
        let expectedStart = calendar.date(byAdding: .day, value: -30, to: Date())!
        XCTAssertLessThan(abs(interval.start.timeIntervalSince(expectedStart)), 2)
    }

    func testAllTimeInterval() {
        let interval = TimePeriod.allTime.dateInterval
        let calendar = Calendar.current
        let expectedStart = calendar.date(byAdding: .year, value: -10, to: Date())!
        XCTAssertLessThan(abs(interval.start.timeIntervalSince(expectedStart)), 2)
    }

    func testIntervalEndIsNow() {
        for period in TimePeriod.allCases {
            let interval = period.dateInterval
            XCTAssertLessThan(abs(interval.end.timeIntervalSince(Date())), 2)
        }
    }
}
