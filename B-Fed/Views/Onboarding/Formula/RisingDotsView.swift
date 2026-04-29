import SwiftUI

// MARK: - Rising Dot Model
struct RisingDot: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let size: CGFloat
    let color: Color
    let duration: Double
    let delay: Double
    let swayAmount: CGFloat
}

// MARK: - Rising Dots View
struct RisingDotsView: View {
    
    let dots: [RisingDot] = [
        RisingDot(startX: 0.18, size: 8,
                  color: Color(hex: "E8C4B0"),
                  duration: 2.8, delay: 0.0,
                  swayAmount: 8),
        RisingDot(startX: 0.35, size: 12,
                  color: Color(hex: "EEE8C8"),
                  duration: 3.2, delay: 0.5,
                  swayAmount: 10),
        RisingDot(startX: 0.55, size: 7,
                  color: Color(hex: "DDE9DE"),
                  duration: 2.6, delay: 1.0,
                  swayAmount: 6),
        RisingDot(startX: 0.72, size: 10,
                  color: Color(hex: "C4BCCD"),
                  duration: 3.0, delay: 0.3,
                  swayAmount: 9),
        RisingDot(startX: 0.28, size: 6,
                  color: Color(hex: "C49070"),
                  duration: 2.4, delay: 1.4,
                  swayAmount: 7),
        RisingDot(startX: 0.62, size: 9,
                  color: Color(hex: "EEE8C8"),
                  duration: 2.9, delay: 0.7,
                  swayAmount: 8),
        RisingDot(startX: 0.82, size: 7,
                  color: Color(hex: "E8C4B0"),
                  duration: 3.1, delay: 1.8,
                  swayAmount: 6),
        RisingDot(startX: 0.10, size: 9,
                  color: Color(hex: "DDE9DE"),
                  duration: 2.7, delay: 0.9,
                  swayAmount: 10),
        RisingDot(startX: 0.45, size: 11,
                  color: Color(hex: "C4BCCD"),
                  duration: 3.3, delay: 0.2,
                  swayAmount: 7),
        RisingDot(startX: 0.90, size: 8,
                  color: Color(hex: "E8C4B0"),
                  duration: 2.5, delay: 1.1,
                  swayAmount: 9),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(dots) { dot in
                    RisingDotView(
                        dot: dot,
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
                }
            }
        }
    }
}

// MARK: - Single Rising Dot
struct RisingDotView: View {
    let dot: RisingDot
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Circle()
            .fill(dot.color)
            .frame(width: dot.size, height: dot.size)
            .opacity(opacity)
            .offset(
                x: dot.startX * screenWidth + offsetX,
                y: screenHeight - 20 + offsetY
            )
            .task {
                // Initial delay before first cycle
                try? await Task.sleep(for: .seconds(dot.delay))
                
                while !Task.isCancelled {
                    // Reset to bottom, invisible
                    withAnimation(.none) {
                        offsetY = 0
                        offsetX = 0
                        opacity = 0
                    }
                    
                    // Tiny beat so SwiftUI registers the reset
                    try? await Task.sleep(for: .nanoseconds(10_000_000))
                    
                    // Fade in
                    withAnimation(.easeIn(duration: 0.3)) {
                        opacity = 0.85
                    }
                    
                    // Rise and fade out
                    withAnimation(.easeOut(duration: dot.duration)) {
                        offsetY = -(screenHeight + 40)
                        opacity = 0
                    }
                    
                    // Sway
                    withAnimation(
                        .easeInOut(duration: dot.duration * 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        offsetX = dot.swayAmount
                    }
                    
                    // Wait for cycle to finish before resetting
                    try? await Task.sleep(for: .seconds(dot.duration))
                }
            }
    }
}
