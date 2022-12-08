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
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", from: "2.9.0"),
        .package(url: "https://github.com/ably/ably-cocoa", from: "1.2.17"),
        .package(url: "https://github.com/mxcl/Version", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "AblyAssetTrackingSubscriber",
            dependencies: [
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
            ]),
        .target(
            name: "AblyAssetTrackingPublisher",
            dependencies: [
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "MapboxNavigation"),
                .product(name: "Version", package: "Version")
            ]),
        .target(
            name: "AblyAssetTrackingInternal",
            dependencies: [
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa"),
            ]),
        .target(
            name: "AblyAssetTrackingCore",
            dependencies: []),
        .target(
            name: "AblyAssetTrackingUI",
            dependencies: [
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal",
            ]),
        .testTarget(
            name: "SystemTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingSubscriber",
                "AblyAssetTrackingPublisher",
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
            ],
            resources: [.copy("Resources/test-locations.json")]),
        .testTarget(
            name: "SubscriberTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingSubscriber"
            ]),
        .testTarget(
            name: "PublisherTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingPublisher"
            ],
            resources: [.copy("common")]),
        .testTarget(
            name: "InternalTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa")
            ]),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingPublisher"
            ]),
        .testTarget(
            name: "UITests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingUI"
            ]),
        .target(
            name: "AblyAssetTrackingCoreTesting",
            dependencies: [
                "AblyAssetTrackingCore"
            ],
            path: "Tests/Support/AblyAssetTrackingCoreTesting"
        ),
        .target(
            name: "AblyAssetTrackingInternalTesting",
            dependencies: [
                "AblyAssetTrackingInternal"
            ],
            path: "Tests/Support/AblyAssetTrackingInternalTesting"
        )
    ]
)
