import SwiftUI

struct LogFeedView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: Double = 90
    @State private var isDragging = false
    @State private var showingTimer = false
    @State private var showingConfirmation = false
    @State private var lastSavedFeed: Feed?
    
    private var perFeedGuidance: String {
        feedStore.perFeedGuide.display
    }
    
    private var bottleFillLevel: CGFloat {
        let guide = feedStore.perFeedGuide
        let target = Double(guide.typical.max)
        guard target > 0 else { return 0 }
        let percentage = amount / target
        return CGFloat(min(percentage, 1.0))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Number Scrubber Area
                VStack(spacing: 20) {
                    Spacer().frame(height: AppSpacing.xxl)
                    
                    // Bottle Fill Preview
                    BottleFillPreview(fillLevel: bottleFillLevel)
                        .frame(width: 80, height: 130)
                        .opacity(isDragging ? 1 : 0.6)
                        
                    
                    // Amount Display with Drag
                    AmountScrubber(amount: $amount, isDragging: $isDragging)
                    
                    // Per-feed guidance
                    Text(perFeedGuidance)
                        .font(AppFont.body)
                        .foregroundStyle(Color.inkSecondary)
                        .opacity(isDragging ? 0 : 1)
                    
                    // Formula context
                    if let profile = feedStore.babyProfile,
                       profile.showsFormulaInfo {
                        FormulaFeedContext(profile: profile)
                            .opacity(isDragging ? 0 : 1)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.backgroundBase)
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.inkSecondary.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)
                    
                    // Timer Toggle
                    Button {
                        showingTimer.toggle()
                        if showingTimer {
                            feedStore.startFeedTimer()
                        } else {
                            feedStore.resetFeedTimer()
                        }
                    } label: {
                        HStack {
                            Image(systemName: feedStore.isTimerRunning ? "stopwatch.fill" : "stopwatch")
                            Text(timerButtonTitle)
                        }
                        .font(AppFont.body)
                        .foregroundStyle(Color.almostAquaDark)
                    }
                    
                    if showingTimer {
                        FeedTimerView()
                    }
                    
                    // Save Button with gentle press
                    Button(action: saveFeed) {
                        Text("Save Feed")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.bottom, AppSpacing.sm)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
                .background(Color.backgroundCard)
            }
            .navigationTitle("Log Feed")
            
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        feedStore.resetFeedTimer()
                        dismiss()
                    }
                }
            }
            .onAppear {
                let guide = feedStore.perFeedGuide
                let midPoint = (guide.typical.min + guide.typical.max) / 2
                amount = Double(midPoint)
            }
            .onDisappear {
                if !showingConfirmation {
                    feedStore.resetFeedTimer()
                }
            }
            .fullScreenCover(isPresented: $showingConfirmation) {
                FeedConfirmationView(
                    babyName: feedStore.babyProfile?.babyName ?? "your baby",
                    onComplete: confirmFeed
                )
            }
        }
    }
    
    private var timerButtonTitle: String {
        if feedStore.isTimerRunning {
            let mins = Int(feedStore.timerElapsed) / 60
            let secs = Int(feedStore.timerElapsed) % 60
            return String(format: "Tracking %02d:%02d", mins, secs)
        }
        return showingTimer ? "Stop Tracking" : "Track Duration"
    }
    
    private func saveFeed() {
        guard amount > 0 else { return }
        
        lastSavedFeed = feedStore.createFeed(amount: amount)
        showingConfirmation = true
    }
    
    private func confirmFeed(completed: Bool) {
        if let feed = lastSavedFeed {
            feedStore.updateFeed(feed, amount: feed.amount, startTime: feed.startTime, endTime: feed.endTime, notes: feed.notes, completed: completed)
        }
        dismiss()
    }
}

// MARK: - Amount Scrubber
struct AmountScrubber: View {
    @Binding var amount: Double
    @Binding var isDragging: Bool
    
    @State private var dragStartX: CGFloat = 0
    @State private var dragStartAmount: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isHorizontalDrag: Bool = false
    @State private var textInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private let magneticPoints = [60, 90, 120, 150, 180]
    private let magneticRange: Double = 5
    
