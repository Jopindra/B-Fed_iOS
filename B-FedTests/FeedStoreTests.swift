import XCTest
import SwiftData
@testable import B_Fed

@MainActor
final class FeedStoreTests: XCTestCase {
    
    private var container: ModelContainer!
    private var context: ModelContext!
    private var store: FeedStore!
    private var clock: StaticClock!
    private var logger: SilentErrorLogger!
    
    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([Feed.self, BabyProfile.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        
        clock = StaticClock(time: Date())
        logger = SilentErrorLogger()
        store = FeedStore(clock: clock, logger: logger)
        store.setModelContext(context)
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
        store = nil
        clock = nil
        logger = nil
        try await super.tearDown()
    }
    
    // MARK: - Create Feed
    
    func testCreateFeed() {
        let feed = store.createFeed(amount: 120)
        
        XCTAssertEqual(feed.amount, 120)
        XCTAssertEqual(feed.unit, .milliliters)
        XCTAssertTrue(feed.completed)
        XCTAssertNotNil(feed.startTime)
    }
    
    func testCreateFeedWithCustomValues() {
        let start = Date().addingTimeInterval(-3600)
        let feed = store.createFeed(amount: 90, startTime: start, notes: "Good feed", completed: false)
        
        XCTAssertEqual(feed.amount, 90)
        XCTAssertEqual(feed.startTime, start)
        XCTAssertEqual(feed.notes, "Good feed")
        XCTAssertFalse(feed.completed)
    }
    
    func testCreateFeedPersistsToContext() {
        _ = store.createFeed(amount: 150)
        
        let descriptor = FetchDescriptor<Feed>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        let feeds = try! context.fetch(descriptor)
        
        XCTAssertEqual(feeds.count, 1)
        XCTAssertEqual(feeds.first?.amount, 150)
    }
    
    // MARK: - Delete Feed
    
    func testDeleteFeed() {
        let feed = store.createFeed(amount: 100)
        store.deleteFeed(feed)
        
        let descriptor = FetchDescriptor<Feed>()
        let feeds = try! context.fetch(descriptor)
        
        XCTAssertTrue(feeds.isEmpty)
    }
    
    func testDeleteFeedClearsActiveFeed() {
        let feed = store.createFeed(amount: 100)
        store.activeFeed = feed
        
        store.deleteFeed(feed)
        
        XCTAssertNil(store.activeFeed)
    }
    
    // MARK: - Update Feed
    
    func testUpdateFeed() {
        let feed = store.createFeed(amount: 100)
        let newStart = Date().addingTimeInterval(-7200)
        let newEnd = Date().addingTimeInterval(-3600)
        
        store.updateFeed(feed, amount: 150, startTime: newStart, endTime: newEnd, notes: "Updated")
        
        XCTAssertEqual(feed.amount, 150)
        XCTAssertEqual(feed.startTime, newStart)
        XCTAssertEqual(feed.endTime, newEnd)
        XCTAssertEqual(feed.notes, "Updated")
    }
    
    func testUpdateFeedCompletedStatus() {
        let feed = store.createFeed(amount: 100, completed: true)
        store.updateFeed(feed, amount: 100, startTime: feed.startTime, endTime: nil, notes: "", completed: false)
        
        XCTAssertFalse(feed.completed)
    }
    
    // MARK: - Fetch Feeds
    
    func testFetchFeedsForDate() {
        let today = clock.currentTime
        _ = store.createFeed(amount: 120, startTime: today)
        _ = store.createFeed(amount: 90, startTime: today.addingTimeInterval(-3600))
        _ = store.createFeed(amount: 60, startTime: today.addingTimeInterval(-86400))
        
        let feeds = store.fetchFeeds(for: today)
        
        XCTAssertEqual(feeds.count, 2)
    }
    
    func testFetchFeedsForDateReturnsEmptyWhenNoFeeds() {
        let feeds = store.fetchFeeds(for: clock.currentTime)
        XCTAssertTrue(feeds.isEmpty)
    }
    
    func testFetchAllFeeds() {
        _ = store.createFeed(amount: 100)
        _ = store.createFeed(amount: 120)
        
        let feeds = store.fetchAllFeeds()
        
        XCTAssertEqual(feeds.count, 2)
    }
    
    // MARK: - Statistics
    
    func testGetStatistics() {
        let today = clock.currentTime
        _ = store.createFeed(amount: 120, startTime: today)
        _ = store.createFeed(amount: 90, startTime: today.addingTimeInterval(-3600))
        
        let stats = store.getStatistics(for: today)
        
        XCTAssertEqual(stats.totalFeeds, 2)
        XCTAssertEqual(stats.totalAmount, 210)
        XCTAssertEqual(stats.averageAmount, 105)
    }
    
    func testGetStatisticsEmpty() {
        let stats = store.getStatistics(for: clock.currentTime)
        
        XCTAssertEqual(stats.totalFeeds, 0)
        XCTAssertEqual(stats.totalAmount, 0)
        XCTAssertEqual(stats.averageAmount, 0)
    }
    
    // MARK: - Baby Profile
    
    func testSaveBabyProfile() {
        let profile = BabyProfile(babyName: "Lily", feedingType: .formula)
        store.saveBabyProfile(profile)
        
        XCTAssertEqual(store.babyProfile?.babyName, "Lily")
        XCTAssertTrue(store.hasCompletedOnboarding)
    }
    
    func testLoadBabyProfile() {
        let profile = BabyProfile(babyName: "Lily", feedingType: .formula)
        store.saveBabyProfile(profile)
        
        let newStore = FeedStore(clock: clock, logger: logger)
        newStore.setModelContext(context)
        
        XCTAssertEqual(newStore.babyProfile?.babyName, "Lily")
    }
    
    // MARK: - Intelligence Methods
    
    func testGetBottleFillLevelWithNoProfile() {
        let level = store.getBottleFillLevel()
        // With no profile and no feeds, bottle shows base level (10%)
        XCTAssertEqual(level, 0.1, accuracy: 0.001)
    }
    
    func testGetIntakeDisplayWithNoProfile() {
        let display = store.getIntakeDisplay()
        XCTAssertFalse(display.isEmpty)
    }
    
    func testGetSupportingMessageWithNoProfile() {
        let message = store.getSupportingMessage()
        XCTAssertFalse(message.isEmpty)
    }
    
    func testGetContextualGuidanceWithNoProfile() {
        let guidance = store.getContextualGuidance()
        XCTAssertNil(guidance)
    }
    
    func testGetInsightsEmpty() {
        let insights = store.getInsights()
        XCTAssertTrue(insights.isEmpty)
    }
}
