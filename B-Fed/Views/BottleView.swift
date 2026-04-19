import SwiftUI

struct BottleView: View {
    let fillLevel: CGFloat // 0.0 to 1.0
    let isAnimating: Bool
    @State private var waveOffset: CGFloat = 0
    @State private var secondaryWaveOffset: CGFloat = 0
    @State private var bottleScale: CGFloat = 1.0
    @State private var glowOpacity: CGFloat = 0
    
    // Cap fill at 85% to avoid "completion" feeling
    private var cappedFillLevel: CGFloat {
        min(fillLevel, 0.85)
    }
    
    // Add glow effect when bottle is well-fed (above 70%)
    private var shouldGlow: Bool {
        fillLevel > 0.7
    }
    
    var body: some View {
        ZStack {
            // Glow effect when bottle is well-fed
            if shouldGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#2F6F5E").opacity(0.3),
                                Color(hex: "#2F6F5E").opacity(0)
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                    .opacity(glowOpacity)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowOpacity)
                    .onAppear {
                        glowOpacity = 1
                    }
            }
            
            // Bottle container
            ZStack {
                // Bottle outline (hand-drawn feel)
                BottleShape()
                    .stroke(
                        Color(hex: "#8B9A8B"),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 100, height: 160)
                
                // Liquid with wave
                LiquidBottleView(
                    fillLevel: cappedFillLevel,
                    waveOffset: waveOffset,
                    secondaryWaveOffset: secondaryWaveOffset
                )
                .frame(width: 94, height: 154)
                .clipShape(BottleShape().inset(by: 3))
            }
            .scaleEffect(bottleScale)
        }
        .onAppear {
            // Gentle continuous wave animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 2
            }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                secondaryWaveOffset = .pi * 2
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                performFillAnimation()
            }
        }
    }
    
    private func performFillAnimation() {
        // Button press
        withAnimation(.easeInOut(duration: 0.1)) {
            bottleScale = 0.97
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Release and micro bounce
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                bottleScale = 1.02
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.2)) {
                    bottleScale = 1.0
                }
            }
        }
    }
}

// MARK: - Bottle Shape (Soft, rounded, hand-drawn feel)
struct BottleShape: Shape, InsettableShape {
    var insetAmount: CGFloat = 0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let width = insetRect.width
        let height = insetRect.height
        
        // Neck width and body width
        let neckWidth = width * 0.35
        let bodyWidth = width * 0.75
        let neckHeight = height * 0.25
        let shoulderHeight = height * 0.35
        
        // Start at bottom left of body
        path.move(to: CGPoint(x: (width - bodyWidth) / 2, y: height - 15))
        
        // Bottom curve (slightly irregular)
        path.addCurve(
            to: CGPoint(x: (width + bodyWidth) / 2, y: height - 15),
            control1: CGPoint(x: (width - bodyWidth) / 2 + 10, y: height),
            control2: CGPoint(x: (width + bodyWidth) / 2 - 10, y: height)
        )
        
        // Right side up to shoulder
        path.addLine(to: CGPoint(x: (width + bodyWidth) / 2, y: shoulderHeight))
        
        // Right shoulder curve
        path.addCurve(
            to: CGPoint(x: (width + neckWidth) / 2, y: neckHeight),
            control1: CGPoint(x: (width + bodyWidth) / 2 - 5, y: shoulderHeight - 10),
            control2: CGPoint(x: (width + neckWidth) / 2 + 5, y: neckHeight + 10)
        )
        
        // Right neck
        path.addLine(to: CGPoint(x: (width + neckWidth) / 2, y: 20))
        
        // Top rim (slightly curved)
        path.addCurve(
            to: CGPoint(x: (width - neckWidth) / 2, y: 20),
            control1: CGPoint(x: (width + neckWidth) / 2 - 3, y: 15),
            control2: CGPoint(x: (width - neckWidth) / 2 + 3, y: 15)
        )
        
        // Left neck
        path.addLine(to: CGPoint(x: (width - neckWidth) / 2, y: neckHeight))
        
        // Left shoulder curve
        path.addCurve(
            to: CGPoint(x: (width - bodyWidth) / 2, y: shoulderHeight),
            control1: CGPoint(x: (width - neckWidth) / 2 - 5, y: neckHeight + 10),
            control2: CGPoint(x: (width - bodyWidth) / 2 + 5, y: shoulderHeight - 10)
        )
        
        // Close path
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Liquid with Wave Effect
struct LiquidBottleView: View {
    let fillLevel: CGFloat
    let waveOffset: CGFloat
    let secondaryWaveOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base liquid color
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#4A9B85"), // Lighter at top
                                Color(hex: "#2F6F5E")  // Emerald base
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height)
                    .offset(y: geometry.size.height * (1 - fillLevel))
                
                // Wave surface
                WaveShape(
                    progress: fillLevel,
                    waveHeight: 6,
                    phase: waveOffset
                )
                .fill(Color(hex: "#4A9B85").opacity(0.8))
                .frame(height: geometry.size.height)
                
                // Secondary wave for depth
                WaveShape(
                    progress: fillLevel,
                    waveHeight: 4,
                    phase: secondaryWaveOffset
                )
                .fill(Color(hex: "#5BA895").opacity(0.5))
                .frame(height: geometry.size.height)
            }
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    let progress: CGFloat
    let waveHeight: CGFloat
    let phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waterLevel = rect.height * (1 - progress)
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        
        // Create wave
        for x in stride(from: 0, to: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + phase)
            let y = waterLevel + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Supportive Message View
struct SupportiveMessageView: View {
    let message: String
    @Binding var isVisible: Bool
    
    // Supportive messages pool
    static let messages = [
        "Nice one",
        "That feed counts",
        "You're doing great",
        "Keep it up",
        "Well done",
        "Every feed matters",
        "You're nourishing them",
        "Gentle and steady",
        "One step at a time"
    ]
    
    static func random() -> String {
        messages.randomElement()!
    }
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color(hex: "#2F6F5E"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "#2F6F5E").opacity(0.1))
            )
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .animation(.easeOut(duration: 0.3), value: isVisible)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    VStack(spacing: 40) {
        BottleView(fillLevel: 0.3, isAnimating: false)
            .frame(height: 200)
        
        BottleView(fillLevel: 0.6, isAnimating: false)
            .frame(height: 200)
        
        BottleView(fillLevel: 0.85, isAnimating: false)
            .frame(height: 200)
    }
    .padding()
    .background(Color(hex: "F2F2F7"))
}
