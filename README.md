# AblyAssetTracking SDK

![.github/workflows/check.yml](https://github.com/ably/ably-asset-tracking-cocoa/workflows/.github/workflows/check.yml/badge.svg)

## Overview

Ably Asset Tracking SDKs provide an easy way to track multiple assets with realtime location updates powered by [Ably](https://ably.io/) realtime network and Mapbox [Navigation SDK](https://docs.mapbox.com/android/navigation/overview/) with location enhancement.

**Status:** this is a preview version of the SDKs. That means that it contains a subset of the final SDK functionality, and the APIs are subject to change. The latest release of the SDKs is available in the Releases section of this repo

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

This repository also contains example apps that showcase how Ably Asset Tracking SDKs can be used:

- the [Asset Publishing example app](PublisherExample/)
- the [Asset Subscribing example app](SubscriberExample/)

To build the apps you will need to specify credentials properties.

## Development

### Project structure

The project follows standard Pods architecture, so you'll find `AblyAssetTracking.xcworkspace` file which, after opening in Xcode reveals `AblyAssetTracking` and `Pods` projects. We'll skip the description of `Pods` as it's pretty standard and focus on `AblyAssetTracking`.

There are 3 framework targets with dedicated tests and 2 example apps:
- `Core` (and tests)
  <br> Contains all shared logic and models (i.e. GeoJSON mappers) used by Publisher and Subscriber. Notice that there is no direct dependency between Publisher/Subscriber and Core. Instead of that, all files from Core should be also included in Publisher/Subscriber targets (by a tick in the Target Membership in Xcode's File Inspector tab). It's designed like that to avoid creating Umbrella Frameworks (as recommended in `Don't Create Umbrella Frameworks` in [Framework Creation Guidelines](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/CreationGuidelines.html)) - there are some shared sources which we want to be publicly visible for client apps and it won't work with direct dependencies.
- `Publisher` (and tests)
  <br> Contains all sources needed to get the user's location and send it to Ably network.
- `Subscriber` (and tests)
  <br> Contains all sources needed to listen Ably's network for updated asset locations
- `PublisherExample` (without tests)
  <br> Example app demonstrating Publisher SDK usage
- `SubscriberExample` (without tests)
  <br> Example app demonstrating Subscriber SDK usage and presenting asset locations on the map

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
4. API Keys and Access Tokens for Example Apps:

During the pods installation you will be asked to provide:
- `ablyApiKey` :
```
What is the key for ablyApiKey
> <INSERT_API_KEY_HERE>
```

- `ablyClienId`:
```
What is the key for ablyClientId
> <INSERT_CLIENT_ID_HERE>
```

- `MAPBOX_ACCESS_TOKEN` needs to be set in the `Info.plist` file for `MGLMapboxAccessToken` key.

5. Open `AblyAssetTracking.xcworkspace` file. After updating `Info.plist` with the MapBox public key, you should be ready to run the example apps.

#### Why Bundler

It's common that several developers (or CI) will have different tool versions installed locally on their machines, and it may cause compatibility problems (some tools might work only on dedicated versions). So to avoid asking everyone to upgrade/downgrade their local tools it's easier to use some tool to execute needed commands with preset versions and that's what Bundler does. Of course, you are still free to execute all CLI commands directly if you wish.

Here is the list of tools versioned with the Bundler with their versions:
- `CocoaPods` (1.10.0)
- `Fastlane` (2.169.0)
- `Slather` (2.6.0)

You may always check `Gemfile.lock` as it's the source of truth for versions of used libraries.

#### Xcode 12 and Apple M1 compability

Due to [MapBox CoreNavigation SDK issue](https://github.com/ably/ably-asset-tracking-cocoa/issues/40), to be able to build example apps for physical devices, we needed to exclude the `arm64` architecture from supported simulator architectures (check post install script in `Podfile`). It means, that if you are using Apple M1 based computer, you **will not** be able run example app on simulator.

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

### Concepts and assumptions

- The SDKs are written in Swift, however they still have to be compatible for use from Objective-C based apps
- It should be structured as monorepo with publishing SDK and demo app and subscribing SDK and demo app.
- Both SDK are well tested
- We’re following Protocol Oriented Programming with Dependency Injection for easy testing and stubbing.
- Demo apps are written using MVC pattern as they won't contain any heavy logic
- There should be some static analysis built-in (SwiftLint)
- SDK’s should be distributed using CocoaPods (at the beginning), later we’ll add support for Carthage and Swift Package Manager
- At the beginning, we aim only to support iOS, but we need to keep in mind macOS and tvOS
- Project dependencies (ably SDK and MapBox) are fetched using CocoaPods
- Docs are written for both Swift and ObjC
- SDK instances are created using the Builder pattern.
- We’re supporting iOS 12 and higher
- There is a Fastlane setup for testing and archiving SDKs

### iOS version requirements

These SDKs require a minimum of iOS 12+ / iPadOS 12+

### Working on code shared between Publisher and Subscriber

To speed up CocoaPods setup we removed framework/project linking in Xcode and we're just referencing files from the `Core` framework in `Publisher` and `Subscriber` SDK. There is a [ticket](https://github.com/ably/ably-asset-tracking-cocoa/issues/43) to fix it in the future, but for now, if you need to add or move any file in the `Core` SDK make sure that you also reference them in `Publisher` and `Subscriber`.
