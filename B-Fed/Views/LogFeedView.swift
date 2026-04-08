import SwiftUI

struct LogFeedView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: Double = 90
    @State private var isDragging = false
    @State private var showingTimer = false
    
    private var perFeedGuidance: String {
        feedStore.perFeedGuide.display
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Number Scrubber Area
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    
                    // Amount Display with Drag
                    AmountScrubber(amount: $amount, isDragging: $isDragging)
                    
                    // Per-feed guidance
                    Text(perFeedGuidance)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .opacity(isDragging ? 0 : 1)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)
                    
                    // Timer Toggle
                    Button {
                        showingTimer.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "stopwatch")
                            Text(showingTimer ? "Hide Timer" : "Track Duration")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.emerald)
                    }
                    
                    if showingTimer {
                        TimerView()
                    }
                    
                    // Save Button
                    Button(action: saveFeed) {
                        Text("Save Feed")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.emerald)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Log Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Pre-fill with middle of typical range
                let guide = feedStore.perFeedGuide
                let midPoint = (guide.typical.min + guide.typical.max) / 2
                amount = Double(midPoint)
            }
        }
    }
    
    private func saveFeed() {
        guard amount > 0 else { return }
        
        _ = feedStore.createFeed(amount: amount)
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
    
    private let magneticPoints = [60, 90, 120, 150, 180]
    private let magneticRange: Double = 5
    
    var body: some View {
        VStack(spacing: 12) {
            // Amount Display
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(amount))")
                    .font(.system(size: 96, weight: .light, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .scaleEffect(scale)
                
                Text("ml")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.secondary)
            }
            .gesture(
                DragGesture()
                    .onChanged(handleDrag)
                    .onEnded(handleDragEnd)
            )
            
            // Helper
            Text("Swipe to adjust")
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.7))
                .opacity(isDragging ? 0 : 1)
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
        withAnimation(.easeInOut(duration: 0.05)) {
            scale = 1.03
        }
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
        
        withAnimation(.spring(response: 0.3)) {
            amount = finalAmount
            scale = 1.0
        }
    }
}

// MARK: - Timer View
struct TimerView: View {
    @State private var isRunning = false
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    
    var displayTime: String {
        let mins = Int(elapsed) / 60
        let secs = Int(elapsed) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var body: some View {
        HStack {
            Text(displayTime)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .monospacedDigit()
            
            Spacer()
            
            Button(action: toggleTimer) {
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(isRunning ? .white : Color.emerald)
                    .frame(width: 50, height: 50)
                    .background(isRunning ? Color.red.opacity(0.9) : Color.emerald.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsed += 1
            }
        }
    }
}

// MARK: - Color Extension
private extension Color {
    static var emerald: Color {
        Color(red: 0.18, green: 0.44, blue: 0.37)
    }
}

#Preview {
    LogFeedView()
        .environment(FeedStore())
        .modelContainer(for: Feed.self, inMemory: true)
}
