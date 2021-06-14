// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ably-asset-tracking-swift",
    platforms: [.iOS(.v12), .macOS(.v10_11), .tvOS(.v10)],
    products: [
        .library(
            name: "AblyAssetTrackingSubscriber",
            targets: ["AblyAssetTrackingSubscriber"]
        ),
        .library(name: "AblyAssetTrackingPublisher",
                 targets: ["AblyAssetTrackingPublisher"]
        )
    ],
    dependencies: [
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", .exact("2.0.0-beta.13")),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.43.1"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.2"),
        // TODO Release a version of Ably-cocoa supporting SPM and use it here.
//        .package(url: "https://github.com/ably/ably-cocoa", from: "NEW_VERSION"),
        .package(url: "/Users/zen/repos/ably/ably-cocoa", .branch("feature/ben-butterworth-spm-support"))
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
            name: "SubscriberTests",
                    dependencies: [
                        "AblyAssetTrackingSubscriber",
                       .product(name: "Logging", package: "swift-log")
                    ]),
        .testTarget(
            name: "PublisherTests",
            dependencies: [
                "AblyAssetTrackingPublisher",
               .product(name: "Logging", package: "swift-log")
            ]),
        .testTarget(
            name: "SystemTests",
            dependencies: [
                "AblyAssetTrackingSubscriber",
                "AblyAssetTrackingPublisher",
               .product(name: "Logging", package: "swift-log")
            ]),
    ]
)
