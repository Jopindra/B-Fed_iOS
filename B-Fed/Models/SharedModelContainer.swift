import SwiftData

@MainActor
final class SharedModelContainer {
    static let shared: ModelContainer = create()

    static func create() -> ModelContainer {
        let schema = Schema([Feed.self, BabyProfile.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fallback to in-memory container - data won't persist but app won't crash
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // If even in-memory fails (should never happen with valid schema), the app cannot function
                preconditionFailure("Cannot create ModelContainer even with in-memory fallback: \(error)")
            }
        }
    }
}
