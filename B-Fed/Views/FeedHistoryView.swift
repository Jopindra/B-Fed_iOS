import SwiftUI
import SwiftData

struct FeedHistoryView: View {
    @Environment(FeedStore.self) private var feedStore
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    
    @State private var feedToEdit: Feed?
    @State private var showingDeleteConfirmation = false
    @State private var feedToDelete: Feed?
    
    private var groupedFeeds: [(String, [(String, [Feed])])] {
        let calendar = Calendar.current
        let dateGrouped = Dictionary(grouping: feeds) { feed in
            calendar.startOfDay(for: feed.startTime)
        }
        
        return dateGrouped.keys.sorted { $0 > $1 }.map { date in
            let dayFeeds = dateGrouped[date] ?? []
            let timeGrouped = groupByTimeOfDay(dayFeeds)
            return (formatDate(date), timeGrouped)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if feeds.isEmpty {
                    EmptyHistoryView()
                } else {
                    timelineList
                }
            }
            .navigationTitle("History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(item: $feedToEdit) { feed in
                EditFeedView(feed: feed)
            }
            .alert("Delete Feed?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let feed = feedToDelete {
                        feedStore.deleteFeed(feed)
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var timelineList: some View {
        List {
            ForEach(groupedFeeds, id: \.0) { dateString, timeGroups in
                Section {
                    ForEach(timeGroups, id: \.0) { timeLabel, groupFeeds in
                        TimeGroupSection(
                            timeLabel: timeLabel,
                            feeds: groupFeeds,
                            feedToEdit: $feedToEdit,
                            feedToDelete: $feedToDelete,
                            showingDeleteConfirmation: $showingDeleteConfirmation
                        )
                    }
                } header: {
                    DateSectionHeader(dateString: dateString, feedCount: timeGroups.flatMap { $0.1 }.count)
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }
    
    private func groupByTimeOfDay(_ feeds: [Feed]) -> [(String, [Feed])] {
        let calendar = Calendar.current
        let sorted = feeds.sorted { $0.startTime > $1.startTime }
        
        let grouped = Dictionary(grouping: sorted) { feed -> String in
            let hour = calendar.component(.hour, from: feed.startTime)
            switch hour {
            case 6..<12: return "Morning"
            case 12..<17: return "Afternoon"
            case 17..<21: return "Evening"
            default: return "Night"
            }
        }
        
        let order = ["Morning", "Afternoon", "Evening", "Night"]
        return order.compactMap { key in
            grouped[key].map { (key, $0) }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.weekday(.wide).month().day())
        }
    }
}

// MARK: - Empty History View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.almostAquaDark.opacity(0.08))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(AppFont.sans(40, weight: .light))
                    .foregroundStyle(Color.almostAquaDark.opacity(0.5))
            }
            
            Text("No feeds yet")
                .font(AppFont.serif(24))
                .foregroundStyle(Color.inkPrimary)
            
            Text("Your feeding timeline will appear here")
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xxl)
            
            Spacer()
        }
        .background(Color.backgroundBase)
    }
}

// MARK: - Date Section Header
struct DateSectionHeader: View {
    let dateString: String
    let feedCount: Int
    
    var body: some View {
        HStack {
            Text(dateString)
                .font(AppFont.sectionTitle)
                .textCase(nil)
            
            Spacer()
            
            Text("\(feedCount) feed\(feedCount == 1 ? "" : "s")")
                .font(AppFont.caption)
                .foregroundStyle(Color.inkSecondary)
        }
    }
}

// MARK: - Time Group Section
struct TimeGroupSection: View {
    let timeLabel: String
    let feeds: [Feed]
    @Binding var feedToEdit: Feed?
    @Binding var feedToDelete: Feed?
    @Binding var showingDeleteConfirmation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(timeLabel)
                .font(AppFont.sans(11, weight: .semibold))
                .foregroundStyle(Color.inkSecondary.opacity(0.7))
                .padding(.leading, 62)
                .padding(.bottom, AppSpacing.sm)
            
