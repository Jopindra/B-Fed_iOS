import SwiftData

@MainActor
let sharedModelContainer: ModelContainer = {
    let schema = Schema([Feed.self, BabyProfile.self])
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .automatic
    )
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        // Fallback to in-memory storage so the app can still launch
        let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [fallbackConfig])
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }
}()
