import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingLogFeedSheet = false
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    FeedHistoryView()
                case 2:
                    InsightsView()
                default:
                    DashboardView()
                }
            }
            
            // Custom tab bar
            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
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
            countryCode: "AU",
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

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs: [(label: String, icon: String)] = [
        ("Today", "sun.max"),
        ("History", "clock"),
        ("Insights", "chart.line.uptrend.xyaxis")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 20, weight: .medium))
                            Text(tabs[index].label)
                                .font(AppFont.sans(10, weight: .semibold))
                            
                            // Active indicator capsule
                            Capsule()
                                .fill(Color.inkPrimary)
                                .frame(width: 20, height: 2.5)
                                .opacity(selectedTab == index ? 1 : 0)
                                .padding(.top, 4)
                        }
                        .foregroundStyle(
                            selectedTab == index
                                ? Color.inkPrimary
                                : Color.inkSecondary.opacity(0.6)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                }
            }
            .frame(height: 56)
            .background(Color.backgroundCard)
        }
    }
}

#Preview {
    ContentView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
