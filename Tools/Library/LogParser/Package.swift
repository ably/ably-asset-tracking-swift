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
            targets: ["LogParser"]
        )
    ],
    targets: [
        .target(
            name: "LogParser"
        ),
        .testTarget(
            name: "LogParserTests",
            dependencies: ["LogParser"]
        )
    ]
)
