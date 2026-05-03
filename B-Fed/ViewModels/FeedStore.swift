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
    var babyProfile: BabyProfile?
    var timerElapsed: TimeInterval = 0
    var isTimerRunning: Bool = false
    private var observationTimer: Timer?

    var currentTime: Date { clock.currentTime }

    // MARK: - Intelligence

    var dailyGuide: DailyGuide {
        FeedingIntelligence.dailyIntakeGuide(for: babyProfile)
    }

    var perFeedGuide: PerFeedGuide {
        FeedingIntelligence.perFeedGuide(for: babyProfile)
    }

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
    
    func updateBabyProfile(
        babyName: String? = nil,
        feedingType: FeedingType? = nil,
        formulaBrand: String? = nil,
        formulaStage: FormulaStage? = nil,
        currentWeight: Double? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        dateOfBirth: Date? = nil,
        parentName: String? = nil,
        parentEmail: String? = nil
    ) {
        guard let profile = babyProfile else { return }
        
        if let babyName = babyName { profile.babyName = babyName }
        if let feedingType = feedingType { profile.feedingType = feedingType }
        if let formulaBrand = formulaBrand { profile.formulaBrand = formulaBrand }
        if let formulaStage = formulaStage { profile.formulaStage = formulaStage }
        if let currentWeight = currentWeight { profile.currentWeight = currentWeight }
        if let country = country { profile.country = country }
        if let countryCode = countryCode {
            // If country changed, reset formula brand if not available in new country
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
        if let parentEmail = parentEmail { profile.parentEmail = parentEmail }
        
        profile.updatedAt = Date()
        persist()
    }
    
    func deleteAllData() {
        guard let context = modelContext else { return }
        
        let feedDescriptor = FetchDescriptor<Feed>()
        let profileDescriptor = FetchDescriptor<BabyProfile>()
        
        do {
            let feeds = try context.fetch(feedDescriptor)
            feeds.forEach { context.delete($0) }
            
            let profiles = try context.fetch(profileDescriptor)
            profiles.forEach { context.delete($0) }
            
            persist()
            babyProfile = nil
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            DismissedTipStore.reset()
        } catch {
            logger.log(error, context: "DeleteAllData")
        }
    }

    var hasCompletedOnboarding: Bool {
        babyProfile != nil
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
            consumedMl: consumedMl,
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

    private func startObservationTimer() {
        observationTimer?.invalidate()
        observationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.timerElapsed = self.timerService.elapsed
                self.isTimerRunning = self.timerService.isRunning
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

    // MARK: - Widget Sync

    private func syncWidgetData() {
        let today = clock.currentTime
        let stats = getStatistics(for: today)
        WidgetDataStore.update(
            feedCount: stats.totalFeeds,
            totalAmount: stats.totalAmount,
            babyName: babyProfile?.babyName ?? "Baby"
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
