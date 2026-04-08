import SwiftUI
import SwiftData

@main
struct B_FedApp: App {
    @State private var feedStore = FeedStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(feedStore)
        }
        .modelContainer(for: [Feed.self, BabyProfile.self])
    }
}