            ForEach(Array(feeds.enumerated()), id: \.element.id) { index, feed in
                let isLast = index == feeds.count - 1
                TimelineRow(
                    feed: feed,
                    isLast: isLast,
                    feedToEdit: $feedToEdit,
                    feedToDelete: $feedToDelete,
                    showingDeleteConfirmation: $showingDeleteConfirmation
                )
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Timeline Row
struct TimelineRow: View {
    let feed: Feed
    let isLast: Bool
    @Binding var feedToEdit: Feed?
    @Binding var feedToDelete: Feed?
    @Binding var showingDeleteConfirmation: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Time column
            VStack(alignment: .trailing, spacing: 2) {
                Text(feed.startTime, style: .time)
                    .font(AppFont.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let endTime = feed.endTime {
                    Text(endTime, style: .time)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary.opacity(0.6))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(width: 56)
            
            // Timeline connector
            TimelineConnector(
                isActive: feed.endTime == nil,
                isCompleted: feed.completed,
                isLast: isLast
            )
            .frame(width: 24)
            
            // Feed card
            FeedTimelineCard(feed: feed)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        feedToDelete = feed
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        feedToEdit = feed
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(Color.orchidTintDark)
                }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Timeline Connector
struct TimelineConnector: View {
    let isActive: Bool
    let isCompleted: Bool
    let isLast: Bool
    
    var body: some View {
        ZStack {
            // Vertical line
            if !isLast {
                Rectangle()
                    .fill(Color.inkSecondary.opacity(0.15))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            
            // Dot
            Circle()
                .fill(dotColor)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(dotColor.opacity(0.3), lineWidth: 3)
                )
        }
    }
    
    private var dotColor: Color {
        if isActive {
            return Color.peachDustDark
        } else if !isCompleted {
            return Color.peachDustDark.opacity(0.6)
        } else {
            return Color.almostAquaDark
        }
    }
}

// MARK: - Feed Timeline Card
struct FeedTimelineCard: View {
    let feed: Feed
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(feed.formattedAmount)
                    .font(AppFont.body)
                
                HStack(spacing: 12) {
                    if feed.duration != nil {
                        Label(feed.durationInMinutes, systemImage: "clock")
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    
                    if !feed.completed {
                        Label("Left some", systemImage: "minus.circle")
                            .font(AppFont.caption)
                            .foregroundStyle(Color.peachDustDark.opacity(0.9))
                    }
                    
                    if !feed.notes.isEmpty {
                        Label("Note", systemImage: "text.alignleft")
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
    }
}

// MARK: - Edit Feed View
struct EditFeedView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    let feed: Feed
    
    @State private var amount: String = ""
    @State private var selectedUnit: FeedUnit = .milliliters
    @State private var startTime: Date = Date()
    @State private var endTime: Date?
    @State private var notes: String = ""
    @State private var useDuration = false
    @State private var durationMinutes: String = ""
    @State private var completed: Bool = true
    
    init(feed: Feed) {
        self.feed = feed
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $amount)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(FeedUnit.allCases, id: \.self) { unit in
                                Text(unit.shortName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                }
                
                Section("Timing") {
                    DatePicker("Start Time", selection: $startTime)
                    
                    Toggle("Set End Time", isOn: $useDuration)
                    
                    if useDuration {
                        DatePicker("End Time", selection: Binding(
                            get: { endTime ?? startTime },
                            set: { endTime = $0 }
                        ))
                        
                        HStack {
                            Text("Duration")
                            Spacer()
                            TextField("Minutes", text: $durationMinutes)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("min")
                                .foregroundStyle(Color.inkSecondary)
                        }
                    }
                }
                
                Section("Completion") {
                    Toggle("Finished whole bottle", isOn: $completed)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .primaryButton()
                }
            }
            .navigationTitle("Edit Feed")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                amount = String(format: "%.1f", feed.amount)
                selectedUnit = feed.unit
                startTime = feed.startTime
                endTime = feed.endTime
                notes = feed.notes
                completed = feed.completed
                useDuration = feed.endTime != nil
                
                if let duration = feed.duration {
                    durationMinutes = String(Int(duration / 60))
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var newEndTime: Date? = endTime
        if useDuration, let duration = Int(durationMinutes), duration > 0 {
            newEndTime = startTime.addingTimeInterval(TimeInterval(duration * 60))
        } else if !useDuration {
            newEndTime = nil
        }
        
        feedStore.updateFeed(
            feed,
            amount: amountValue,
            startTime: startTime,
            endTime: newEndTime,
            notes: notes,
            completed: completed
        )
        
        dismiss()
    }
}

#Preview {
    FeedHistoryView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
