import SwiftUI
import SwiftData

@main
struct B_FedApp: App {
    @State private var feedStore = FeedStore()
    @State private var showOnboarding: Bool
    
    init() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        _showOnboarding = State(initialValue: !hasCompleted)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(onComplete: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        showOnboarding = false
                    })
                    .environment(feedStore)
                } else {
                    ContentView()
                        .environment(feedStore)
                }
            }
        }
        .modelContainer(for: [Feed.self, BabyProfile.self])
    }
}
