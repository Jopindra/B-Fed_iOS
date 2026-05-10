import SwiftUI
import SwiftData

@main
struct B_Fed_Watch_App: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
