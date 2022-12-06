// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyzeLocationEventFrequencies",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(path: "../../Library/LogParser")
    ],
    targets: [
        .executableTarget(
            name: "AnalyzeLocationEventFrequencies",
            dependencies: [
                .product(name: "LogParser", package: "LogParser"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
