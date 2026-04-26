import XCTest
@testable import B_Fed

final class FeedTests: XCTestCase {

    // MARK: - Initialization

    func testDefaultInitialization() {
        let feed = Feed(amount: 120)
        XCTAssertNotNil(feed.id)
        XCTAssertEqual(feed.amount, 120)
        XCTAssertEqual(feed.unit, .milliliters)
        XCTAssertEqual(feed.notes, "")
        XCTAssertNil(feed.endTime)
        XCTAssertNotNil(feed.createdAt)
    }

    func testCustomInitialization() {
        let start = Date()
        let end = Date().addingTimeInterval(600)
        let feed = Feed(
            startTime: start,
            endTime: end,
            amount: 150,
            unit: .ounces,
            notes: "Good feed"
        )
        XCTAssertEqual(feed.amount, 150)
        XCTAssertEqual(feed.unit, .ounces)
        XCTAssertEqual(feed.notes, "Good feed")
        XCTAssertEqual(feed.endTime, end)
    }

    // MARK: - Duration

    func testDurationWithEndTime() {
        let start = Date()
        let end = start.addingTimeInterval(600) // 10 minutes
        let feed = Feed(startTime: start, endTime: end, amount: 100)
        XCTAssertEqual(feed.duration, 600)
    }

    func testDurationWithoutEndTime() {
        let feed = Feed(amount: 100)
        XCTAssertNil(feed.duration)
    }

    // MARK: - Duration Formatting

    func testDurationInMinutesWithMinutesAndSeconds() {
        let start = Date()
        let end = start.addingTimeInterval(625) // 10 min 25 sec
        let feed = Feed(startTime: start, endTime: end, amount: 100)
        XCTAssertEqual(feed.durationInMinutes, "10m 25s")
    }

    func testDurationInMinutesWithSecondsOnly() {
        let start = Date()
        let end = start.addingTimeInterval(45)
        let feed = Feed(startTime: start, endTime: end, amount: 100)
        XCTAssertEqual(feed.durationInMinutes, "45s")
    }

    func testDurationInMinutesInProgress() {
        let feed = Feed(amount: 100)
        XCTAssertEqual(feed.durationInMinutes, "In progress")
    }

    // MARK: - Active State

    func testIsActiveTrue() {
        let feed = Feed(amount: 100)
        XCTAssertTrue(feed.isActive)
    }

    func testIsActiveFalse() {
        let feed = Feed(startTime: Date(), endTime: Date(), amount: 100)
        XCTAssertFalse(feed.isActive)
    }

    // MARK: - Formatted Amount

    func testFormattedAmountMilliliters() {
        let feed = Feed(amount: 125.5, unit: .milliliters)
        XCTAssertEqual(feed.formattedAmount, "125.5 ml")
    }

    func testFormattedAmountOunces() {
        let feed = Feed(amount: 4.0, unit: .ounces)
        XCTAssertEqual(feed.formattedAmount, "4.0 oz")
    }

    // MARK: - Feed Unit

    func testFeedUnitDisplayNames() {
        XCTAssertEqual(FeedUnit.milliliters.displayName, "Milliliters (ml)")
        XCTAssertEqual(FeedUnit.ounces.displayName, "Ounces (oz)")
    }

    func testFeedUnitShortNames() {
        XCTAssertEqual(FeedUnit.milliliters.shortName, "ml")
        XCTAssertEqual(FeedUnit.ounces.shortName, "oz")
    }

    func testFeedUnitAllCases() {
        XCTAssertEqual(FeedUnit.allCases.count, 2)
        XCTAssertTrue(FeedUnit.allCases.contains(.milliliters))
        XCTAssertTrue(FeedUnit.allCases.contains(.ounces))
    }

    func testFeedUnitRawValues() {
        XCTAssertEqual(FeedUnit.milliliters.rawValue, "ml")
        XCTAssertEqual(FeedUnit.ounces.rawValue, "oz")
    }

    // MARK: - Completion Status

    func testDefaultCompletedIsTrue() {
        let feed = Feed(amount: 120)
        XCTAssertTrue(feed.completed)
    }

    func testCompletedCanBeSetToFalse() {
        let feed = Feed(amount: 120, completed: false)
        XCTAssertFalse(feed.completed)
    }

    func testCompletedCanBeUpdated() {
        let feed = Feed(amount: 120)
        feed.completed = false
        XCTAssertFalse(feed.completed)
    }
}
