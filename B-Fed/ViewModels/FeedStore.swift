import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class FeedStore {
    private var modelContext: ModelContext?
    private let clock: Clock
    private let logger: ErrorLogger
    private let timerService: FeedTimerService

    var activeFeed: Feed?
    var timerElapsed: TimeInterval = 0
    var isTimerRunning: Bool = false
    private var observationTimer: Timer?

    /// Backward-compatible access to baby profile (views should migrate to ProfileStore)
    var babyProfile: BabyProfile? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<BabyProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor).first
        } catch {
            logger.log(error, context: "FeedStore.babyProfile")
            return nil
        }
    }

    var currentTime: Date { clock.currentTime }

    // MARK: - Initialization

    init(
        clock: Clock = LiveClock(),
        logger: ErrorLogger = PrintErrorLogger(),
        timerService: FeedTimerService = LiveFeedTimerService()
    ) {
        self.clock = clock
        self.logger = logger
        self.timerService = timerService
    }

    // MARK: - Setup

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Baby Profile (convenience for onboarding)

    func saveBabyProfile(_ profile: BabyProfile) {
        modelContext?.insert(profile)
        persist()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    // MARK: - CRUD Operations

    func createFeed(amount: Double, startTime: Date = Date(), notes: String = "", completed: Bool = true, duration: TimeInterval? = nil, consumedMl: Int? = nil) -> Feed {
        var endTime: Date? = nil
        if let duration = duration, duration > 0 {
            endTime = startTime.addingTimeInterval(duration)
        } else if timerService.isRunning {
            let duration = stopFeedTimer()
            if duration > 0 {
                endTime = startTime.addingTimeInterval(duration)
            }
        }

        let feed = Feed(
            startTime: startTime,
            endTime: endTime,
            amount: amount,
            consumedMl: consumedMl ?? Int(amount),
            unit: .milliliters,
            notes: notes,
            completed: completed
        )
        modelContext?.insert(feed)
        persist()
        syncWidgetData()
        return feed
    }

    func startFeedTimer() {
        timerService.start()
        isTimerRunning = true
        timerElapsed = 0
        startObservationTimer()
    }

    func stopFeedTimer() -> TimeInterval {
        let duration = timerService.stop()
        isTimerRunning = false
        timerElapsed = 0
        observationTimer?.invalidate()
        observationTimer = nil
        return duration
    }

    func resetFeedTimer() {
        timerService.reset()
        isTimerRunning = false
        timerElapsed = 0
        observationTimer?.invalidate()
        observationTimer = nil
    }

    func syncTimerState() {
        isTimerRunning = timerService.isRunning
        timerElapsed = timerService.elapsed
        if timerService.isRunning {
            startObservationTimer()
        }
    }

    func pauseTimerObservation() {
        observationTimer?.invalidate()
        observationTimer = nil
    }

    func resumeTimerObservation() {
        if timerService.isRunning {
            startObservationTimer()
        }
    }

    private func startObservationTimer() {
        observationTimer?.invalidate()
        observationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                let newElapsed = self.timerService.elapsed
                let newRunning = self.timerService.isRunning
                if self.timerElapsed != newElapsed {
                    self.timerElapsed = newElapsed
                }
                if self.isTimerRunning != newRunning {
                    self.isTimerRunning = newRunning
                }
            }
        }
    }

    func deleteFeed(_ feed: Feed) {
        if activeFeed?.id == feed.id {
            activeFeed = nil
        }
        modelContext?.delete(feed)
        persist()
        syncWidgetData()
    }

    func updateFeed(_ feed: Feed, amount: Double, startTime: Date, endTime: Date?, notes: String, completed: Bool? = nil, consumedMl: Int? = nil) {
        feed.amount = amount
        feed.startTime = startTime
        feed.endTime = endTime
        feed.notes = notes
        if let completed = completed {
            feed.completed = completed
        }
        if let consumedMl = consumedMl {
            feed.consumedMl = consumedMl
        }
        persist()
        syncWidgetData()
    }

    // MARK: - Profile Operations (kept for SettingsViewModel / Onboarding compatibility)

    func updateBabyProfile(
        babyName: String? = nil,
        feedingType: FeedingType? = nil,
        formulaBrand: String? = nil,
        formulaStage: FormulaStage? = nil,
        currentWeight: Double? = nil,
        weightUnit: String? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        dateOfBirth: Date? = nil,
        parentName: String? = nil
    ) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<BabyProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                if let babyName = babyName { profile.babyName = babyName }
                if let feedingType = feedingType { profile.feedingType = feedingType }
                if let formulaBrand = formulaBrand { profile.formulaBrand = formulaBrand }
                if let formulaStage = formulaStage { profile.formulaStage = formulaStage }
                if let currentWeight = currentWeight { profile.currentWeight = currentWeight }
                if let weightUnit = weightUnit { profile.weightUnit = weightUnit }
                if let country = country { profile.country = country }
                if let countryCode = countryCode {
                    if profile.countryCode != countryCode,
                       let currentBrand = profile.formulaBrand {
                        let brandsInNewCountry = FormulaGuidanceService.brands(forCountryCode: countryCode)
                        let isBrandValid = brandsInNewCountry.contains { $0.name == currentBrand }
                        if !isBrandValid {
                            profile.formulaBrand = nil
                            profile.formulaStage = nil
                            profile.selectedBrandId = nil
                            profile.selectedProductId = nil
                        }
                    }
                    profile.countryCode = countryCode
                }
                if let dateOfBirth = dateOfBirth { profile.dateOfBirth = dateOfBirth }
                if let parentName = parentName { profile.parentName = parentName }
                profile.updatedAt = Date()
                try context.save()
            }
        } catch {
            logger.log(error, context: "FeedStore.updateBabyProfile")
        }
    }

    func deleteAllData() {
        guard let context = modelContext else { return }

        Task {
            let feedDescriptor = FetchDescriptor<Feed>()
            let profileDescriptor = FetchDescriptor<BabyProfile>()

            do {
                let feeds = try context.fetch(feedDescriptor)
                feeds.forEach { context.delete($0) }

                let profiles = try context.fetch(profileDescriptor)
                profiles.forEach { context.delete($0) }

                try context.save()

                await MainActor.run {
                    self.activeFeed = nil
                    self.timerService.reset()
                    self.isTimerRunning = false
                    self.timerElapsed = 0
                    self.observationTimer?.invalidate()
                    self.observationTimer = nil
                    UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                    DismissedTipStore.reset()
                    NotificationCenter.default.post(name: .returnToOnboarding, object: nil)
                }
            } catch {
                await MainActor.run {
                    self.logger.log(error, context: "DeleteAllData")
                }
            }
        }
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

    // MARK: - Widget Sync

    private func syncWidgetData() {
        let today = clock.currentTime
        let stats = getStatistics(for: today)
        WidgetDataStore.update(
            feedCount: stats.totalFeeds,
            totalAmount: stats.totalAmount,
            babyName: "Baby"
        )
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
