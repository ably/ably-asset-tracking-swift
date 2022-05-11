### Ably SDK

[_Ably_](https://ably.com/) _is the platform that powers synchronized digital experiences in realtime. Whether attending an event in a virtual venue, receiving realtime financial information, or monitoring live car performance data – consumers simply expect realtime digital experiences as standard. Ably provides a suite of APIs to build, extend, and deliver powerful digital experiences in realtime for more than 250 million devices across 80 countries each month. Organizations like Bloomberg, HubSpot, Verizon, and Hopin depend on Ably's platform to offload the growing complexity of business-critical realtime data synchronization at global scale. For more information, see the_ [_Ably documentation_](https://ably.com/documentation)_._

# Ably Asset Tracking SDKs for Swift

![.github/workflows/check.yml](https://github.com/ably/ably-asset-tracking-swift/workflows/.github/workflows/check.yml/badge.svg)

### Overview

Ably Asset Tracking SDKs provide an easy way to track multiple assets with realtime location updates powered by the [Ably](https://ably.com/) realtime network and Mapbox [Navigation SDK](https://docs.mapbox.com/android/navigation/overview/) with location enhancement.

### Status

This SDK is a beta version. That means it contains a subset of the final SDK functionality, and the APIs are subject to change. The latest release of the SDKs is available in the [Releases section](https://github.com/ably/ably-asset-tracking-swift/releases) of this repository.

**Ably Asset Tracking is:**

- _easy to integrate_ - comprising two complementary SDKs with easy to use APIs, available for multiple platforms:
- Asset Publishing SDK, for embedding in apps running on the courier's device.
- Asset Subscribing SDK, for embedding in apps running on the customer's observing device.
- _extensible_ - as [Ably](https://ably.com/) is used as the underlying transport, you have direct access to your data and can use [Ably](https://ably.com/) integrations for a wide range of applications in addition to direct realtime subscriptions - examples include:
- passing to a 3rd party system
- persistence for later retrieval
- _built for purpose_ - the APIs and underlying functionality are explicitly designed to meet the requirements of a range of common asset tracking use-cases

This repo holds an Xcode workspace (`Examples/AblyAssetTracking.workspace`), containing:

Multiple example apps/ Xcode projects, and

One Swift Package (`ably-asset-tracking-swift`), containing three libraries/ SDKs:

- Publisher SDK: The `AblyAssetTrackingPublisher` library allows you to use `import AblyAssetTrackingPublisher`.

- Subscriber SDK: The `AblyAssetTrackingSubscriber` library allows you to use `import AblyAssetTrackingSubscriber`.

- Ably Asset Tracking UI SDK: The `AblyAssetTrackingUI` library allows you to use `import AblyAssetTrackingUI`.

  The UI SDK contains:
    - Location Animator - uses to animate map view annotation smoothly

### Documentation

Visit the [Ably Asset Tracking](https://ably.com/documentation/asset-tracking) documentation for a complete API reference and code examples.

### Useful Resources

- [Introducing Ably Asset Tracking - public beta now available](https://ably.com/blog/ably-asset-tracking-beta)

- [Accurate Delivery Tracking with Navigation SDK + Ably Realtime Network](https://www.mapbox.com/blog/accurate-delivery-tracking)


## Installation

### Requirements

These SDKs support support iOS and iPadOS. Support for macOS/ tvOS may be developed in the future, depending on interest/ demand.

- Publisher SDK: iOS 12.0+ / iPadOS 12.0+

- Subscriber SDK: iOS 12.0+ / iPadOS 12.0+

- Xcode 12.4+

- Swift 5.3+

### Swift package manager

- To install this package in an **Xcode Project**:
- Paste `https://github.com/ably/ably-asset-tracking-swift` in the "Swift Packages" search box. (Xcode project > Swift Packages.. > `+` button)
- Select the relevant SDK for your target. (Publisher SDK, Subscriber SDK or both)
- [This apple guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) explains the steps in more detail.
- To install this package into a **Swift Package**, add the following to your manifest (`Package.swift`):

```swift
.package(url: "https://github.com/ably/ably-asset-tracking-swift", from: LATEST_VERSION),
```

_You can find the version on the [releases](https://github.com/ably/ably-asset-tracking-swift/releases) page._

## Example Apps

- Configure your Mapbox credentials (`~/.netrc`) to download the Mapbox SDK by following [this](https://docs.mapbox.com/ios/search/guides/install/#configure-credentials) guide. You'll need a Mapbox account.
- An `Examples/Secrets.xcconfig` file containing credentials (keys/ tokens) is required to build the example apps. (You can use the example `Examples/Example.Secrets.xcconfig`, e.g. by running `cp Examples/Example.Secrets.xcconfig Examples/Secrets.xcconfig`). Update the following values in `Examples/Secrets.xcconfig`:
- `ABLY_API_KEY`: Used by all example apps to authenticate with Ably using basic authentication. Not recommended in production, and can be taken from [here](https://ably.com/accounts).
- `MAPBOX_ACCESS_TOKEN`: Used to access Mapbox Navigation SDK/ APIs, and can be taken from [here](https://account.mapbox.com/). Using the Mapbox token is only required to run the **Publisher** example apps.
- Open `AblyAssetTracking.xcworkspace` to open an Xcode workspace containing example apps and the Swift Package containing the SDKs that showcase how to use the Ably Asset Tracking SDKs.

## Usage

### Publisher SDK

The Asset Publisher SDK can efficiently acquire the location data on a device and publish location updates to other subscribers in realtime. Here is an example of how the Asset Publisher SDK can be used:

```swift
import AblyAssetTrackingPublisher

// Initialise a Publisher

publisher = try? PublisherFactory.publishers() // get a Publisher Builder
    .connection(ConnectionConfiguration(apiKey: ABLY_API_KEY, clientId: CLIENT_ID)) // provide Ably configuration with credentials
    .log(LogConfiguration()) // provide logging configuration
    .transportationMode(TransportationMode()) // provide mode of transportation for better location enhancements
    .delegate(self) // provide delegate to handle location updates locally if needed
    .start()
    
// Start tracking an asset

publisher?.track(trackable: Trackable(id: trackingId)) // provide a tracking ID of the asset
```

### Subscriber SDK

The Asset Subscriber SDK can be used to receive location updates from a publisher in realtime. Here is an example of how Asset Subscribing SDK can be used:

```swift
import AblyAssetTrackingSubscriber

// Initialise a Subscriber

subscriber = try? SubscriberFactory.subscribers() // get a Subscriber Builder
    .connection(ConnectionConfiguration(apiKey: ABLY_API_KEY, clientId: CLIENT_ID)) // provide Ably configuration with credentials
    .trackingId(trackingId) // provide a Tracking ID for the asset to be tracked
    .routingProfile(.cycling) // provide a routing profile for better location enhancements
    .log(LogConfiguration()) // provide logging configuration
    .delegate(self) // provide a delegate to handle received location updates
    .start() // start listening to updates
```

### Authentication

Both Subscriber and Publisher SDK support basic authentication (API key) and token authentication. Specify this by passing a `ConnectionConfiguration` to the Subscriber or Publisher builder: `SubscriberFactory.subscribers().connection(connectionConfiguration)`.

**To use basic authentication, set the following `ConnectionConfiguration` on the Subscriber or Publisher builder:**

```swift

let connectionConfiguration = ConnectionConfiguration(apiKey: ABLY_API_KEY, clientId: clientId)

```
**To use token authentication, you can pass a closure which will be called when the Ably client needs to authenticate or reauthenticate:**

```swift
let connectionConfiguration = ConnectionConfiguration(clientId: clientId) { tokenParams, resultHandler in

    // Implement a request to your servers which provides either a TokenRequest (simplest), TokenDetails, JWT or token string.

    getTokenRequestJSONFromYourServer(tokenParams: tokenParams) { result in
        switch result {
        case .success(let tokenRequest):
            resultHandler(.success(.tokenRequest(tokenRequest)))
        case .failure(let error):
            resultHandler(.failure(error))
        }
    }
}
```

**Alternatively, in token authentication, you can specify an _authUrl_, which will be used by Ably to authenticate.**

```swift
let connectionConfiguration = ConnectionConfiguration(authUrl: authUrl, clientId: clientId)
```

### Ably Asset Tracking UI (Location Animator)

The `Location Animator` can interpolate and animate map annotation view.

```swift
// Instantiate Location Animator
let locationAnimator = DefaultLocationAnimator()
```

```swift
// Subscribe for `Location Animator` position updates
locationAnimator.subscribeForFrequentlyUpdatingPosition { position in
    // Update map view annotation position here
}
```

```swift
// Additionally you can subscribe for infrequently position updates
locationAnimator.subscribeForInfrequentlyUpdatingPosition { position in
    // Update map camera position
}
```

```swift
// Feed animator with location changes from the `Subscriber SDK`
func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
    locationAnimator.animateLocationUpdate(location: locationUpdate, interval: locationUpdateInterval / 1000.0)
}
```

## Resources

- [Asset Tracking Documentation](https://ably.com/documentation/asset-tracking)
- [Ably Documentation](https://ably.com/documentation)

## Feature Support

iOS Client Library [feature support matrix](https://ably.com/documentation/asset-tracking).

## Support, feedback and troubleshooting

Please visit http://support.ably.com/ for access to our knowledgebase and to ask for any assistance.

You can also view the [community reported Github issues](https://github.com/ably/ably-asset-tracking-swift/issues).

To see what has changed in recent versions, see the [CHANGELOG](https://github.com/ably/ably-asset-tracking-swift/blob/main/CHANGELOG.md).

## Known Limitations

These SDKs support iOS and iPadOS. Support for macOS / tvOS may be developed in the future, depending on interest / demand.

## Contributing

For guidance on how to contribute to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).
