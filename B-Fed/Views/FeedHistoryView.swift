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
    
    private var feedingType: FeedingType {
        feedStore.babyProfile?.feedingType ?? .formula
    }
    
    private var isBreastfeedingMode: Bool {
        feedingType == .breast
    }
    
    private var groupedDays: [DayGroup] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: feeds) { calendar.startOfDay(for: $0.startTime) }
        let sortedDays = byDay.keys.sorted { $0 > $1 }
        return sortedDays.map { date in
            let dayFeeds = byDay[date] ?? []
            let totalMl = dayFeeds.reduce(0) { $0 + Int($1.consumedMl ?? Int($1.amount)) }
            let totalDuration = dayFeeds.compactMap { $0.totalDurationSeconds }.reduce(0, +)
            return DayGroup(
                date: date,
                feeds: dayFeeds.sorted { $0.startTime > $1.startTime },
                totalMl: totalMl,
                totalDurationSeconds: totalDuration
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color.surfaceCream.ignoresSafeArea()
            
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
                .fill(Color.accentLavender.opacity(0.32))
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
        .accessibilityHidden(true)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("History")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color.textPrimary)
            
            Text("\(babyName) · all feeds")
                .font(AppFont.sans(13))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Empty state
    
    private var emptyState: some View {
        Text("No feeds logged yet")
            .font(AppFont.sans(13))
            .foregroundColor(Color.textSecondary)
            .italic()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: — Day list
    
    private var dayList: some View {
        LazyVStack(spacing: 24) {
            ForEach(groupedDays) { group in
                DaySection(
                    group: group,
                    onTapFeed: { feed in
                        feedToEdit = feed
                    },
                    onDeleteFeed: { feed in
                        feedToDelete = feed
                        showingDeleteConfirmation = true
                    },
                    isBreastfeedingMode: isBreastfeedingMode
                )
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
    let totalDurationSeconds: Int
}

// MARK: - Day Section
private struct DaySection: View {
    let group: DayGroup
    let onTapFeed: (Feed) -> Void
    let onDeleteFeed: (Feed) -> Void
    let isBreastfeedingMode: Bool
    
    private var dayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(group.date) {
            return "Today"
        } else if calendar.isDateInYesterday(group.date) {
            return "Yesterday"
        } else {
            return AppFormatters.dayLabel.string(from: group.date)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header
            HStack {
                Text(dayLabel)
                    .font(AppFont.sans(10, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                    .tracking(0.05 * 10)
                    .textCase(.uppercase)
                
                Spacer()
                
                Group {
                    if isBreastfeedingMode {
                        let durationText = BreastfeedingGuidance.formatDurationVerbose(group.totalDurationSeconds)
                        Text("\(group.feeds.count) feed\(group.feeds.count == 1 ? "" : "s") · \(durationText)")
                    } else {
                        Text("\(group.feeds.count) feed\(group.feeds.count == 1 ? "" : "s") · \(group.totalMl) ml")
                    }
                }
                .font(AppFont.sans(11))
                .foregroundColor(Color.textSecondary)
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
    
    @Environment(FeedStore.self) private var feedStore
    
    private var feedingType: FeedingType {
        feedStore.babyProfile?.feedingType ?? .formula
    }
    
    private var isBreastfeedingMode: Bool {
        feedingType == .breast
    }
    
    private var isPartial: Bool {
        let prepared = Int(feed.amount)
        let consumed = feed.consumedMl ?? prepared
        return consumed < prepared
    }
    
    private var statusColor: Color {
        if isBreastfeedingMode {
            return feed.feedingSide != nil ? Color(hex: "7B6A9A") : Color.accentLavender
        }
        return isPartial ? Color.accentLavender : Color(hex: "7B6A9A")
    }
    
    private var timeString: String {
        return AppFormatters.time.string(from: feed.startTime).lowercased()
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
    
    private var breastInfo: String {
        guard let side = feed.feedingSide else { return "" }
        if side == .both,
           let left = feed.leftDurationSeconds,
           let right = feed.rightDurationSeconds {
            return "Left \(BreastfeedingGuidance.formatDuration(left)) · Right \(BreastfeedingGuidance.formatDuration(right))"
        }
        return side.displayName
    }
    
    private var primaryText: String {
        if isBreastfeedingMode, let total = feed.totalDurationSeconds {
            return "\(BreastfeedingGuidance.formatDuration(total)) total"
        }
        return "\(Int(feed.amount)) ml"
    }
    
    private var secondaryText: String {
        if isBreastfeedingMode {
            return breastInfo
        }
        return formulaInfo
    }
    
    private var accessibilityLabel: String {
        if isBreastfeedingMode, let side = feed.feedingSide {
            return "\(primaryText) feed on \(side.displayName) at \(timeString)"
        }
        return "\(Int(feed.amount)) millilitre feed at \(timeString), \(formulaInfo)"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(primaryText)
                            .font(AppFont.sans(14, weight: .medium))
                            .foregroundColor(Color.textPrimary)
                        
                        if !isBreastfeedingMode, isPartial, let consumed = feed.consumedMl {
                            Text("· \(consumed) ml consumed")
                                .font(AppFont.sans(11, weight: .regular))
                                .foregroundColor(Color(hex: "B07850"))
                        }
                    }
                    
                    Text(secondaryText)
                        .font(AppFont.sans(12))
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeString)
                        .font(AppFont.sans(13))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(periodLabel)
                        .font(AppFont.sans(11))
                        .foregroundColor(Color.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
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
    @State private var isSaving: Bool = false
    
    private var feedingType: FeedingType {
        feedStore.babyProfile?.feedingType ?? .formula
    }
    
    private var isBreastMode: Bool { feedingType == .breast }
    private var isMixedMode: Bool { feedingType == .mixed }
    private var showsFormulaSections: Bool { !isBreastMode }
    private var showsBreastSections: Bool { isBreastMode || isMixedMode }
    
    private var timeString: String {
        return AppFormatters.time.string(from: feedTime)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCard.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                                .frame(width: 32, height: 4)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 10)
                            
                            Text("Edit feed")
                                .font(AppFont.screenTitle)
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            if showsFormulaSections {
                                sectionLabel("FORMULA")
                                    .padding(.top, 8)
                                
                                formulaRow
                                    .padding(.horizontal, 20)
                                
                                sectionLabel("AMOUNT")
                                    .padding(.top, 12)
                                
                                amountStepperCard
                                    .padding(.horizontal, 20)
                                
                                sectionLabel("CONSUMED")
                                    .padding(.top, 12)
                                
                                consumedStepperCard
                                    .padding(.horizontal, 20)
                            }
                            
                            if showsBreastSections {
                                if let side = feed.feedingSide {
                                    sectionLabel("SIDE")
                                        .padding(.top, showsFormulaSections ? 12 : 8)
                                    
                                    sideInfoRow(side: side)
                                        .padding(.horizontal, 20)
                                }
                                
                                if let total = feed.totalDurationSeconds, total > 0 {
                                    sectionLabel("DURATION")
                                        .padding(.top, 12)
                                    
                                    durationInfoRow
                                        .padding(.horizontal, 20)
                                }
                            }
                            
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
            TimePickerSheet(selectedTime: $feedTime, baseDate: feed.startTime)
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
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Your current formula")
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.textSecondary)
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
    
    private func sideInfoRow(side: FeedingSide) -> some View {
        HStack(spacing: 12) {
            Text(side.displayName)
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfacePurple)
        )
    }
    
    private var durationInfoRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let total = feed.totalDurationSeconds {
                HStack {
                    Text("Total")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text(BreastfeedingGuidance.formatDuration(total))
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()
                }
            }
            if let left = feed.leftDurationSeconds, left > 0 {
                HStack {
                    Text("Left")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text(BreastfeedingGuidance.formatDuration(left))
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()
                }
            }
            if let right = feed.rightDurationSeconds, right > 0 {
                HStack {
                    Text("Right")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text(BreastfeedingGuidance.formatDuration(right))
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
            .accessibilityLabel("Decrease amount")
            
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
            .accessibilityLabel("Increase amount")
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
            .accessibilityLabel("Decrease consumed amount")
            
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
            .accessibilityLabel("Increase consumed amount")
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
                        .accessibilityHidden(true)
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
            .accessibilityLabel("Feed time, \(timeString)")
        }
    }
    
    private var saveButton: some View {
        let canSave = isBreastMode ? true : (amount > 0 && !isSaving)
        return Button(action: saveChanges) {
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
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.4)
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Save changes")
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
        .accessibilityLabel("Delete feed")
        .padding(.horizontal, 20)
    }
    
    private func saveChanges() {
        guard !isSaving else { return }
        if !isBreastMode && amount <= 0 { return }
        isSaving = true
        
        feedStore.updateFeed(
            feed,
            amount: showsFormulaSections ? amount : nil,
            startTime: feedTime,
            endTime: feed.endTime,
            notes: feed.notes,
            consumedMl: showsFormulaSections ? consumedMl : nil
        )
        dismiss()
    }
}

#Preview {
    FeedHistoryView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
