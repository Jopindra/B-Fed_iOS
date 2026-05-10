import SwiftUI

struct FeedBubbleArcView: View {
    let feeds: [Feed]
    let geometry: GeometryProxy
    var onSeeAllTapped: () -> Void = {}
    
    // MARK: - Arc Geometry
    private var centreX: CGFloat { geometry.size.width * 0.50 }
    private var centreY: CGFloat { geometry.size.height * 0.38 }
    private var radius: CGFloat { geometry.size.width * 0.40 }
    
    // Slot angles in degrees (Swift cos/sin use radians)
    private let slotAngles: [Double] = [210, 270, 330]
    
    // MARK: - Visible Feeds (max 3, most recent first)
    private var visibleFeeds: [Feed] {
        Array(feeds.prefix(3))
    }
    
    private var hasFeeds: Bool {
        !feeds.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Section header
            sectionHeader
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)
            
            if hasFeeds {
                arcWithBubbles
            } else {
                emptyState
            }
        }
    }
    
    // MARK: - Section Header
    private var sectionHeader: some View {
        HStack {
            Text("LAST 4 HOURS")
                .font(AppFont.sans(9, weight: .semibold))
                .foregroundStyle(Color.inkSecondary)
                .tracking(0.4)
            
            Spacer()
            
            Button(action: onSeeAllTapped) {
                Text("see all")
                    .font(AppFont.sans(9, weight: .regular))
                    .foregroundStyle(Color.orchidTintDark)
            }
        }
    }
    
    // MARK: - Arc with Bubbles
    private var arcWithBubbles: some View {
        ZStack {
            // Background arc track
            arcTrack
            
            // Bubbles and ghost circles
            ForEach(0..<3, id: \.self) { slotIndex in
                let position = pointOnArc(angleDegrees: slotAngles[slotIndex])
                
                if let feed = feedForSlot(slotIndex) {
                    // Active bubble
                    feedBubble(feed: feed, slotIndex: slotIndex)
                        .position(position)
                } else {
                    // Ghost circle
                    ghostCircle
                        .position(position)
                }
            }
        }
        .frame(height: radius * 2)
    }
    
    // MARK: - Arc Track
    private var arcTrack: some View {
        ArcShape(
            centreX: centreX,
            centreY: centreY,
            radius: radius,
            startAngle: .degrees(200),
            endAngle: .degrees(340)
        )
        .stroke(
            Color.inkPrimary.opacity(AppMetrics.borderOpacity),
            style: StrokeStyle(lineWidth: 5, lineCap: .round)
        )
    }
    
    // MARK: - Feed Bubble
    private func feedBubble(feed: Feed, slotIndex: Int) -> some View {
        let bubbleRadius = bubbleRadius(for: feed.amount)
        let fontSize = bubbleFontSize(for: bubbleRadius)
        let fillColor = bubbleFillColor(slotIndex: slotIndex)
        let textColor = bubbleTextColor(slotIndex: slotIndex)
        let timeString = timeString(for: feed.startTime)
        
        return VStack(spacing: 2) {
            // Bubble
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)
                
                VStack(spacing: 0) {
                    Text("\(Int(feed.amount))")
                        .font(AppFont.sans(fontSize, weight: .semibold))
                        .foregroundStyle(textColor)
                    
                    Text("ml")
                        .font(AppFont.caption)
                        .foregroundStyle(textColor)
                        .opacity(0.9)
                }
            }
            
            // Time label below bubble
            Text(timeString)
                .font(AppFont.caption)
                .foregroundStyle(Color.orchidTintDark)
                .padding(.top, AppSpacing.md)
        }
    }
    
    // MARK: - Ghost Circle
    private var ghostCircle: some View {
        Circle()
            .stroke(
                Color.inkPrimary.opacity(AppMetrics.borderOpacity),
                style: StrokeStyle(
                    lineWidth: 1.5,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [3, 4]
                )
            )
            .frame(width: 36, height: 36)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            MinimalBottleOutline()
                .stroke(Color.peachDust, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 50, height: 80)
            
            Text("No feeds yet today")
                .font(AppFont.serif(16))
                .foregroundStyle(Color.inkPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helpers
    
    private func pointOnArc(angleDegrees: Double) -> CGPoint {
        let radians = angleDegrees * .pi / 180
        let x = centreX + radius * cos(radians)
        let y = centreY + radius * sin(radians)
        return CGPoint(x: x, y: y)
    }
    
    private func feedForSlot(_ slotIndex: Int) -> Feed? {
        // Map feeds to slots:
        // Slot 0 (left, 210°):   oldest visible feed
        // Slot 1 (centre, 270°): middle feed (if 3) or single feed (if 1)
        // Slot 2 (right, 330°):  most recent feed
        
        let count = visibleFeeds.count
        guard count > 0 else { return nil }
        
        switch count {
        case 1:
            // 1 feed → centred (slot 1)
            return slotIndex == 1 ? visibleFeeds[0] : nil
        case 2:
            // 2 feeds → slots 0 and 2 (left and right)
            if slotIndex == 0 { return visibleFeeds[1] } // older
            if slotIndex == 2 { return visibleFeeds[0] } // most recent
            return nil
        default:
            // 3 feeds → all 3 slots
            // visibleFeeds[0] = most recent → slot 2 (right)
            // visibleFeeds[1] = middle → slot 1 (centre)
            // visibleFeeds[2] = oldest → slot 0 (left)
            if slotIndex == 0 { return visibleFeeds[2] }
            if slotIndex == 1 { return visibleFeeds[1] }
            if slotIndex == 2 { return visibleFeeds[0] }
            return nil
        }
    }
    
    private func bubbleRadius(for amount: Double) -> CGFloat {
        switch amount {
        case ..<60:    return 18
        case 60...100: return 20
        case 101...140: return 23
        case 141...180: return 26
        default:        return 29
        }
    }
    
    private func bubbleFontSize(for bubbleRadius: CGFloat) -> CGFloat {
        // Linear interpolation: 18pt radius → 9pt font, 26pt → 13pt font
        // slope = (13 - 9) / (26 - 18) = 4 / 8 = 0.5
        // fontSize = 9 + (radius - 18) * 0.5
        9 + (bubbleRadius - 18) * 0.5
    }
    
    private func bubbleFillColor(slotIndex: Int) -> Color {
        let count = visibleFeeds.count
        
        // Determine recency rank for this slot
        // Most recent feed = visibleFeeds[0]
        // In 1-feed case: slot 1 = most recent
        // In 2-feed case: slot 2 = most recent, slot 0 = second
        // In 3-feed case: slot 2 = most recent, slot 1 = second, slot 0 = oldest
        
        let recencyRank: Int // 0 = most recent, 1 = second, 2 = oldest
        switch count {
        case 1:
            recencyRank = (slotIndex == 1) ? 0 : -1
        case 2:
            if slotIndex == 2 { recencyRank = 0 }
            else if slotIndex == 0 { recencyRank = 1 }
            else { recencyRank = -1 }
        default:
            if slotIndex == 2 { recencyRank = 0 }
            else if slotIndex == 1 { recencyRank = 1 }
            else if slotIndex == 0 { recencyRank = 2 }
            else { recencyRank = -1 }
        }
        
        switch recencyRank {
        case 0: return Color.peachDustDark.opacity(0.80)
        case 1: return Color.peachDust.opacity(0.75)
        case 2: return Color.peachDustLight.opacity(0.80)
        default: return Color.clear
        }
    }
    
    private func bubbleTextColor(slotIndex: Int) -> Color {
        let count = visibleFeeds.count
        
        let isMostRecent: Bool
        switch count {
        case 1:
            isMostRecent = (slotIndex == 1)
        case 2:
            isMostRecent = (slotIndex == 2)
        default:
            isMostRecent = (slotIndex == 2)
        }
        
        return isMostRecent ? Color.backgroundCard : Color.inkPrimary
    }
    
    private func timeString(for date: Date) -> String {
        return AppFormatters.compactTime.string(from: date).lowercased()
    }
}

// MARK: - Arc Shape
struct ArcShape: Shape {
    let centreX: CGFloat
    let centreY: CGFloat
    let radius: CGFloat
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: centreX, y: centreY),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// MARK: - Minimal Bottle Outline
struct MinimalBottleOutline: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        
        // Proportions
        let teatW = w * 0.30
        let teatH = h * 0.10
        let collarW = w * 0.55
        let collarH = h * 0.06
        let shoulderY = h * 0.22
        let bodyW = w * 0.80
        let bodyBottomY = h * 0.92
        let cornerR = w * 0.12
        
        var path = Path()
        
        // Start at top of teat
        let topX = w / 2
        let topY = h * 0.02
        path.move(to: CGPoint(x: topX - teatW / 2, y: topY + teatH * 0.4))
        
        // Teat left curve
        path.addQuadCurve(
            to: CGPoint(x: topX - teatW / 2, y: topY + teatH),
            control: CGPoint(x: topX - teatW / 2 - w * 0.02, y: topY + teatH * 0.5)
        )
        
        // Collar left
        path.addLine(to: CGPoint(x: topX - collarW / 2, y: topY + teatH + collarH))
        
        // Shoulder left curve
        path.addQuadCurve(
            to: CGPoint(x: topX - bodyW / 2, y: shoulderY + cornerR),
            control: CGPoint(x: topX - bodyW / 2, y: shoulderY)
        )
        
        // Body left
        path.addLine(to: CGPoint(x: topX - bodyW / 2, y: bodyBottomY - cornerR))
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: topX - bodyW / 2 + cornerR, y: bodyBottomY - cornerR),
            radius: cornerR,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        
        // Bottom
        path.addLine(to: CGPoint(x: topX + bodyW / 2 - cornerR, y: bodyBottomY))
        
        // Bottom right corner
        path.addArc(
            center: CGPoint(x: topX + bodyW / 2 - cornerR, y: bodyBottomY - cornerR),
            radius: cornerR,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )
        
        // Body right
        path.addLine(to: CGPoint(x: topX + bodyW / 2, y: shoulderY + cornerR))
        
        // Shoulder right curve
        path.addQuadCurve(
            to: CGPoint(x: topX + collarW / 2, y: topY + teatH + collarH),
            control: CGPoint(x: topX + bodyW / 2, y: shoulderY)
        )
        
        // Collar right
        path.addLine(to: CGPoint(x: topX + teatW / 2, y: topY + teatH))
        
        // Teat right curve
        path.addQuadCurve(
            to: CGPoint(x: topX + teatW / 2, y: topY + teatH * 0.4),
            control: CGPoint(x: topX + teatW / 2 + w * 0.02, y: topY + teatH * 0.5)
        )
        
        // Teat top curve
        path.addQuadCurve(
            to: CGPoint(x: topX - teatW / 2, y: topY + teatH * 0.4),
            control: CGPoint(x: topX, y: topY - h * 0.02)
        )
        
        path.closeSubpath()
        return path
    }
}
