import XCTest
@testable import B_Fed

final class FeedStatisticsTests: XCTestCase {

    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }

    func makeFeed(amount: Double, startTime: Date, endTime: Date? = nil) -> Feed {
        Feed(startTime: startTime, endTime: endTime, amount: amount)
    }

    // MARK: - Empty Statistics

    func testEmptyStatistics() {
        let stats = FeedStatistics(feeds: [], dateRange: DateInterval(start: Date(), duration: 86400))
        XCTAssertEqual(stats.totalFeeds, 0)
        XCTAssertEqual(stats.totalAmount, 0)
        XCTAssertEqual(stats.averageAmount, 0)
        XCTAssertNil(stats.averageDuration)
        XCTAssertEqual(stats.averageDurationFormatted, "N/A")
        XCTAssertEqual(stats.feedsPerDay, 0)
        XCTAssertEqual(stats.maxFeedAmount, 0)
        XCTAssertEqual(stats.minFeedAmount, 0)
    }

    // MARK: - Total Feeds

    func testTotalFeeds() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 120, startTime: now),
            makeFeed(amount: 90, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.totalFeeds, 3)
    }

    // MARK: - Total Amount

    func testTotalAmount() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 150, startTime: now),
            makeFeed(amount: 50, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.totalAmount, 300)
    }

    // MARK: - Average Amount

    func testAverageAmount() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 200, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.averageAmount, 150)
    }

    // MARK: - Average Duration

    func testAverageDuration() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now, endTime: now.addingTimeInterval(600)),
            makeFeed(amount: 100, startTime: now, endTime: now.addingTimeInterval(900))
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.averageDuration, 750)
        XCTAssertEqual(stats.averageDurationFormatted, "12m 30s")
    }

    func testAverageDurationWithActiveFeed() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now, endTime: now.addingTimeInterval(600)),
            makeFeed(amount: 100, startTime: now) // active, no end time
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.averageDuration, 600)
    }

    func testAverageDurationAllActive() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 100, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertNil(stats.averageDuration)
    }

    // MARK: - Feeds Per Day

    func testFeedsPerDay() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 100, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.feedsPerDay, 2)
    }

    func testFeedsPerDayOverMultipleDays() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 100, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 172800)) // 2 days
        XCTAssertEqual(stats.feedsPerDay, 1)
    }

    // MARK: - Max / Min

    func testMaxFeedAmount() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 250, startTime: now),
            makeFeed(amount: 150, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.maxFeedAmount, 250)
    }

    func testMinFeedAmount() {
        let now = Date()
        let feeds = [
            makeFeed(amount: 100, startTime: now),
            makeFeed(amount: 250, startTime: now),
            makeFeed(amount: 150, startTime: now)
        ]
        let stats = FeedStatistics(feeds: feeds, dateRange: DateInterval(start: now, duration: 86400))
        XCTAssertEqual(stats.minFeedAmount, 100)
    }
}
