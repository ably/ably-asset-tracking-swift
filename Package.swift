// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ably-asset-tracking-swift",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "AblyAssetTrackingSubscriber",
            targets: ["AblyAssetTrackingSubscriber"]),
        .library(name: "AblyAssetTrackingPublisher",
                 targets: ["AblyAssetTrackingPublisher"])
    ],
    dependencies: [
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", .exact("2.0.0-beta.12")),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.43.1"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.2"),
        .package(url: "https://github.com/ably/ably-cocoa", .branch("feature/819-SPM-support"))
    ],
    targets: [
        .target(
            name: "AblyAssetTrackingSubscriber",
            dependencies: [
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "AblyAssetTrackingPublisher",
            dependencies: [
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "MapboxNavigation"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "AblyAssetTrackingCore", dependencies: [
                    .product(name: "Ably", package: "ably-cocoa"),
                    .product(name: "Logging", package: "swift-log")
        ]),
        .testTarget(
            name: "AblyAssetTrackingSubscriberTests",
                    dependencies: [
                        "AblyAssetTrackingSubscriber",
                        .product(name: "Ably", package: "ably-cocoa"),
                       .product(name: "Logging", package: "swift-log")
                    ]),
        .testTarget(
            name: "AblyAssetTrackingPublisherTests",
            dependencies: [
                "AblyAssetTrackingSubscriber",
                .product(name: "Ably", package: "ably-cocoa"),
               .product(name: "Logging", package: "swift-log")
            ]),
    ]
)
