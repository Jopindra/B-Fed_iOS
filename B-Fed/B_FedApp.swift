import SwiftUI
import SwiftData
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        for window in windowScene.windows {
            window.backgroundColor = UIColor(Color.backgroundBase)
        }
    }
}

@main
struct B_FedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var feedStore = FeedStore()
    @State private var selectedFormulaStore = SelectedFormulaStore()
    @State private var showOnboarding: Bool
    
    init() {
        let isDemoMode = CommandLine.arguments.contains("--demo") || UserDefaults.standard.bool(forKey: "isDemoMode")
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        _showOnboarding = State(initialValue: !(hasCompleted || isDemoMode))
    }
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showOnboarding = false
                })
                .environment(feedStore)
                .environment(selectedFormulaStore)
                .ignoresSafeArea(.all)
            } else {
                ContentView()
                    .environment(feedStore)
                    .environment(selectedFormulaStore)
                    .onReceive(NotificationCenter.default.publisher(for: .returnToOnboarding)) { _ in
                        showOnboarding = true
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
