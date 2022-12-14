// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogParser",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LogParser",
            targets: ["LogParser"]),
        .executable(
            name: "CommandLineExample",
            targets: ["CommandLineExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "LogParser"
        ),
        .testTarget(
            name: "LogParserTests",
            dependencies: ["LogParser"]
        ),
        .executableTarget(
            name: "CommandLineExample",
            dependencies: [
                "LogParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Examples/CommandLineExample/Sources"
        )
    ]
)
