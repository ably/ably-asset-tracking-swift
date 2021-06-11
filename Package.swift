// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ably-asset-tracking-swift",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "AblyAssetTrackingSubscriber",
            targets: ["Subscriber"]),
        .library(name: "AblyAssetTrackingPublisher",
                 targets: ["Publisher"])
    ],
    dependencies: [
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", .exact("2.0.0-beta.12")),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.43.1"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.2"),
        .package(url: "https://github.com/ably/ably-cocoa", .branch("feature/819-SPM-support"))
    ],
    targets: [
        .target(
            name: "Subscriber",
            dependencies: [
                "Core",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "Publisher",
            dependencies: [
                "Core",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "MapboxNavigation"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "Core", dependencies: [
                    .product(name: "Ably", package: "ably-cocoa"),
                    .product(name: "Logging", package: "swift-log")
        ]),
        .testTarget(
            name: "SubscriberTests",
                    dependencies: [
                        "Subscriber",
                        .product(name: "Ably", package: "ably-cocoa"),
                       .product(name: "Logging", package: "swift-log")
                    ]),
        .testTarget(
            name: "PublisherTests",
            dependencies: [
                "Subscriber",
                .product(name: "Ably", package: "ably-cocoa"),
               .product(name: "Logging", package: "swift-log")
            ]),
    ]
)
