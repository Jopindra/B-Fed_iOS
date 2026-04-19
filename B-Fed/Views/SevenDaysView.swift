import SwiftUI

struct SevenDaysView: View {
    @Environment(FeedStore.self) private var store
    @State private var weekData: [DayRhythm] = []
    @State private var insights: [String] = []
    @State private var wavePhase: CGFloat = 0
    @State private var isVisible: Bool = false
    
    struct DayRhythm: Identifiable {
        let id = UUID()
        let day: String
        let amount: CGFloat
        let actualMl: Int
        let isToday: Bool
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Period toggle
            PeriodToggle(selectedPeriod: .constant(.last7Days), onTodayTap: {
                store.selectedPeriod = .today
            })
            .padding(.bottom, 4)
            
            // Header
            headerSection
            
            Spacer().frame(height: 12)
            
            // Main wave visual with scale
            waveSectionWithScale
                .frame(height: 180)
            
            Spacer().frame(height: 20)
            
            // Intelligent Insights
            insightsSection
            
            Spacer().frame(height: 16)
            
            // Stats
            statsSection
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            generateWeekData()
            loadInsights()
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Your week")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("A gentle rhythm of feeding")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
    
    private var waveSectionWithScale: some View {
        GeometryReader { geometry in
            ZStack {
                RadialGradient(
                    colors: [Color.emerald.opacity(0.06), Color.clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: geometry.size.width * 0.7
                )
                
                ScaleReferenceLines(width: geometry.size.width, height: geometry.size.height)
                
                RhythmWave(data: weekData, phase: wavePhase)
                    .stroke(
                        Color.emerald,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round)
                    )
                
                RhythmWave(data: weekData, phase: wavePhase)
                    .fill(
                        LinearGradient(
                            colors: [Color.emerald.opacity(0.08), Color.emerald.opacity(0.02), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                ScaleLabels(width: geometry.size.width, height: geometry.size.height)
                
                if let todayIndex = weekData.firstIndex(where: { $0.isToday }) {
                    TodayIndicator(
                        data: weekData,
                        todayIndex: todayIndex,
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(insights.prefix(2), id: \.self) { insight in
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.emerald.opacity(0.8))
                    
                    Text(insight)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 0) {
            GentleStat(value: "5.2", label: "feeds", sublabel: "per day")
            
            Divider()
                .frame(height: 40)
                .opacity(0.3)
            
            GentleStat(value: "108", label: "ml", sublabel: "average")
            
            Divider()
                .frame(height: 40)
                .opacity(0.3)
            
            GentleStat(value: "3h", label: "apart", sublabel: "spacing")
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "F2F2F7").opacity(0.5))
        )
    }
    
    private func generateWeekData() {
        weekData = [
            DayRhythm(day: "Mon", amount: 0.6, actualMl: 90, isToday: false),
            DayRhythm(day: "Tue", amount: 0.85, actualMl: 130, isToday: false),
            DayRhythm(day: "Wed", amount: 0.9, actualMl: 140, isToday: false),
            DayRhythm(day: "Thu", amount: 0.75, actualMl: 115, isToday: false),
            DayRhythm(day: "Fri", amount: 0.8, actualMl: 125, isToday: true),
            DayRhythm(day: "Sat", amount: 0.5, actualMl: 75, isToday: false),
            DayRhythm(day: "Sun", amount: 0.65, actualMl: 100, isToday: false)
        ]
    }
    
    private func loadInsights() {
        insights = [
            "Most feeds happen between 8–11am",
            "Feeds are becoming more consistent"
        ]
    }
}

// MARK: - Supporting Views (same as before)
private struct ScaleReferenceLines: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let baseY = height * 0.75
        let amplitude = height * 0.45
        
        ZStack {
            referenceLine(y: baseY - 1.0 * amplitude)
            referenceLine(y: baseY - 0.65 * amplitude)
            referenceLine(y: baseY - 0.3 * amplitude)
        }
    }
    
    private func referenceLine(y: CGFloat) -> some View {
        HStack(spacing: 4) {
            HStack(spacing: 3) {
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(Color.emerald.opacity(0.08))
                        .frame(width: 2, height: 2)
                }
            }
            Spacer()
        }
        .position(x: width * 0.42, y: y)
    }
}

private struct ScaleLabels: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let baseY = height * 0.75
        let amplitude = height * 0.45
        
        ZStack(alignment: .trailing) {
            scaleLabel("150", y: baseY - 1.0 * amplitude)
            scaleLabel("100", y: baseY - 0.65 * amplitude)
            scaleLabel("50", y: baseY - 0.3 * amplitude)
        }
        .frame(width: width, height: height)
    }
    
    private func scaleLabel(_ text: String, y: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color.emerald.opacity(0.35))
            .position(x: width - 16, y: y)
    }
}

private struct TodayIndicator: View {
    let data: [SevenDaysView.DayRhythm]
    let todayIndex: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let stepX = width / CGFloat(data.count - 1)
        let x = stepX * CGFloat(todayIndex)
        let baseY = height * 0.75
        let amplitude = height * 0.45
        let y = baseY - data[todayIndex].amount * amplitude
        
        ZStack {
            Circle()
                .fill(Color.emerald.opacity(0.15))
                .frame(width: 24, height: 24)
                .blur(radius: 8)
            
            Circle()
                .fill(Color.emerald.opacity(0.6))
                .frame(width: 8, height: 8)
        }
        .position(x: x, y: y)
    }
}

private struct GentleStat: View {
    let value: String
    let label: String
    let sublabel: String
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(sublabel)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.emerald.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - Rhythm Wave Shape
struct RhythmWave: Shape {
    let data: [SevenDaysView.DayRhythm]
    let phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count >= 2 else { return path }
        
        let width = rect.width
        let height = rect.height
        let stepX = width / CGFloat(data.count - 1)
        let baseY = height * 0.75
        let amplitude = height * 0.45
        
        let startY = baseY - data[0].amount * amplitude
        path.move(to: CGPoint(x: 0, y: startY))
        
        for i in 0..<(data.count - 1) {
            let x1 = stepX * CGFloat(i)
            let x2 = stepX * CGFloat(i + 1)
            let y1 = baseY - data[i].amount * amplitude
            let y2 = baseY - data[i + 1].amount * amplitude
            
            let waveOffset = sin(CGFloat(i) * 0.8 + phase) * 3
            
            path.addCurve(
                to: CGPoint(x: x2, y: y2),
                control1: CGPoint(x: x1 + stepX * 0.5, y: y1 + waveOffset),
                control2: CGPoint(x: x2 - stepX * 0.5, y: y2 + waveOffset)
            )
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

private extension Color {
    static var emerald: Color {
        Color(red: 0.18, green: 0.44, blue: 0.37)
    }
}

#Preview {
    SevenDaysView()
        .background(Color.white)
        .environment(FeedStore())
}
