// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogParserExample",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(path: "../LogParser")
    ],
    targets: [
        .executableTarget(
            name: "LogParserExample",
            dependencies: [
                .product(name: "LogParser", package: "LogParser"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
