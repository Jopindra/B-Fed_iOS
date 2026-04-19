// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "B-Fed",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BFed", targets: ["BFed"])
    ],
    targets: [
        .target(
            name: "BFed",
            path: "B-Fed",
            exclude: [
                "B_FedApp.swift",
                "Views/DashboardView.swift",
                "Views/LogFeedView.swift",
                "Views/FeedHistoryView.swift",
                "Views/StatisticsView.swift",
                "Views/MonthView.swift",
                "Views/SevenDaysView.swift",
                "Views/BottleView.swift",
                "Views/BabyBottleView.swift",
                "Views/ContentView.swift",
                "Info.plist"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        )
    ]
)
