import SwiftUI
import SwiftData
import UserNotifications

struct LogFeedSheet: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(SelectedFormulaStore.self) private var formulaStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    @State private var amount: Double = 120
    @State private var timerActive: Bool = false
    @State private var feedTime: Date = Date()
    @State private var isTimeManuallySet: Bool = false
    @State private var timeUpdateTimer: Timer? = nil
    @State private var showingTimePicker: Bool = false
    @State private var showingFormulaSelector: Bool = false
    @State private var showingFormulaDetail: Bool = false
    @State private var originalFormula: Formula? = nil
    @State private var formulaChangedForThisFeed: Bool = false
    
    // MARK: - Derived
    private var formulaDisplayName: String {
        if let selected = formulaStore.selectedFormula {
            return selected.isCustom ? selected.name : selected.displayName
        }
        guard let profile = feedStore.babyProfile else { return "Select formula" }
        return profile.customFormulaBrand ?? profile.formulaBrand ?? "Select formula"
    }
    
    private var formulaSubtitle: String {
        formulaChangedForThisFeed ? "Changed for this feed" : "Your current formula"
    }
    
    private var hasFormulaSet: Bool {
        if formulaStore.selectedFormula != nil { return true }
        guard let profile = feedStore.babyProfile else { return false }
        return (profile.customFormulaBrand ?? profile.formulaBrand) != nil
    }
    
    private var currentFormula: Formula? {
        if let selected = formulaStore.selectedFormula { return selected }
        guard let profile = feedStore.babyProfile,
              let brand = profile.customFormulaBrand ?? profile.formulaBrand else { return nil }
        return FormulaService.allFormulas.first {
            $0.brand == brand || $0.displayName.contains(brand)
        }
    }
    
    private var ageInMonths: Int? {
        guard let dob = feedStore.babyProfile?.dateOfBirth else { return nil }
        return FormulaStageService.ageInMonths(from: dob)
    }
    
    private var perFeedRange: (min: Int, max: Int) {
        guard let months = ageInMonths else { return (60, 120) }
        switch months {
        case 0..<1:  return (60, 90)
        case 1..<2:  return (90, 120)
        case 2..<4:  return (120, 180)
        case 4..<6:  return (150, 210)
        case 6..<9:  return (180, 240)
        case 9..<12: return (180, 240)
        case 12..<24: return (150, 200)
        default:     return (120, 180)
        }
    }
    
    private var quickAmountValues: [Int] {
        let (feedMin, feedMax) = perFeedRange
        let low = max(10, feedMin - 20)
        let midLow = feedMin
        let mid = Int(round(Double(feedMin + feedMax) / 2.0 / 10.0) * 10.0)
        let midHigh = feedMax
        let high = min(350, feedMax + 20)
        return [low, midLow, mid, midHigh, high]
    }
    
    private var todayFeeds: [Feed] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allFeeds.filter { $0.startTime >= startOfDay && $0.startTime < endOfDay }
    }
    
    private var defaultAmount: Double {
        let pills = quickAmountValues
        let midpoint = Double(pills[2])
        
        guard !todayFeeds.isEmpty else { return midpoint }
        
        let avg = todayFeeds.reduce(0.0) { $0 + $1.amount } / Double(todayFeeds.count)
        let rounded = round(avg / 10.0) * 10.0
        let closest = pills.map { Double($0) }.min { abs($0 - rounded) < abs($1 - rounded) } ?? midpoint
        return closest
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: feedTime)
    }
    
    private func startTimeTimer() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            Task { @MainActor in
                if !isTimeManuallySet {
                    feedTime = Date()
                }
            }
        }
    }
    
    private func stopTimeTimer() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCard.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Top handle
                            sheetHandle
                            
                            // Title
                            Text("Log a feed")
                                .font(AppFont.screenTitle)
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            // Formula section
                            sectionLabel("FORMULA")
                                .padding(.top, 8)
                            
                            formulaRow
                                .padding(.horizontal, 20)
                            
                            if formulaChangedForThisFeed {
                                Button(action: resetFormula) {
                                    Text("Reset to \(originalFormula?.brand ?? originalFormula?.name ?? "original")")
                                        .font(AppFont.sans(11))
                                        .foregroundStyle(Color(hex: "5A8A5A"))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                                .padding(.top, 6)
                            }
                            
                            // Amount section
                            sectionLabel("AMOUNT")
                                .padding(.top, 12)
                            
                            amountInputCard
                                .padding(.horizontal, 20)
                            
                            // Quick amount pills
                            quickAmountPills
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            
                            // Timer toggle
                            sectionLabel("FEED TIMER")
                                .padding(.top, 12)
                            
                            timerToggleRow
                                .padding(.horizontal, 20)
                            
                            // Time field
                            sectionLabel("TIME")
                                .padding(.top, 8)
                            
                            timeField
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                        }
                    }
                    
                    saveButton
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(20)
        .presentationBackground(.white)
        .onAppear {
            amount = defaultAmount
            originalFormula = formulaStore.selectedFormula ?? currentFormula
            feedTime = Date()
            startTimeTimer()
        }
        .onDisappear {
            stopTimeTimer()
        }
        .onChange(of: showingFormulaSelector) { _, isShowing in
            if !isShowing {
                formulaChangedForThisFeed = formulaStore.selectedFormula?.id != originalFormula?.id
                if formulaChangedForThisFeed {
                    amount = Double(quickAmountValues[2])
                }
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $feedTime)
        }
        .sheet(isPresented: $showingFormulaSelector) {
            FormulaSelector()
        }
        .sheet(isPresented: $showingFormulaDetail) {
            if let formula = currentFormula {
                FormulaDetailView(formula: formula, volumeMl: amount)
            }
        }
    }
    
    // MARK: - Sheet Handle
    private var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
            .frame(width: 32, height: 4)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
    }
    
    // MARK: - Section Label
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.label)
            .foregroundStyle(Color.inkSecondary)
            .tracking(0.3)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
    }
    
    // MARK: - Formula Row
    private var formulaRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.almostAquaLight)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(formulaIcon)
                            .font(AppFont.sans(12, weight: .semibold))
                            .foregroundStyle(Color.almostAquaDark)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(formulaDisplayName)
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Color(hex: "1C2421"))
                    
                    Text(formulaSubtitle)
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color(hex: "888780"))
                        .italic(formulaChangedForThisFeed)
                }
            }
            
            Spacer()
            
            Button(action: { showingFormulaSelector = true }) {
                Text("Change")
                    .font(AppFont.sans(12, weight: .medium))
                    .foregroundStyle(Color(hex: "5A8A5A"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: "EEF4EE"))
                    )
            }
            .buttonStyle(PlainButtonStyle())
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
    
    private var formulaIcon: String {
        guard hasFormulaSet else { return "?" }
        let name = formulaDisplayName
        return String(name.prefix(1)).uppercased()
    }
    
    private func resetFormula() {
        formulaStore.selectedFormula = originalFormula
        formulaChangedForThisFeed = false
    }
    
    // MARK: - Amount Input Card
    private var amountInputCard: some View {
        HStack {
            // Minus button
            amountButton("−") {
                amount = max(0, amount - 10)
            } onLongPress: {
                amount = max(0, amount - 50)
            }
            
            Spacer()
            
            // Amount display
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
            
            // Plus button
            amountButton("+") {
                amount = min(300, amount + 10)
            } onLongPress: {
                amount = min(300, amount + 50)
            }
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
    
    private func amountButton(
        _ label: String,
        action: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.lead)
                .foregroundStyle(Color.inkPrimary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.backgroundCard)
                        
                )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in onLongPress() }
        )
    }
    
    // MARK: - Quick Amount Pills
    private var quickAmountPills: some View {
        HStack(spacing: 8) {
            ForEach(quickAmountValues, id: \.self) { value in
                Button(action: { amount = Double(value) }) {
                    Text("\(value)ml")
                        .font(AppFont.caption)
                        .foregroundStyle(isPillActive(value) ? Color.backgroundCard : Color.inkPrimary)
                        .frame(height: 28)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(isPillActive(value) ? Color.inkPrimary : Color.backgroundCard)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func isPillActive(_ value: Int) -> Bool {
        Int(amount) == value
    }
    
    // MARK: - Timer Toggle Row
    private var timerToggleRow: some View {
        HStack {
            Text("Start timer when I save")
                .font(AppFont.sans(13, weight: .regular))
                .foregroundStyle(Color.inkPrimary)
            
            Spacer()
            
            Toggle("Start bottle timer", isOn: $timerActive).labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.inkPrimary))
                .labelsHidden()
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
    
    // MARK: - Time Field
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
            
            if isTimeManuallySet {
                Button(action: {
                    isTimeManuallySet = false
                    feedTime = Date()
                }) {
                    Text("Now")
                        .font(AppFont.sans(11, weight: .medium))
                        .foregroundStyle(Color(hex: "5A8A5A"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "EEF4EE"))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        VStack(spacing: 0) {
            Button(action: saveFeed) {
                Text("Save feed")
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
        .background(Color.backgroundCard)
    }
    
    // MARK: - Save Action
    private func saveFeed() {
        guard amount > 0 else { return }

        _ = feedStore.createFeed(
            amount: amount,
            startTime: feedTime,
            notes: "",
            completed: true
        )

        if timerActive {
            feedStore.startFeedTimer()
            scheduleBottleNotification()
        }

        dismiss()
    }

    private func scheduleBottleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Remove any pending bottle timer notification before scheduling a new one
        center.removePendingNotificationRequests(withIdentifiers: ["bottle-timer-notification"])

        let content = UNMutableNotificationContent()
        content.title = "Bottle check"
        let timeString = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: feedTime).lowercased()
        }()
        content.body = "The bottle made at \(timeString) should be used or discarded"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "bottle-timer-notification", content: content, trigger: trigger)

        center.add(request)
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Formula Picker Sheet
struct LogFeedFormulaPickerSheet: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    private var formulaBrand: String? {
        feedStore.babyProfile?.customFormulaBrand ?? feedStore.babyProfile?.formulaBrand
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let brand = formulaBrand {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.almostAquaLight)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(brand.prefix(1)).uppercased())
                                    .font(AppFont.sans(14, weight: .semibold))
                                    .foregroundStyle(Color.almostAquaDark)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(brand)
                                .font(AppFont.sans(16, weight: .semibold))
                                .foregroundStyle(Color.inkPrimary)
                            
                            if let stage = feedStore.babyProfile?.formulaStage {
                                Text(stage.displayName)
                                    .font(AppFont.sans(13, weight: .regular))
                                    .foregroundStyle(Color.inkSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppFont.sans(22, weight: .regular))
                            .foregroundStyle(Color.inkPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    ContentUnavailableView(
                        "No Formula Set",
                        systemImage: "drop",
                        description: Text("Set a formula in Settings to see it here.")
                    )
                    .padding(.top, 40)
                }
                
                Spacer()
            }
            .navigationTitle("Formula")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    LogFeedSheet()
        .environment(FeedStore())
        .environment(SelectedFormulaStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
