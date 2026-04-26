import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class FeedStore {
    private var modelContext: ModelContext?
    private let clock: Clock
    private let logger: ErrorLogger

    var activeFeed: Feed?
    var babyProfile: BabyProfile?

    var currentTime: Date { clock.currentTime }

    // MARK: - Intelligence

    var dailyGuide: DailyGuide {
        FeedingIntelligence.dailyIntakeGuide(for: babyProfile)
    }

    var perFeedGuide: PerFeedGuide {
        FeedingIntelligence.perFeedGuide(for: babyProfile)
    }

    // MARK: - Initialization

    init(clock: Clock = LiveClock(), logger: ErrorLogger = PrintErrorLogger()) {
        self.clock = clock
        self.logger = logger
    }

    // MARK: - Setup

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadBabyProfile()
    }

    // MARK: - Baby Profile

    private func loadBabyProfile() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<BabyProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let profiles = try context.fetch(descriptor)
            babyProfile = profiles.first
        } catch {
            logger.log(error, context: "LoadProfile")
        }
    }

    func saveBabyProfile(_ profile: BabyProfile) {
        modelContext?.insert(profile)
        persist()
        babyProfile = profile
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    var hasCompletedOnboarding: Bool {
        babyProfile != nil
    }

    // MARK: - CRUD Operations

    func createFeed(amount: Double, startTime: Date = Date(), notes: String = "", completed: Bool = true) -> Feed {
        let feed = Feed(
            startTime: startTime,
            amount: amount,
            unit: .milliliters,
            notes: notes,
            completed: completed
        )
        modelContext?.insert(feed)
        persist()
        return feed
    }

    func deleteFeed(_ feed: Feed) {
        if activeFeed?.id == feed.id {
            activeFeed = nil
        }
        modelContext?.delete(feed)
        persist()
    }

    func updateFeed(_ feed: Feed, amount: Double, startTime: Date, endTime: Date?, notes: String, completed: Bool? = nil) {
        feed.amount = amount
        feed.startTime = startTime
        feed.endTime = endTime
        feed.notes = notes
        if let completed = completed {
            feed.completed = completed
        }
        persist()
    }

    // MARK: - Fetch Operations

    func fetchFeeds(for date: Date) -> [Feed] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let descriptor = FetchDescriptor<Feed>(
            predicate: #Predicate {
                $0.startTime >= startOfDay && $0.startTime < endOfDay
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            logger.log(error, context: "FetchFeeds")
            return []
        }
    }

    func fetchAllFeeds() -> [Feed] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Feed>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            logger.log(error, context: "FetchAllFeeds")
            return []
        }
    }

    // MARK: - Statistics

    func getStatistics(for date: Date) -> FeedStatistics {
        let feeds = fetchFeeds(for: date)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        return FeedStatistics(
            feeds: feeds,
            dateRange: DateInterval(start: startOfDay, end: endOfDay)
        )
    }

    func getStatistics(from startDate: Date, to endDate: Date) -> FeedStatistics {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate

        let descriptor = FetchDescriptor<Feed>(
            predicate: #Predicate {
                $0.startTime >= startOfDay && $0.startTime < endOfDay
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )

        var feeds: [Feed] = []
        do {
            feeds = try modelContext?.fetch(descriptor) ?? []
        } catch {
            logger.log(error, context: "FetchStatistics")
        }

        return FeedStatistics(
            feeds: feeds,
            dateRange: DateInterval(start: startOfDay, end: endOfDay)
        )
    }

    // MARK: - Intelligence Methods

    func getBottleFillLevel(for date: Date = Date()) -> CGFloat {
        let stats = getStatistics(for: date)
        return FeedingIntelligence.bottleFillLevel(
            current: stats.totalAmount,
            profile: babyProfile
        )
    }

    func getIntakeDisplay(for date: Date = Date()) -> String {
        let stats = getStatistics(for: date)
        return FeedingIntelligence.intakeDisplay(
            current: stats.totalAmount,
            profile: babyProfile
        )
    }

    func getSupportingMessage(for date: Date = Date()) -> String {
        let stats = getStatistics(for: date)
        return FeedingIntelligence.supportingMessage(
            current: stats.totalAmount,
            profile: babyProfile
        )
    }

    func getContextualGuidance(for date: Date = Date()) -> String? {
        let stats = getStatistics(for: date)
        return FeedingIntelligence.contextualGuidance(
            current: stats.totalAmount,
            profile: babyProfile
        )
    }

    func getInsights() -> [String] {
        let feeds = fetchAllFeeds()
        return FeedingIntelligence.insights(from: feeds, profile: babyProfile)
    }

    // MARK: - Persistence

    private func persist() {
        do {
            try modelContext?.save()
        } catch {
            logger.log(error, context: "Save")
        }
    }
}
