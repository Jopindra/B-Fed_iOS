import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingLogFeedSheet = false
    @State private var showingOnboarding = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(0)
            
            FeedHistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
                .tag(1)
        }
        .overlay(alignment: .bottom) {
            LogFeedButton {
                showingLogFeedSheet = true
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingLogFeedSheet) {
            LogFeedView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .onAppear {
            feedStore.setModelContext(modelContext)
            
            // Check if onboarding is needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !feedStore.hasCompletedOnboarding {
                    showingOnboarding = true
                }
            }
        }
    }
}

// MARK: - Log Feed Button
struct LogFeedButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.emerald)
                .clipShape(Circle())
                .shadow(color: Color.emerald.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 30)
    }
}

// MARK: - Color Extension
private extension Color {
    static var emerald: Color {
        Color(red: 0.18, green: 0.44, blue: 0.37)
    }
}

#Preview {
    ContentView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
