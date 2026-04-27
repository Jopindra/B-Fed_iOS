import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingLogFeedSheet = false
    
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
            
            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(2)
        }
        .tabBarStyled()
        .overlay(alignment: .bottom) {
            LogFeedButton {
                showingLogFeedSheet = true
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingLogFeedSheet) {
            LogFeedView()
        }
        .onAppear {
            feedStore.setModelContext(modelContext)
            if CommandLine.arguments.contains("--demo") {
                populateDemoDataIfNeeded()
            }
        }
    }
    
    private func populateDemoDataIfNeeded() {
        guard feedStore.babyProfile == nil else { return }
        
        let profile = BabyProfile(
            parentName: "Sarah",
            parentEmail: "sarah@example.com",
            parentDOB: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
            country: "Australia",
            babyName: "Lily",
            dateOfBirth: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            birthWeight: 3400,
            currentWeight: 4200,
            feedingType: .formula,
            formulaBrand: "Aptamil",
            formulaStage: .stage1
        )
        feedStore.saveBabyProfile(profile)
        
        // Add some sample feeds for today
        let calendar = Calendar.current
        let now = Date()
        let feedTimes = [
            calendar.date(byAdding: .hour, value: -2, to: now)!,
            calendar.date(byAdding: .hour, value: -5, to: now)!,
            calendar.date(byAdding: .hour, value: -8, to: now)!
        ]
        let amounts = [120.0, 90.0, 150.0]
        let completeds = [true, false, true]
        
        for (index, time) in feedTimes.enumerated() {
            _ = feedStore.createFeed(amount: amounts[index], startTime: time, notes: "", completed: completeds[index])
        }
    }
}

// MARK: - Log Feed Button
struct LogFeedButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(AppFont.sans(24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.inkPrimary)
                .clipShape(Circle())
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, AppSpacing.xl)
    }
}



#Preview {
    ContentView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
