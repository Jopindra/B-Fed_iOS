import SwiftUI
import SwiftData

struct WatchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    @Query(sort: \BabyProfile.createdAt, order: .reverse) private var profiles: [BabyProfile]
    
    @State private var showingLogFeed = false
    
    private var profile: BabyProfile? {
        profiles.first
    }
    
    private var todayFeeds: [Feed] {
        let calendar = Calendar.current
        return feeds.filter { calendar.isDateInToday($0.startTime) }
    }
    
    private var totalAmount: Double {
        todayFeeds.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if let profile = profile {
                        Text(profile.babyName)
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundStyle(.primary)
                    }
                    
                    // Today's summary
                    VStack(spacing: 4) {
                        Text("\(Int(totalAmount))")
                            .font(.system(size: 36, weight: .medium, design: .serif))
                            .foregroundStyle(.primary)
                        Text("ml today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(todayFeeds.count) feeds")
                            .font(.caption2)
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    .padding(.vertical, 8)
                    
                    // Quick log button
                    Button {
                        showingLogFeed = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Log Feed")
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.35, green: 0.65, blue: 0.65))
                    
                    // Recent feeds
                    if !todayFeeds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ForEach(todayFeeds.prefix(3)) { feed in
                                HStack {
                                    Text(feed.startTime, style: .time)
                                        .font(.system(size: 14, weight: .medium))
                                    Spacer()
                                    Text("\(Int(feed.amount)) ml")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("B-Fed")
        }
        .sheet(isPresented: $showingLogFeed) {
            WatchLogFeedView()
        }
    }
}

struct WatchLogFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: Double = 90
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("\(Int(amount)) ml")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                
                Slider(value: $amount, in: 30...240, step: 5)
                
                Button("Save") {
                    saveFeed()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.35, green: 0.65, blue: 0.65))
            }
            .padding()
            .navigationTitle("Log Feed")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveFeed() {
        let feed = Feed(amount: amount)
        modelContext.insert(feed)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    WatchContentView()
        .modelContainer(for: [Feed.self, BabyProfile.self], inMemory: true)
}
