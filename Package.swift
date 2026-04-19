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
                "Info.plist",
                "Views/SevenDaysView.swift"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: []
        )
    ]
)
