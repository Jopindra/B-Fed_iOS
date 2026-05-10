import WidgetKit
import SwiftUI

// MARK: - Widget Data Store (duplicated for widget target)
enum WidgetDataStore {
    private static let suiteName = "group.com.bfed.B-Fed"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: suiteName) }
    
    static func feedCount() -> Int { defaults?.integer(forKey: "widget-feed-count") ?? 0 }
    static func totalAmount() -> Double { defaults?.double(forKey: "widget-total-amount") ?? 0 }
    static func babyName() -> String { defaults?.string(forKey: "widget-baby-name") ?? "Baby" }
}

// MARK: - Colors
private extension Color {
    static let inkPrimary = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let inkSecondary = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let almostAquaDark = Color(red: 0.35, green: 0.65, blue: 0.65)
    static let backgroundBase = Color(red: 0.98, green: 0.98, blue: 0.97)
}

// MARK: - Bottle Shape
private struct BottleOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.35
        let bodyWidth = width * 0.75
        let neckHeight = height * 0.25
        let shoulderHeight = height * 0.35
        
        path.move(to: CGPoint(x: (width - bodyWidth) / 2, y: height - 20))
        path.addCurve(
            to: CGPoint(x: (width + bodyWidth) / 2, y: height - 20),
            control1: CGPoint(x: (width - bodyWidth) / 2 + 10, y: height - 5),
            control2: CGPoint(x: (width + bodyWidth) / 2 - 10, y: height - 5)
        )
        path.addLine(to: CGPoint(x: (width + bodyWidth) / 2, y: shoulderHeight))
        path.addCurve(
            to: CGPoint(x: (width + neckWidth) / 2, y: neckHeight),
            control1: CGPoint(x: (width + bodyWidth) / 2 - 5, y: shoulderHeight - 10),
            control2: CGPoint(x: (width + neckWidth) / 2 + 5, y: neckHeight + 10)
        )
        path.addLine(to: CGPoint(x: (width + neckWidth) / 2, y: 25))
        path.addCurve(
            to: CGPoint(x: (width - neckWidth) / 2, y: 25),
            control1: CGPoint(x: (width + neckWidth) / 2 - 3, y: 20),
            control2: CGPoint(x: (width - neckWidth) / 2 + 3, y: 20)
        )
        path.addLine(to: CGPoint(x: (width - neckWidth) / 2, y: neckHeight))
        path.addCurve(
            to: CGPoint(x: (width - bodyWidth) / 2, y: shoulderHeight),
            control1: CGPoint(x: (width - neckWidth) / 2 - 5, y: neckHeight + 10),
            control2: CGPoint(x: (width - bodyWidth) / 2 + 5, y: shoulderHeight - 10)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), feedCount: 5, totalAmount: 450, babyName: "Baby")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            feedCount: WidgetDataStore.feedCount(),
            totalAmount: WidgetDataStore.totalAmount(),
            babyName: WidgetDataStore.babyName()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            feedCount: WidgetDataStore.feedCount(),
            totalAmount: WidgetDataStore.totalAmount(),
            babyName: WidgetDataStore.babyName()
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let feedCount: Int
    let totalAmount: Double
    let babyName: String
}

struct B_FedWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.almostAquaDark)
                Text(entry.babyName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
            }
            
            Spacer()
            
            Text("\(Int(entry.totalAmount))")
                .font(.system(size: 32, weight: .medium, design: .serif))
                .foregroundStyle(Color.inkPrimary)
            
            Text("ml today")
                .font(.system(size: 12))
                .foregroundStyle(Color.inkSecondary)
            
            Text("\(entry.feedCount) feeds")
                .font(.system(size: 11))
                .foregroundStyle(Color.inkSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.backgroundBase)
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.almostAquaDark)
                    Text(entry.babyName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.inkPrimary)
                }
                
                Spacer()
                
                Text("\(Int(entry.totalAmount)) ml")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(Color.inkPrimary)
                
                Text("\(entry.feedCount) feeds today")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.inkSecondary)
            }
            
            Spacer()
            
            ZStack {
                BottleOutlineShape()
                    .stroke(Color.inkSecondary.opacity(0.2), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 40, height: 64)
                
                BottleOutlineShape()
                    .fill(Color.almostAquaDark.opacity(0.3))
                    .frame(width: 40, height: 64)
                    .clipShape(BottleOutlineShape())
                    .mask(
                        VStack {
                            Spacer()
                            Rectangle()
                                .frame(height: 40)
                        }
                    )
            }
        }
        .padding(16)
        .background(Color.backgroundBase)
    }
}

struct B_FedWidget: Widget {
    let kind: String = "B_FedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            B_FedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("B-Fed Summary")
        .description("See today's feeding summary at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    B_FedWidget()
} timeline: {
    SimpleEntry(date: .now, feedCount: 5, totalAmount: 450, babyName: "Lily")
}
