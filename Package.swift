// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ably-asset-tracking-swift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AblyAssetTrackingSubscriber",
            targets: ["AblyAssetTrackingSubscriber"]
        ),
        .library(
            name: "AblyAssetTrackingPublisher",
            targets: ["AblyAssetTrackingPublisher"]
        ),
        .library(
            name: "AblyAssetTrackingUI",
            targets: ["AblyAssetTrackingUI"]
        )
    ],
    dependencies: [
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", from: "2.3.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.2"),
        .package(url: "https://github.com/ably/ably-cocoa", from: "1.2.10")
    ],
    targets: [
        .target(
            name: "AblyAssetTrackingSubscriber",
            dependencies: [
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "AblyAssetTrackingPublisher",
            dependencies: [
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "MapboxNavigation"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "AblyAssetTrackingInternal",
            dependencies: [
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "AblyAssetTrackingCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "AblyAssetTrackingUI",
            dependencies: [
                "AblyAssetTrackingCore"
            ]),
        .testTarget(
            name: "SystemTests",
            dependencies: [
                "AblyAssetTrackingSubscriber",
                "AblyAssetTrackingPublisher",
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [.copy("Resources/test-locations.json")]),
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
            name: "InternalTests",
            dependencies: [
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "AblyAssetTrackingPublisher",
                .product(name: "Logging", package: "swift-log")
            ])
    ]
)
