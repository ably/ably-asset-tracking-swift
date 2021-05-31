// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ably-asset-tracking-swift",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "AblyAssetTracking-Subscriber",
            targets: ["AblyAssetTracking-Subscriber"]),
        .library(name: "AblyAssetTracking-Publisher",
                 targets: ["AblyAssetTracking-Publisher"])
    ],
    dependencies: [
        .package(name: "MapboxNavigation", url: "https://github.com/mapbox/mapbox-navigation-ios.git", .exact("2.0.0-beta.11")),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.43.1"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.2"),
//        .package(url: "https://github.com/ably/ably-cocoa", from: "1.2.4")
    ],
    targets: [
        .target(
            name: "AblyAssetTracking-Subscriber",
            dependencies: [
//                .product(name: "ably-cocoa", package: "ably-cocoa"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "AblyAssetTracking-Publisher",
            dependencies: [
//                .product(name: "ably-cocoa", package: "ably-cocoa"),
                .product(name: "MapboxNavigation", package: "MapboxNavigation"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(name: "AblyAssetTracking-Core", dependencies: [
//                    .product(name: "ably-cocoa", package: "ably-cocoa"),
                    .product(name: "Logging", package: "swift-log")]),
        // TODO do i need to depend on the SDKs in the test targets?
        .testTarget(
            name: "AblyAssetTracking-SubscriberTests",
                    dependencies: ["AblyAssetTracking-Subscriber", .product(name: "Logging", package: "swift-log")]),
        .testTarget(
            name: "AblyAssetTracking-PublisherTests",
            dependencies: ["AblyAssetTracking-Publisher", .product(name: "Logging", package: "swift-log")]),
    ]
)
