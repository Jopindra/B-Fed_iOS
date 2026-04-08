import SwiftUI
import SwiftData

struct FeedHistoryView: View {
    @Environment(FeedStore.self) private var feedStore
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    
    @State private var feedToEdit: Feed?
    @State private var showingDeleteConfirmation = false
    @State private var feedToDelete: Feed?
    
    private var groupedFeeds: [(String, [Feed])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: feeds) { feed in
            let date = calendar.startOfDay(for: feed.startTime)
            return formatDate(date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedFeeds, id: \.0) { dateString, dayFeeds in
                    Section {
                        ForEach(dayFeeds) { feed in
                            FeedHistoryRow(feed: feed)
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
                                    .tint(.indigo)
                                }
                        }
                    } header: {
                        HStack {
                            Text(dateString)
                                .font(.subheadline.weight(.semibold))
                                .textCase(nil)
                            
                            Spacer()
                            
                            Text("\(dayFeeds.count) feeds • \(Int(dayFeeds.reduce(0) { $0 + $1.amount }))ml")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - Feed History Row
struct FeedHistoryRow: View {
    let feed: Feed
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(feed.startTime, style: .time)
                    .font(.subheadline.weight(.semibold))
                
                if let endTime = feed.endTime {
                    Text(endTime, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 55)
            
            TimelineDot(isActive: feed.endTime == nil)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feed.formattedAmount)
                    .font(.subheadline.weight(.medium))
                
                HStack(spacing: 12) {
                    if let duration = feed.duration {
                        Label(feed.durationInMinutes, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !feed.notes.isEmpty {
                        Label("Note", systemImage: "text.alignleft")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Timeline Dot
struct TimelineDot: View {
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.accentColor : Color.green)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(isActive ? Color.accentColor.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 3)
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
    
    init(feed: Feed) {
        self.feed = feed
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        
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
                        if let _ = endTime {
                            DatePicker("End Time", selection: Binding(
                                get: { endTime ?? startTime },
                                set: { endTime = $0 }
                            ))
                        }
                        
                        HStack {
                            Text("Duration")
                            Spacer()
                            TextField("Minutes", text: $durationMinutes)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("min")
                                .foregroundStyle(.secondary)
                        }
                    }
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
                }
            }
            .navigationTitle("Edit Feed")
            .navigationBarTitleDisplayMode(.inline)
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
            notes: notes
        )
        
        dismiss()
    }
}

#Preview {
    FeedHistoryView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
