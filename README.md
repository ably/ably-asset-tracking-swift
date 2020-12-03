# AblyAssetTracking SDK

Hi there. This is the main repo for Ably Asset Tracking (AAT) project.
Since it's in a very early stage of development, this doc will be changed heavily.

## Table of contents

1. Build instructions
    - Why Bundler
2. Project structure
3. Concepts and assumptions

## Build instructions
Project use CocoaPods, Fastlane (TBD), and Bundler (to make sure that the same version of development tools is used) and is developed using Xcode 12. However, building it's not straightforward and requires some extra steps.

1. Setup `.netrc` file as described in MapBox SDK documentation [here](https://docs.mapbox.com/ios/maps/overview/#configure-credentials). You can skip public token configuration for now.
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

### Why Bundler
It's common that several developers (or CI) will have different tool versions installed locally on their machines, and it may cause compatibility problems (some tools might work only on dedicated versions). So to avoid asking everyone to upgrade/downgrade their local tools it's easier to use some tool to execute needed commands with preset versions and that's what Bundler does. Of course, you are still free to execute all CLI commands directly if you wish.

## Project structure
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

## Concepts and assumptions
- SDK will be written in Swift, however, it still has to be compatible with ObjC
- It should be structured as monorepo with publishing SDK and demo app and subscribing SDK and demo app.
- Both SDK are well tested (I’d love to use Quick/Nimble for that)
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
