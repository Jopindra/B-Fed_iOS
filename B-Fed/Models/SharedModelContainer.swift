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
        let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [fallbackConfig])
    }
}()
