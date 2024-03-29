// swift-tools-version:5.7
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
        .package(url: "https://github.com/mapbox/mapbox-navigation-ios.git", from: "2.9.0"),
        .package(url: "https://github.com/ably/ably-cocoa", from: "1.2.20"),
        .package(url: "https://github.com/mxcl/Version", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "AblyAssetTrackingSubscriber",
            dependencies: [
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa")
            ]
        ),
        .target(
            name: "AblyAssetTrackingPublisher",
            dependencies: [
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal",
                .product(name: "Ably", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "mapbox-navigation-ios"),
                .product(name: "Version", package: "Version")
            ]
        ),
        .target(
            name: "AblyAssetTrackingInternal",
            dependencies: [
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa")
            ]
        ),
        .target(
            name: "AblyAssetTrackingCore",
            dependencies: [
                .product(name: "Ably", package: "ably-cocoa")
            ]
        ),
        .target(
            name: "AblyAssetTrackingUI",
            dependencies: [
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal"
            ]
        ),
        .testTarget(
            name: "SystemTests",
            dependencies: [
                "AblyAssetTrackingTesting",
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingSubscriberTesting",
                "AblyAssetTrackingPublisherTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingSubscriber",
                "AblyAssetTrackingPublisher",
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore"
            ],
            resources: [.copy("Resources/test-locations.json")]
        ),
        .testTarget(
            name: "SubscriberTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingSubscriberTesting",
                "AblyAssetTrackingSubscriber"
            ]
        ),
        .testTarget(
            name: "PublisherTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingPublisherTesting",
                "AblyAssetTrackingPublisher"
            ],
            resources: [.copy("common")]
        ),
        .testTarget(
            name: "InternalTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingInternalTesting",
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingCore",
                .product(name: "Ably", package: "ably-cocoa")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingPublisher"
            ]
        ),
        .testTarget(
            name: "UITests",
            dependencies: [
                "AblyAssetTrackingCoreTesting",
                "AblyAssetTrackingUI"
            ]
        ),
        .target(
            name: "AblyAssetTrackingTesting",
            dependencies: [
                "AblyAssetTrackingTestingObjC",
                "AblyAssetTrackingCore",
                "AblyAssetTrackingInternal"
            ],
            path: "Tests/Support/AblyAssetTrackingTesting"
        ),
        .target(
            name: "AblyAssetTrackingTestingObjC",
            dependencies: [],
            path: "Tests/Support/AblyAssetTrackingTestingObjC"
        ),
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
                "AblyAssetTrackingInternal",
                "AblyAssetTrackingTesting"
            ],
            path: "Tests/Support/AblyAssetTrackingInternalTesting"
        ),
        .target(
            name: "AblyAssetTrackingSubscriberTesting",
            dependencies: [
                "AblyAssetTrackingSubscriber"
            ],
            path: "Tests/Support/AblyAssetTrackingSubscriberTesting"
        ),
        .target(
            name: "AblyAssetTrackingPublisherTesting",
            dependencies: [
                "AblyAssetTrackingPublisher"
            ],
            path: "Tests/Support/AblyAssetTrackingPublisherTesting"
        )
    ]
)
