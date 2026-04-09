// MARK: - B-Fed Motion System
// Calm, fluid, reassuring animation language

import SwiftUI

// MARK: - Motion Timing Constants
enum MotionDuration {
    /// Breathing loop duration (slow, calm)
    static let breathing: Double = 3.5
    
    /// Liquid rise animation
    static let liquidRise: Double = 0.8
    
    /// Screen transitions
    static let screenTransition: Double = 0.35
    
    /// Interaction feedback (quick but soft)
    static let interaction: Double = 0.12
    
    /// Stagger delay for layered animations
    static let stagger: Double = 0.08
}

// MARK: - Motion Curves
enum MotionCurve {
    /// Primary easing - smooth acceleration/deceleration
    static let standard: Animation = .easeInOut(duration: MotionDuration.screenTransition)
    
    /// Breathing animation - gentle sine-like motion
    static let breathing: Animation = .easeInOut(duration: MotionDuration.breathing)
    
    /// Liquid movement - slightly slower at end
    static let liquid: Animation = .easeOut(duration: MotionDuration.liquidRise)
    
    /// Interaction - quick but soft
    static let interaction: Animation = .easeInOut(duration: MotionDuration.interaction)
    
    /// Spring replacement - gentle return (no bounce)
    static let gentleReturn: Animation = .easeOut(duration: 0.25)
}

// MARK: - Breathing Animation Modifier
struct BreathingAnimation: ViewModifier {
    let intensity: Double
    let verticalOffset: Double
    let delay: Double
    
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: sin(phase + delay) * verticalOffset)
            .scaleEffect(1.0 + sin(phase + delay) * intensity)
            .onAppear {
                withAnimation(MotionCurve.breathing.repeatForever(autoreverses: true)) {
                    phase = .pi * 2
                }
            }
    }
}

extension View {
    /// Apply gentle breathing animation
    func breathing(intensity: Double = 0.02, verticalOffset: Double = 2.0, delay: Double = 0) -> some View {
        modifier(BreathingAnimation(intensity: intensity, verticalOffset: verticalOffset, delay: delay))
    }
}

// MARK: - Gentle Press Effect
struct GentlePressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(MotionCurve.interaction, value: configuration.isPressed)
    }
}

// MARK: - Screen Transition Modifier
struct ScreenTransition: ViewModifier {
    let isActive: Bool
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : offset)
            .animation(MotionCurve.standard, value: isActive)
    }
}

extension View {
    /// Apply screen transition animation
    func screenTransition(isActive: Bool, offset: CGFloat = 10) -> some View {
        modifier(ScreenTransition(isActive: isActive, offset: offset))
    }
}

// MARK: - Staggered Appearance
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let baseDelay: Double
    
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 8)
            .onAppear {
                withAnimation(MotionCurve.standard.delay(baseDelay + Double(index) * MotionDuration.stagger)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Staggered appearance for list items
    func staggered(index: Int, baseDelay: Double = 0.1) -> some View {
        modifier(StaggeredAppearance(index: index, baseDelay: baseDelay))
    }
}
