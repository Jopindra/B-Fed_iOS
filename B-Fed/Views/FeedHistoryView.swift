import SwiftUI
import SwiftData

// MARK: - Feed History View
struct FeedHistoryView: View {
    @Environment(FeedStore.self) private var feedStore
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    
    @State private var feedToEdit: Feed?
    @State private var showingDeleteConfirmation = false
    @State private var feedToDelete: Feed?
    
    private var babyName: String {
        feedStore.babyProfile?.babyName ?? "Baby"
    }
    
    private var groupedDays: [DayGroup] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: feeds) { calendar.startOfDay(for: $0.startTime) }
        let sortedDays = byDay.keys.sorted { $0 > $1 }
        return sortedDays.map { date in
            let dayFeeds = byDay[date] ?? []
            let total = dayFeeds.reduce(0) { $0 + Int($1.consumedMl ?? Int($1.amount)) }
            return DayGroup(
                date: date,
                feeds: dayFeeds.sorted { $0.startTime > $1.startTime },
                totalMl: total
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F7F6F2").ignoresSafeArea()
            
            historyBlobs
            
            Group {
                if feeds.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            header
                                .padding(.top, 20)
                            
                            dayList
                                .padding(.top, 24)
                            
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(item: $feedToEdit) { feed in
            EditFeedSheet(feed: feed)
        }
        .alert("Delete this feed?", isPresented: $showingDeleteConfirmation) {
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
    
    // MARK: — Blobs
    
    private var historyBlobs: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.38))
                .frame(width: 160, height: 160)
                .position(x: UIScreen.main.bounds.width + 50, y: -40)
            
            Circle()
                .fill(Color(hex: "C8C0D4").opacity(0.32))
                .frame(width: 130, height: 130)
                .position(x: UIScreen.main.bounds.width + 50, y: 120)
            
            Circle()
                .fill(Color(hex: "B0C4B0").opacity(0.35))
                .frame(width: 180, height: 180)
                .position(x: -50, y: UIScreen.main.bounds.height + 40)
            
            Circle()
                .fill(Color(hex: "D4A898").opacity(0.30))
                .frame(width: 110, height: 110)
                .position(x: UIScreen.main.bounds.width + 40, y: UIScreen.main.bounds.height - 80)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("History")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color(hex: "1C2421"))
            
            Text("\(babyName) · all feeds")
                .font(AppFont.sans(13))
                .foregroundColor(Color(hex: "888780"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Empty state
    
    private var emptyState: some View {
        Text("No feeds logged yet")
            .font(AppFont.sans(13))
            .foregroundColor(Color(hex: "888780"))
            .italic()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: — Day list
    
    private var dayList: some View {
        VStack(spacing: 24) {
            ForEach(groupedDays) { group in
                DaySection(group: group, onTapFeed: { feed in
                    feedToEdit = feed
                }, onDeleteFeed: { feed in
                    feedToDelete = feed
                    showingDeleteConfirmation = true
                })
            }
        }
    }
}

// MARK: - Day Group Model
private struct DayGroup: Identifiable {
    let id = UUID()
    let date: Date
    let feeds: [Feed]
    let totalMl: Int
}

// MARK: - Day Section
private struct DaySection: View {
    let group: DayGroup
    let onTapFeed: (Feed) -> Void
    let onDeleteFeed: (Feed) -> Void
    
    private var dayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(group.date) {
            return "Today"
        } else if calendar.isDateInYesterday(group.date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE d MMM"
            return formatter.string(from: group.date)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header
            HStack {
                Text(dayLabel)
                    .font(AppFont.sans(10, weight: .semibold))
                    .foregroundColor(Color(hex: "1C2421"))
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("\(group.feeds.count) feed\(group.feeds.count == 1 ? "" : "s") · \(group.totalMl) ml")
                    .font(AppFont.sans(11))
                    .foregroundColor(Color(hex: "888780"))
            }
            .padding(.bottom, 10)
            
            // Day card
            VStack(spacing: 0) {
                ForEach(Array(group.feeds.enumerated()), id: \.element.id) { index, feed in
                    FeedRow(
                        feed: feed,
                        onTap: { onTapFeed(feed) }
                    )
                    
                    if index < group.feeds.count - 1 {
                        Divider()
                            .background(Color.black.opacity(0.05))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Feed Row
private struct FeedRow: View {
    let feed: Feed
    let onTap: () -> Void
    
    private var isPartial: Bool {
        let prepared = Int(feed.amount)
        let consumed = feed.consumedMl ?? prepared
        return consumed < prepared
    }
    
    private var statusColor: Color {
        isPartial ? Color(hex: "C8C0D4") : Color(hex: "7B6A9A")
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: feed.startTime).lowercased()
    }
    
    private var periodLabel: String {
        let hour = Calendar.current.component(.hour, from: feed.startTime)
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }
    
    private var formulaInfo: String {
        let brand = feedStore.babyProfile?.customFormulaBrand ?? feedStore.babyProfile?.formulaBrand ?? "Formula"
        let status = isPartial ? "left some" : "finished"
        return "\(brand) · \(status)"
    }
    
    @Environment(FeedStore.self) private var feedStore
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status dot
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                // Details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(Int(feed.amount)) ml")
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundColor(Color(hex: "1C2421"))
                        
                        if isPartial, let consumed = feed.consumedMl {
                            Text("· \(consumed) ml consumed")
                                .font(AppFont.sans(11, weight: .regular))
                                .foregroundColor(Color(hex: "B07850"))
                        }
                    }
                    
                    Text(formulaInfo)
                        .font(AppFont.sans(12))
                        .foregroundColor(Color(hex: "888780"))
                }
                
                Spacer()
                
                // Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeString)
                        .font(AppFont.sans(13))
                        .foregroundColor(Color(hex: "888780"))
                    
                    Text(periodLabel)
                        .font(AppFont.sans(11))
                        .foregroundColor(Color(hex: "B4B2A9"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Feed Sheet
struct EditFeedSheet: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(SelectedFormulaStore.self) private var formulaStore
    @Environment(\.dismiss) private var dismiss
    
    let feed: Feed
    
    @State private var amount: Double = 0
    @State private var consumedMl: Int? = nil
    @State private var feedTime: Date = Date()
    @State private var isTimeManuallySet: Bool = false
    @State private var showingTimePicker: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: feedTime)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCard.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Handle
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                                .frame(width: 32, height: 4)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 10)
                            
                            // Title
                            Text("Edit feed")
                                .font(AppFont.screenTitle)
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            // Formula section
                            sectionLabel("FORMULA")
                                .padding(.top, 8)
                            
                            formulaRow
                                .padding(.horizontal, 20)
                            
                            // Amount section
                            sectionLabel("AMOUNT")
                                .padding(.top, 12)
                            
                            amountStepperCard
                                .padding(.horizontal, 20)
                            
                            // Consumed section
                            sectionLabel("CONSUMED")
                                .padding(.top, 12)
                            
                            consumedStepperCard
                                .padding(.horizontal, 20)
                            
                            // Time section
                            sectionLabel("TIME")
                                .padding(.top, 12)
                            
                            timeField
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                        }
                    }
                    
                    VStack(spacing: 8) {
                        saveButton
                        deleteButton
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(20)
        .presentationBackground(.white)
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $feedTime)
        }
        .alert("Delete this feed?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                feedStore.deleteFeed(feed)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            amount = feed.amount
            consumedMl = feed.consumedMl
            feedTime = feed.startTime
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.label)
            .foregroundStyle(Color.inkSecondary)
            .tracking(0.3)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
    }
    
    private var formulaRow: some View {
        let brand = feedStore.babyProfile?.customFormulaBrand ?? feedStore.babyProfile?.formulaBrand ?? "Formula"
        return HStack(spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.almostAquaLight)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(brand.prefix(1)).uppercased())
                            .font(AppFont.sans(12, weight: .semibold))
                            .foregroundStyle(Color.almostAquaDark)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(brand)
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Color(hex: "1C2421"))
                    
                    Text("Your current formula")
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color(hex: "888780"))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.backgroundBase)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                )
        )
    }
    
    private var amountStepperCard: some View {
        HStack {
            Button(action: { amount = max(0, amount - 10) }) {
                Text("−")
                    .font(AppFont.lead)
                    .foregroundStyle(Color.inkPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.backgroundCard))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("\(Int(amount))")
                    .font(AppFont.serif(32))
                    .foregroundStyle(Color.inkPrimary)
                    .monospacedDigit()
                
                Text("ml")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            Spacer()
            
            Button(action: { amount = min(350, amount + 10) }) {
                Text("+")
                    .font(AppFont.lead)
                    .foregroundStyle(Color.inkPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.backgroundCard))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.backgroundBase)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                )
        )
    }
    
    private var consumedStepperCard: some View {
        let current = consumedMl ?? Int(amount)
        return HStack {
            Button(action: { consumedMl = max(0, current - 10) }) {
                Text("−")
                    .font(AppFont.lead)
                    .foregroundStyle(Color.inkPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.backgroundCard))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("\(current)")
                    .font(AppFont.serif(32))
                    .foregroundStyle(Color.inkPrimary)
                    .monospacedDigit()
                
                Text("ml")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            Spacer()
            
            Button(action: { consumedMl = min(Int(amount), current + 10) }) {
                Text("+")
                    .font(AppFont.lead)
                    .foregroundStyle(Color.inkPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.backgroundCard))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.backgroundBase)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                )
        )
    }
    
    private var timeField: some View {
        HStack(spacing: 12) {
            Button(action: {
                isTimeManuallySet = true
                showingTimePicker = true
            }) {
                HStack {
                    Text(timeString)
                        .font(AppFont.sans(15, weight: .regular))
                        .foregroundStyle(Color.inkPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(12, weight: .medium))
                        .foregroundStyle(Color.inkSecondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.backgroundBase)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var saveButton: some View {
        Button(action: saveChanges) {
            Text("Save changes")
                .font(AppFont.button)
                .foregroundStyle(Color.backgroundCard)
                .frame(maxWidth: .infinity)
                .frame(height: AppMetrics.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.inkPrimary)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    private var deleteButton: some View {
        Button(action: { showingDeleteConfirmation = true }) {
            Text("Delete feed")
                .font(AppFont.sans(14, weight: .medium))
                .foregroundStyle(Color.peachDustDark)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    private func saveChanges() {
        feedStore.updateFeed(
            feed,
            amount: amount,
            startTime: feedTime,
            endTime: feed.endTime,
            notes: feed.notes,
            consumedMl: consumedMl
        )
        dismiss()
    }
}

#Preview {
    FeedHistoryView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
