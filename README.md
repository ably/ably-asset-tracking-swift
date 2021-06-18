# Ably Asset Tracking SDKs for Cocoa

![.github/workflows/check.yml](https://github.com/ably/ably-asset-tracking-swift/workflows/.github/workflows/check.yml/badge.svg)

## Overview

Ably Asset Tracking SDKs provide an easy way to track multiple assets with realtime location updates powered by [Ably](https://ably.com/) realtime network and Mapbox [Navigation SDK](https://docs.mapbox.com/android/navigation/overview/) with location enhancement.

**Status:** this is a beta version of the SDKs. That means that it contains a subset of the final SDK functionality, and the APIs are subject to change. The latest release of the SDKs is available in the [Releases section](https://github.com/ably/ably-asset-tracking-swift/releases) of this repository.

Ably Asset Tracking is:

- **easy to integrate** - comprising two complementary SDKs with easy to use APIs, available for multiple platforms:
    - Asset Publishing SDK, for embedding in apps running on the courier's device
    - Asset Subscribing SDK, for embedding in apps runnong on the customer's observing device
- **extensible** - as Ably is used as the underlying transport, you have direct access to your data and can use Ably integrations for a wide range of applications in addition to direct realtime subscriptions - examples include:
    - passing to a 3rd party system
    - persistence for later retrieval
- **built for purpose** - the APIs and underlying functionality are designed specifically to meet the requirements of a range of common asset tracking use-cases

This repo holds an Xcode workspace (`AblyAssetTracking.workspace`), containing:
- Multiple example apps/ Xcode projects, and
- One Swift Package (`ably-asset-tracking-swift`), containing 2 libraries/ SDKs:
   - Publisher SDK: The `AblyAssetTrackingPublisher` library allows you to use `import AblyAssetTrackingCore` and `import AblyAssetTrackingPublisher`.
   - Subscriber SDK: The `AblyAssetTrackingSubscriber` library allows you to use `import AblyAssetTrackingCore` and `import AblyAssetTrackingSubscriber`.

### Documentation

Visit the [Ably Asset Tracking](https://ably.com/documentation/asset-tracking) documentation for a complete API reference and code examples.

### Useful Resources

- [Introducing Ably Asset Tracking - public beta now available](https://ably.com/blog/ably-asset-tracking-beta)
- [Accurate Delivery Tracking with Navigation SDK + Ably Realtime Network](https://www.mapbox.com/blog/accurate-delivery-tracking)

## Requirements

These SDKs support support iOS and iPadOS. Support for macOS/ tvOS may be developed in the future, depending on interest/ demand.
- Publisher SDK: iOS 12.0+ / iPadOS 12.0+
- Subscriber SDK: iOS 12.0+ / iPadOS 12.0+
- Xcode 12.4+
- Swift 5.3+

## Installation

### Swift package manager
- To install this package in an **Xcode Project**:
    - Paste `https://github.com/ably/ably-asset-tracking-swift` in the "Swift Packages" search box. (Xcode project > Swift Packages.. > `+` button)
    - Select the relevant SDK for your target. (Publisher SDK, Subscriber SDK or both)
    - [This apple guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) explains the steps in more detail.
- To install this package into a **Swift Package**, add the following to your manifest (`Package.swift`):

  ```swift
  .package(url: "https://github.com/ably/ably-asset-tracking-swift", from: LATEST_VERSION),
  ```

## Usage

### Publisher SDK

The Asset Publisher SDK can be used to efficiently acquire the location data on a device, and publish location updates to other subscribers in real time. Here is an example of how the Asset Publisher SDK can be used:

```swift
// Import relevant modules
import AblyAssetTrackingCore
import AblyAssetTrackingPublisher

// Initialise a Publisher
publisher = try? PublisherFactory.publishers() // get a Publisher Builder
  .connection(ConnectionConfiguration(apiKey: ABLY_API_KEY,
                                      clientId: CLIENT_ID)) // provide Ably configuration with credentials
  .log(LogConfiguration()) // provide logging configuration
  .transportationMode(TransportationMode()) // provide mode of transportation for better location enhancements
  .delegate(self) // provide delegate to handle location updates locally if needed
  .start()

// Start tracking an asset
publisher?.track(trackable: Trackable(id: trackingId)) // provide a tracking ID of the asset
```

## Subscriber SDK 

The Asset Subscriber SDK can be used to receive location updates from a publisher in realtime. Here is an example of how Asset Subscribing SDK can be used:

```swift
// Import relevant modules
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber

// Initialise a Subscriber
subscriber = try? SubscriberFactory.subscribers() // get a Subscriber Builder
  .connection(ConnectionConfiguration(apiKey: ABLY_API_KEY,
                                      clientId: CLIENT_ID)) // provide Ably configuration with credentials
  .trackingId(trackingId) // provide a Tracking ID for the asset to be tracked
  .routingProfile(.cycling) // provide a routing profile for better location enhancements
  .log(LogConfiguration()) // provide logging configuration
  .delegate(self) // provide a delegate to handle received location updates
  .start() // start listening to updates
```

## Example Apps

- Configure your mapbox credentials (`~/.netrc`) to download the Mapbox SDK by following [this](https://docs.mapbox.com/ios/search/guides/install/#configure-credentials) guide. You'll need a Mapbox account. 

- An `Examples/Secrets.xcconfig` file containing credentials (keys/ tokens) is required to build the example apps. (You can use the example `Examples/Example.Secrets.xcconfig`, e.g. by running `cp Examples/Example.Secrets.xcconfig Examples/Secrets.xcconfig`). Update the following values in `Examples/Secrets.xcconfig`:
  - `ABLY_API_KEY`: Used by all example apps to authenticate with Ably using basic authentication. Not recommended in production, and can be taken from [here](https://ably.com/accounts).
  - `MAPBOX_ACCESS_TOKEN`: Used to access Mapbox Navigation SDK/ APIs, and can be taken from [here](https://account.mapbox.com/). This is only required to run the **Publisher** example apps.
- Open `AblyAssetTracking.xcworkspace` to open a Xcode workspace containing example apps and the Swift Package containing the SDKs that showcase how Ably Asset Tracking SDKs can be used.

## Development

### Getting started
Set up a `~/.netrc` file by following the [Example Apps](#example-apps) section. You'll also need the `Examples/Secrets.xcconfig` to run the example applications. 
### Package structure

These SDKs (libraries/ product in Swift Package terminology) expose targets, which can be imported into a users source code file. We have 4 targets, `AblyAssetTrackingCore`, `AblyAssetTrackingInternal`, `AblyAssetTrackingPublisher` and `AblyAssetTrackingSubscriber`. Internal is the only target not exposed (not `import`able) to users, and is ideal for interfacing with Ably-cocoa in order to hide ably-cocoa interfaces from end users. All public entities in other targets, such as `AblyAssetTrackingCore`, are importable by users, by using `import AblyAssetTrackingCore`. All public entities in `AblyAssetTrackingInternal` are public to other targets in the same package, but not to users. 

**Note:** The user currently has to import both targets in their code to use entities in both Core and Publisher (or Subscriber). In the future, we may expose both `AblyAssetTrackingCore` and `AblyAssetTrackingPublisher` through one target using `@_exported`, so users only need to import one module. Similarly, a new target that joins `AblyAssetTrackingCore` and `AblyAssetTrackingSubscriber` can be created in the future. 

### Running tests locally

- Install fastlane by running `gem install fastlane`
- Running in Xcode: Xcode automatically generates schemes based on the Swift Package. Select `ably-asset-tracking-swift-Package` to run all test targets specified in `Package.swift` and press ⌘U or click `Product` > `Test. You can also the other autogenerated schemes to run individual test targets.
  - Xcode can generate test coverage (go into the scheme's test settings).
- Running using Fastlane: 
  - To run all tests, run `fastlane test_all`
  - To run only one target, run `fastlane test_target_name`, where test_target_name can be `test_core`, `test_internal` or other test lanes are defined in `./Fastfile`.

### Coding Conventions and Style Guide

- The SDKs are written in Swift, however they still have to be compatible for use from Objective-C based apps.
- Favor Protocol Oriented Programming with Dependency Injection when writing any code. We're unable to create automatic mocks in Swift, so it'll be helpful for writing unit tests.
- SwiftLint is integrated into the project. Make sure that your code does not add any SwiftLint related warning.
- Please remove default Xcode header comments (with author, license and creation date) as they're not necessary.
- If you're adding or modifying any part of the public interface of SDK, please also update [QuickHelp](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/SymbolDocumentation.html#//apple_ref/doc/uid/TP40016497-CH51-SW1) documentation.
- Docs are written for both Swift and ObjC

### Release Procedure

#### Bumping the Version

To increment the version information for each release from the `main` branch:

1. Search for all instances of the `CFBundleShortVersionString` key in `Info.plist` files and increment according to release requirements, conforming to the [Semantic Versioning Specification](https://semver.org/) version 2.0.0.
2. Search for all instances of the `CFBundleVersion` key in `Info.plist` files and increment the integer value by 1, ignoring those indirected via `$(CURRENT_PROJECT_VERSION)` (see next step).
3. Search for all instances of the `CURRENT_PROJECT_VERSION` key in `project.pbxproj` filesand increment the integer value by 1.

The version, both in SemVer string form and as an integer, **MUST** be the same across all projects in this repository (e.g. example app project versions must match those of the library they're built on top of).
