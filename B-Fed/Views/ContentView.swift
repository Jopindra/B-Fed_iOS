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
