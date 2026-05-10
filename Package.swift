// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "B-Fed",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BFed", targets: ["BFed"])
    ],
    targets: [
        .target(
            name: "BFed",
            path: "B-Fed",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: []
        ),
        .testTarget(
            name: "BFedTests",
            dependencies: ["BFed"],
            path: "B-FedTests"
        )
    ]
)
