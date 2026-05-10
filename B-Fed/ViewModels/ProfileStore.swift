import SwiftData
import SwiftUI

@Observable
final class ProfileStore {
    private var modelContext: ModelContext?
    private let logger: ErrorLogger?

    init(logger: ErrorLogger? = nil) {
        self.logger = logger
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func fetchProfile() -> BabyProfile? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<BabyProfile>()
        do {
            let profiles = try context.fetch(descriptor)
            return profiles.first
        } catch {
            logger?.log(error, context: "ProfileStore.fetchProfile")
            return nil
        }
    }

    func updateProfile(weightInGrams: Int, feedingType: String) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<BabyProfile>()
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                profile.currentWeight = Double(weightInGrams)
                profile.feedingType = FeedingType(rawValue: feedingType) ?? .formula
                try context.save()
            }
        } catch {
            logger?.log(error, context: "ProfileStore.updateProfile")
        }
    }

    func babyAgeInDays() -> Int {
        guard let profile = fetchProfile() else { return 0 }
        return profile.ageInDays
    }

    func isBreastfeeding() -> Bool {
        guard let profile = fetchProfile() else { return false }
        return profile.feedingType == .breast
    }

    func deleteProfile() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<BabyProfile>()
        do {
            let profiles = try context.fetch(descriptor)
            for profile in profiles {
                context.delete(profile)
            }
            try context.save()
        } catch {
            logger?.log(error, context: "ProfileStore.deleteProfile")
        }
    }
}
