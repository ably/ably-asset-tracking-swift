# Ably Asset Tracking SDKs for Cocoa

![.github/workflows/check.yml](https://github.com/ably/ably-asset-tracking-cocoa/workflows/.github/workflows/check.yml/badge.svg)

## Overview

Ably Asset Tracking SDKs provide an easy way to track multiple assets with realtime location updates powered by [Ably](https://ably.com/) realtime network and Mapbox [Navigation SDK](https://docs.mapbox.com/android/navigation/overview/) with location enhancement.

**Status:** this is a beta version of the SDKs. That means that it contains a subset of the final SDK functionality, and the APIs are subject to change. The latest release of the SDKs is available in the [Releases section](https://github.com/ably/ably-asset-tracking-cocoa/releases) of this repository.

Ably Asset Tracking is:

- **easy to integrate** - comprising two complementary SDKs with easy to use APIs, available for multiple platforms:
    - Asset Publishing SDK, for embedding in apps running on the courier's device
    - Asset Subscribing SDK, for embedding in apps runnong on the customer's observing device
- **extensible** - as Ably is used as the underlying transport, you have direct access to your data and can use Ably integrations for a wide range of applications in addition to direct realtime subscriptions - examples include:
    - passing to a 3rd party system
    - persistence for later retrieval
- **built for purpose** - the APIs and underlying functionality are designed specifically to meet the requirements of a range of common asset tracking use-cases

In this repository there are two SDKs for iOS devices:

- the [Asset Publishing SDK](Publisher/)
- the [Asset Subscribing SDK](Subscriber/)

### Documentation

Visit the [Ably Asset Tracking](https://ably.com/documentation/asset-tracking) documentation for a complete API reference and code examples.

### Useful Resources

- [Introducing Ably Asset Tracking - public beta now available](https://ably.com/blog/ably-asset-tracking-beta)
- [Accurate Delivery Tracking with Navigation SDK + Ably Realtime Network](https://www.mapbox.com/blog/accurate-delivery-tracking)

## Requirements

- Publisher SDK: iOS 12.0+ / iPadOS 12.0+
- Subscriber SDK: iOS 12.0+ / iPadOS 12.0+ / macOS 10.11+ / tvOS 10.0+
- Xcode 12.4+
- Swift 5.3+
- Cocoapods: 1.10+

## Installation

### Swift package manager
- To install the AblyAssetTracking page in your **Xcode Project**:
    - Paste `https://github.com/ably/ably-asset-tracking-cocoa` in the "Swift Packages" search box. (Xcode project > Swift Packages.. > `+` button)
    - Select the relevant SDK for your target. (Publisher SDK, Subscriber SDK or both)
    - [This apple guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) explains the steps in more detail.
- To install the AblyAssetTracking package in another **Swift Package**, then add the following to your `Package.Swift`:

  ```swift
  .package(url: "https://github.com/ably/ably-asset-tracking-cocoa", from: "0.0.1"),
  ```

### Cocoapods

- The SDK has not been released to Cocoapods.org trunk, but you can still use it by adding the relevant lines below to your Podfile:

  ```
  target 'Your App Name' do
    pod 'AblyAssetTracking/Publisher', :git => 'https://github.com/ably/ably-asset-tracking-cocoa' // To use the Publisher SDK
    pod 'AblyAssetTracking/Subscriber', :git => 'https://github.com/ably/ably-asset-tracking-cocoa' // To use the Subscriber SDK
  end
  ```

- Run `pod install` to update your Xcode project with these new Podfile dependencies

## Usage

The Asset Publishing SDK is used to get the location of the assets that need to be tracked.

Here is an example of how the Asset Publishing SDK can be used:

```swift
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

Asset Subscribing SDK is used to receive the location of the required assets.

Here is an example of how Asset Subscribing SDK can be used:

```swift
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

Open `AblyAssetTracking.xcworkspace` to open a Xcode workspace containing example apps that showcase how Ably Asset Tracking SDKs can be used:

- the [Asset Publishing example app](PublisherExample/)
- the [Asset Subscribing example app](SubscriberExample/)

To build the apps you will need to specify credentials properties. Create a file called `Secrets.xconfig` in the root project directory (You can copy `Example.Secrets.xcconfig`, e.g. using `cp Example.Secrets.xcconfig Secrets.xcconfig`) and update the following values in the file:

- `ABLY_API_KEY`: Used by publishing and subscribing example apps to authenticate with Ably using basic authentication. Not recommended in production.
- `MAPBOX_ACCESS_TOKEN`: Used to access Mapbox Navigation SDK/ APIs.

## Development

### Getting started

The SDKs are provided via a Swift Package, so it does not use `xcodeproj` or `xcworkspace`. Example apps are contained in 1 `xcworkspace`, each one being an `xcodeproj` .Therefore, 

- To develop the SDK, open the Swift Package in Xcode (`xed .` when in the repo directory, double click `Package.swift`, or open the directory in Xcode). To open the Swift Package using Jetbrains AppCode, you cannot use `appcode .` because it will automatically read the `.xcworkspace` file. Instead, you must go into AppCode and open the `Swift.package`.
- To develop the example apps, open the Xcode workspace file (`xed AblyAssetTracking.xcworkspace` or double click the workspace file). 

### Build instructions

Project use CocoaPods, Fastlane, and Bundler (to make sure that the same version of development tools is used) and is developed using Xcode 12.2. However, building it's not straightforward and requires some extra steps.

1. Setup `.netrc` file as described in MapBox SDK documentation [here](https://docs.mapbox.com/ios/search/guides/install/#configure-credentials). You can skip public token configuration for now. This is needed to obtain the Mapbox SDK dependency.
2. Install bundler using:

```
gem install bundler
```

3. Navigate to the project directory (one with .xcodeproj file) and execute:

```
bundle install
bundle exec pod install
```

4. Open `AblyAssetTracking.xcworkspace` file. After updating `Info.plist` with the MapBox public key, you should be ready to run the example apps.

#### Why Bundler

It's common that several developers (or CI) will have different tool versions installed locally on their machines, and it may cause compatibility problems (some tools might work only on dedicated versions). So to avoid asking everyone to upgrade/downgrade their local tools it's easier to use some tool to execute needed commands with preset versions and that's what Bundler does. Of course, you are still free to execute all CLI commands directly if you wish.

Here is the list of tools versioned with the Bundler with their versions:

- `CocoaPods` (1.10.0)
- `Fastlane` (2.169.0)
- `Slather` (2.6.0)

You may always check `Gemfile.lock` as it's the source of truth for versions of used libraries.

### Running tests

There are two ways of running tests in the project. The first one is standard for all Xcode projects and requires only selecting the correct active scheme in Xcode (`Core`/`Subscriber`/`Publisher`) and running tests from the `Product` -> `Test` menu.

Another one involves `Fastlane` and is executed from the command line:

```zsh
# run tests for the Core target
bundle exec fastlane test_core

# run tests for the Publisher target
bundle exec fastlane test_publisher

# run tests for the Subscriber target
bundle exec fastlane test_subscriber

# run tests for all targets
bundle exec fastlane test_all
```

Additionally, when you run tests using `Fastlane` you will see three new directories created: `coverage_core`, `coverage_publisher`, `coverage_subscriber`. Each contains an `index.html` file with a full test coverage report for the given target.

### Coding Conventions and Style Guide

- The SDKs are written in Swift, however they still have to be compatible for use from Objective-C based apps.
- Favor Protocol Oriented Programming with Dependency Injection when writing any code. We're unable to create automatic mocks in Swift, so it'll be helpful for writing unit tests.
- SwiftLint is integrated into the project. Make sure that your code does not add any SwiftLint related warning.
- Please remove default Xcode header comments (with author, license and creation date) as they're not necessary.
- If you're adding or modifying any part of the public interface of SDK, please also update [QuickHelp](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/SymbolDocumentation.html#//apple_ref/doc/uid/TP40016497-CH51-SW1) documentation.

### Concepts and assumptions

- At the beginning, we aim only to support iOS, but we need to keep in mind macOS and tvOS
- Docs are written for both Swift and ObjC

### Working on code shared between Publisher and Subscriber

**Core target:** Contains all shared logic and models (i.e. GeoJSON mappers) used by Publisher and Subscriber. Notice that there is no direct dependency between Publisher/Subscriber and Core. Instead of that, all files from Core should be also included in Publisher/Subscriber targets (by a tick in the Target Membership in Xcode's File Inspector tab). It's designed like that to avoid creating Umbrella Frameworks (as recommended in `Don't Create Umbrella Frameworks` in [Framework Creation Guidelines](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/CreationGuidelines.html)) - there are some shared sources which we want to be publicly visible for client apps and it won't work with direct dependencies.

### Release Procedure

#### Bumping the Version

To increment the version information for each release from the `main` branch:

1. Search for all instances of the `CFBundleShortVersionString` key in `Info.plist` files and increment according to release requirements, conforming to the [Semantic Versioning Specification](https://semver.org/) version 2.0.0.
2. Search for all instances of the `CFBundleVersion` key in `Info.plist` files and increment the integer value by 1, ignoring those indirected via `$(CURRENT_PROJECT_VERSION)` (see next step).
3. Search for all instances of the `CURRENT_PROJECT_VERSION` key in `project.pbxproj` filesand increment the integer value by 1.

The version, both in SemVer string form and as an integer, **MUST** be the same across all projects in this repository (e.g. example app project versions must match those of the library they're built on top of).