    var body: some View {
        VStack(spacing: 12) {
            // Amount Display (drag gesture for sighted users)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(amount))")
                    .font(AppFont.jumbo)
                    .foregroundStyle(Color.inkPrimary)
                    .monospacedDigit()
                    .scaleEffect(scale)
                    .accessibilityHidden(true)
                
                Text("ml")
                    .font(AppFont.subHero)
                    .foregroundStyle(Color.inkSecondary)
                    .accessibilityHidden(true)
            }
            .gesture(
                DragGesture()
                    .onChanged(handleDrag)
                    .onEnded(handleDragEnd)
            )
            
            // Accessibility fallback: text field for VoiceOver / precise input
            TextField("Amount in millilitres", value: $amount, format: .number)
                .font(AppFont.sans(17))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .accessibilityLabel("Feed amount")
                .accessibilityHint("Enter amount in millilitres")
                .focused($isTextFieldFocused)
            
            // Helper
            Text("Swipe to adjust")
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary.opacity(0.7))
                .opacity(isDragging || isTextFieldFocused ? 0 : 1)
        }
    }
    
    private func handleDrag(value: DragGesture.Value) {
        // On first movement, determine if this is a horizontal drag
        if !isDragging {
            let horizontalDelta = abs(value.translation.width)
            let verticalDelta = abs(value.translation.height)
            
            // Only start if movement is primarily horizontal
            guard horizontalDelta > verticalDelta else { return }
            
            isHorizontalDrag = true
            isDragging = true
            dragStartX = value.location.x
            dragStartAmount = amount
        }
        
        // Only process if this was determined to be a horizontal drag
        guard isHorizontalDrag else { return }
        
        let deltaX = value.location.x - dragStartX
        let velocity = abs(value.velocity.width)
        
        // Sensitivity based on velocity
        let sensitivity: Double
        if velocity < 100 { sensitivity = 0.3 }
        else if velocity < 500 { sensitivity = 0.6 }
        else if velocity < 1000 { sensitivity = 1.2 }
        else { sensitivity = 2.0 }
        
        var newAmount = dragStartAmount + Double(deltaX) * sensitivity
        
        // Magnetic effect near common values
        for point in magneticPoints {
            let distance = abs(newAmount - Double(point))
            if distance < magneticRange {
                let resistance = 0.3 + (0.7 * (distance / magneticRange))
                newAmount = dragStartAmount + Double(deltaX) * sensitivity * resistance
            }
        }
        
        amount = max(0, min(240, newAmount))
        
        // Visual feedback
        // Gentle scale feedback during drag
        scale = 1.02
    }
    
    private func handleDragEnd(_: DragGesture.Value) {
        isDragging = false
        
        // Only process if this was a horizontal drag
        guard isHorizontalDrag else {
            isHorizontalDrag = false
            return
        }
        
        isHorizontalDrag = false
        
        var finalAmount = round(amount)
        
        // Snap to magnetic point if close
        for point in magneticPoints {
            if abs(finalAmount - Double(point)) <= 3 {
                finalAmount = Double(point)
                break
            }
        }
        
        // Gentle return to rest
        amount = finalAmount
        scale = 1.0
    }
}

// MARK: - Bottle Fill Preview
struct BottleFillPreview: View {
    let fillLevel: CGFloat
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            BottleGlassShape()
                .fill(Color.backgroundCard.opacity(0.6))
            
            LiquidWithWave(fillLevel: fillLevel, phase: wavePhase)
                .clipShape(BottleGlassShape())
            
            BottleGlassShape()
                .stroke(Color.backgroundCard.opacity(0.6), lineWidth: 2)
        }
        .onAppear {
            wavePhase = .pi * 2
        }
    }
}

// MARK: - Feed Timer View
struct FeedTimerView: View {
    @Environment(FeedStore.self) private var feedStore
    
    var displayTime: String {
        let elapsed = feedStore.timerElapsed
        let mins = Int(elapsed) / 60
        let secs = Int(elapsed) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var body: some View {
        HStack {
            Text(displayTime)
                .font(AppFont.sans(32, weight: .medium))
                .monospacedDigit()
                .accessibilityLabel("Elapsed time: \(displayTime)")
            
            Spacer()
            
            Button(action: toggleTimer) {
                Image(systemName: feedStore.isTimerRunning ? "stop.fill" : "play.fill")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(feedStore.isTimerRunning ? .white : Color.almostAquaDark)
                    .frame(width: 48, height: 48)
                    .background(feedStore.isTimerRunning ? Color.peachDustDark.opacity(0.9) : Color.almostAquaDark.opacity(0.1))
                    .clipShape(Circle())
            }
            .accessibilityLabel(feedStore.isTimerRunning ? "Stop timer" : "Start timer")
        }
        .cardStyle()
    }
    
    private func toggleTimer() {
        if feedStore.isTimerRunning {
            _ = feedStore.stopFeedTimer()
        } else {
            feedStore.startFeedTimer()
        }
    }
}



// MARK: - Feed Confirmation View
struct FeedConfirmationView: View {
    let babyName: String
    let onComplete: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundBase.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: AppSpacing.xxl)
                
                ZStack {
                    Circle()
                        .fill(Color.almostAquaDark.opacity(0.08))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppFont.sans(56, weight: .light))
                        .foregroundStyle(Color.almostAquaDark)
                }
                
                Spacer().frame(height: AppSpacing.xl)
                
                Text("Feed logged")
                    .font(AppFont.serif(28))
                    .foregroundStyle(Color.inkPrimary)
                
                Spacer().frame(height: AppSpacing.md)
                
                Text("Did \(babyName) finish the whole bottle?")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(Color.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                
                Spacer().frame(height: AppSpacing.xxl)
                
                VStack(spacing: AppSpacing.md) {
                    Button {
                        onComplete(true)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(AppFont.body)
                            Text("Yes, all of it")
                                .font(AppFont.bodyLarge)
                        }
                        .frame(maxWidth: .infinity)
                        .primaryButton()
                    }
                    .accessibilityLabel("Yes, finished whole bottle")
                    
                    Button {
                        onComplete(false)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "minus.circle")
                                .font(AppFont.body)
                            Text("Left some")
                                .font(AppFont.bodyLarge)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.inkSecondary)
                        .padding(.vertical, AppSpacing.md)
                    }
                    .accessibilityLabel("No, left some milk")
                }
                .padding(.horizontal, AppSpacing.xl)
                
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Formula Feed Context
struct FormulaFeedContext: View {
    let profile: BabyProfile
    
    private var displayBrand: String {
        profile.customFormulaBrand ?? profile.formulaBrand ?? "Formula"
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "drop.fill")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.almostAquaDark)
            
            Text(displayBrand)
                .font(AppFont.sans(13, weight: .medium))
                .foregroundStyle(Color.inkPrimary)
            
            if let stage = profile.formulaStage {
                Text("·")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSecondary)
                
                Text(stage.displayName)
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.almostAquaDark.opacity(0.08))
        .clipShape(Capsule())
    }
}

#Preview {
    LogFeedView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
