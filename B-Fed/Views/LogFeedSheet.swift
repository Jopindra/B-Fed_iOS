import SwiftUI
import SwiftData

struct LogFeedSheet: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Feed.startTime, order: .reverse) private var allFeeds: [Feed]
    
    @State private var amount: Double = 120
    @State private var timerActive: Bool = false
    @State private var selectedTime: Date = Date()
    @State private var showingTimePicker: Bool = false
    @State private var showingFormulaPicker: Bool = false
    
    // MARK: - Derived
    private var formulaDisplayName: String {
        guard let profile = feedStore.babyProfile else { return "Select formula" }
        return profile.customFormulaBrand ?? profile.formulaBrand ?? "Select formula"
    }
    
    private var hasFormulaSet: Bool {
        guard let profile = feedStore.babyProfile else { return false }
        return (profile.customFormulaBrand ?? profile.formulaBrand) != nil
    }
    
    private var defaultAmount: Double {
        if let lastFeed = allFeeds.first {
            return lastFeed.amount
        }
        return 120
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: selectedTime)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Top handle
                        sheetHandle
                        
                        // Title
                        Text("Log a feed")
                            .font(AppFont.serif(20))
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
                            .padding(.bottom, 20)
                        
                        // Save button at bottom of scroll content
                        saveButton
                            .padding(.top, 12)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(20)
        .presentationBackground(.white)
        .onAppear {
            amount = defaultAmount
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $selectedTime)
        }
        .sheet(isPresented: $showingFormulaPicker) {
            LogFeedFormulaPickerSheet()
        }
    }
    
    // MARK: - Sheet Handle
    private var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.black.opacity(0.12))
            .frame(width: 32, height: 4)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
    }
    
    // MARK: - Section Label
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.sans(9, weight: .semibold))
            .foregroundStyle(Color.inkSecondary)
            .tracking(0.3)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
    }
    
    // MARK: - Formula Row
    private var formulaRow: some View {
        Button(action: { showingFormulaPicker = true }) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.almostAquaLight)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(formulaIcon)
                            .font(AppFont.sans(10, weight: .semibold))
                            .foregroundStyle(Color.almostAquaDark)
                    )
                
                Text(formulaDisplayName)
                    .font(AppFont.sans(13, weight: .medium))
                    .foregroundStyle(hasFormulaSet ? Color.inkPrimary : Color.orchidTint)
                
                Spacer()
                
                Text("›")
                    .font(AppFont.sans(16, weight: .light))
                    .foregroundStyle(Color.inkSecondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.backgroundBase)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formulaIcon: String {
        guard hasFormulaSet else { return "?" }
        let name = formulaDisplayName
        return String(name.prefix(1)).uppercased()
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
                    .font(AppFont.sans(10, weight: .regular))
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
                        .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
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
                .font(AppFont.sans(20, weight: .regular))
                .foregroundStyle(Color.inkPrimary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
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
            ForEach([60, 90, 120, 150, 180], id: \.self) { value in
                Button(action: { amount = Double(value) }) {
                    Text("\(value)ml")
                        .font(AppFont.sans(11, weight: .medium))
                        .foregroundStyle(isPillActive(value) ? Color.white : Color.inkPrimary)
                        .frame(height: 28)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(isPillActive(value) ? Color.inkPrimary : Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
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
            
            Toggle("", isOn: $timerActive)
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
                        .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Time Field
    private var timeField: some View {
        Button(action: { showingTimePicker = true }) {
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
                            .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        VStack(spacing: 0) {
            Button(action: saveFeed) {
                Text("Save feed")
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.inkPrimary)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .background(Color.white)
    }
    
    // MARK: - Save Action
    private func saveFeed() {
        guard amount > 0 else { return }
        
        if timerActive {
            feedStore.startFeedTimer()
        }
        
        _ = feedStore.createFeed(
            amount: amount,
            startTime: selectedTime,
            notes: "",
            completed: true
        )
        
        dismiss()
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
                            .font(.system(size: 22))
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
        .modelContainer(for: Feed.self, inMemory: true)
}
