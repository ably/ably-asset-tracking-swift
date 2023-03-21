import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import CoreLocation
import XCTest

class DefaultResolutionPolicyTests: XCTestCase {
    var hooks: DefaultResolutionPolicyHooks!
    var methods: MockResolutionPolicyMethods!
    var defaultResolution: Resolution!
    var batteryLevelProvider: MockBatteryLevelProvider!
    var resolutionPolicy: DefaultResolutionPolicy!

    override func setUpWithError() throws {
        hooks = DefaultResolutionPolicyHooks()
        methods = MockResolutionPolicyMethods()
        defaultResolution = Resolution(accuracy: .balanced, desiredInterval: 100, minimumDisplacement: 100)
        batteryLevelProvider = MockBatteryLevelProvider()
        resolutionPolicy = DefaultResolutionPolicy(
            hooks: hooks,
            methods: methods,
            defaultResolution: defaultResolution,
            batteryLevelProvider: batteryLevelProvider
        )
    }

    func testResolutionPolicy_resolveRequest_noRemoteRequests() {
        let request = TrackableResolutionRequest(trackable: Trackable(id: "TestId"), remoteRequests: [])
        // Resolving request with no remote requests
        let result = resolutionPolicy.resolve(request: request)

        // Should return a default resolution
        XCTAssertEqual(result, defaultResolution)
    }

    func testResolutionPolicy_resolveRequest_withConstraints_noRemoteRequests() {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 10, minimumDisplacement: 11)
        let resolutions = DefaultResolutionSet(resolution: resolution)
        let proximity = DefaultProximity(spatial: 500)
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutions,
            proximityThreshold: proximity,
            batteryLevelThreshold: 50,
            lowBatteryMultiplier: 3
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // Resolving request with constrained trackable and no remote requests
        let result = resolutionPolicy.resolve(request: request)

        // Should return a resolution from trackable constraints
        XCTAssertTrue(result == resolution)
    }

    func testResolutionPolicy_resolveRequest_batteryMultiplier() {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 10, minimumDisplacement: 10)
        let resolutions = DefaultResolutionSet(resolution: resolution)
        let proximity = DefaultProximity(spatial: 500)
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutions,
            proximityThreshold: proximity,
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 3
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // When batteryLevel is available and below given threshold
        batteryLevelProvider.currentBatteryPercentageReturnValue = 20

        // Resolving request with trackable with constraints and no remote requests
        let result = resolutionPolicy.resolve(request: request)

        // Should return a resolution with desiredInterval multiplied by lowBatteryMultiplier
        XCTAssertTrue(result == Resolution(accuracy: .balanced, desiredInterval: 30, minimumDisplacement: 10))
    }

    func testResolutionPolicy_resolveRequest_oneRemoteResolution() {
        let resolution = Resolution(accuracy: .maximum, desiredInterval: 12, minimumDisplacement: 12)
        let request = TrackableResolutionRequest(trackable: Trackable(id: "TestId"), remoteRequests: [resolution])

        // Resolving request with only one remote resolution
        let result = resolutionPolicy.resolve(request: request)

        // Should return it
        XCTAssertTrue(result == resolution)
    }

    func testResolutionPolicy_resolveRequest_multipleRemoteResolutions() {
        let resolutions: Set<Resolution> = [
            Resolution(accuracy: .minimum, desiredInterval: 8, minimumDisplacement: 5),
            Resolution(accuracy: .low, desiredInterval: 10, minimumDisplacement: 3),
            Resolution(accuracy: .balanced, desiredInterval: 6, minimumDisplacement: 7),
            Resolution(accuracy: .high, desiredInterval: 4, minimumDisplacement: 9),
            Resolution(accuracy: .maximum, desiredInterval: 10, minimumDisplacement: 11)
        ]

        let request = TrackableResolutionRequest(trackable: Trackable(id: "TestId"), remoteRequests: resolutions)

        // Resolving request with multiple remote requests
        let result = resolutionPolicy.resolve(request: request)

        // Should return best combination (highest accuracy with lowest desiredInterval and lowest minimumDisplacement)
        XCTAssertTrue(result == Resolution(accuracy: .maximum, desiredInterval: 4, minimumDisplacement: 3))
    }

    func testResolutionPolicy_resolveRequest_constrained_multipleRemoteResolutions() {
        let resolutions: Set<Resolution> = [
            Resolution(accuracy: .minimum, desiredInterval: 8, minimumDisplacement: 5),
            Resolution(accuracy: .low, desiredInterval: 10, minimumDisplacement: 3),
            Resolution(accuracy: .balanced, desiredInterval: 6, minimumDisplacement: 7),
            Resolution(accuracy: .high, desiredInterval: 4, minimumDisplacement: 9),
            Resolution(accuracy: .maximum, desiredInterval: 10, minimumDisplacement: 11)
        ]

        let resolutionSet = DefaultResolutionSet(
            resolution: Resolution(
                accuracy: .balanced,
                desiredInterval: 2,
                minimumDisplacement: 5
            )
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 3
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: resolutions)

        // Resolving a constrained request with multiple remote requests
        let result = resolutionPolicy.resolve(request: request)

        // Should return best combination (highest accuracy with lowest desiredInterval and lowest minimumDisplacement)
        XCTAssertTrue(result == Resolution(accuracy: .maximum, desiredInterval: 2, minimumDisplacement: 3))
    }

    func testResolutionPolicy_resolveRequest_constrained_multipleRemoteResolutions_battery() {
        let resolutions: Set<Resolution> = [
            Resolution(accuracy: .minimum, desiredInterval: 8, minimumDisplacement: 5),
            Resolution(accuracy: .low, desiredInterval: 10, minimumDisplacement: 3),
            Resolution(accuracy: .balanced, desiredInterval: 6, minimumDisplacement: 7),
            Resolution(accuracy: .high, desiredInterval: 4, minimumDisplacement: 9),
            Resolution(accuracy: .maximum, desiredInterval: 10, minimumDisplacement: 11)
        ]

        let resolutionSet = DefaultResolutionSet(
            resolution: Resolution(
                accuracy: .balanced,
                desiredInterval: 2,
                minimumDisplacement: 5
            )
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 20
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: resolutions)

        batteryLevelProvider.currentBatteryPercentageReturnValue = 10
        // Resolving a constrained request with multiple remote requests and battery below threshold
        let result = resolutionPolicy.resolve(request: request)

        // Should return best combination - highest accuracy with lowest minimumDisplacement and multiplied lowest desiredInterval
        XCTAssertTrue(result == Resolution(accuracy: .maximum, desiredInterval: 40, minimumDisplacement: 3))
    }

    func testResolutionPolicy_resolveResolutions_farWithoutSubscriber() {
        let resolutionSet = DefaultResolutionSet(
            farWithoutSubscriber: Resolution(accuracy: .low, desiredInterval: 1, minimumDisplacement: 2),
            farWithSubscriber: Resolution(accuracy: .balanced, desiredInterval: 3, minimumDisplacement: 4),
            nearWithoutSubscriber: Resolution(accuracy: .high, desiredInterval: 5, minimumDisplacement: 6),
            nearWithSubscriber: Resolution(accuracy: .maximum, desiredInterval: 7, minimumDisplacement: 8)
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 20
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // Resolving a constrained request when above threshold and no subscriber
        let result = resolutionPolicy.resolve(request: request)

        // Should return farWithoutSubscriber
        XCTAssertTrue(result == resolutionSet.farWithoutSubscriber)
    }

    func testResolutionPolicy_resolveResolutions_farWithSubscriber() {
        let resolutionSet = DefaultResolutionSet(
            farWithoutSubscriber: Resolution(accuracy: .low, desiredInterval: 1, minimumDisplacement: 2),
            farWithSubscriber: Resolution(accuracy: .balanced, desiredInterval: 3, minimumDisplacement: 4),
            nearWithoutSubscriber: Resolution(accuracy: .high, desiredInterval: 5, minimumDisplacement: 6),
            nearWithSubscriber: Resolution(accuracy: .maximum, desiredInterval: 7, minimumDisplacement: 8)
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 20
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // Resolving a constrained request when above threshold and added subscriber
        hooks.subscribers?.onSubscriberAdded(subscriber: Subscriber(id: "SubscriberId", trackable: trackable))
        let result = resolutionPolicy.resolve(request: request)

        // Should return farWithSubscriber
        XCTAssertTrue(result == resolutionSet.farWithSubscriber)
    }

    func testResolutionPolicy_resolveResolutions_nearWithoutSubscriber() {
        let resolutionSet = DefaultResolutionSet(
            farWithoutSubscriber: Resolution(accuracy: .low, desiredInterval: 1, minimumDisplacement: 2),
            farWithSubscriber: Resolution(accuracy: .balanced, desiredInterval: 3, minimumDisplacement: 4),
            nearWithoutSubscriber: Resolution(accuracy: .high, desiredInterval: 5, minimumDisplacement: 6),
            nearWithSubscriber: Resolution(accuracy: .maximum, desiredInterval: 7, minimumDisplacement: 8)
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 20
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // Resolving a constrained request when below threshold and no subscriber
        resolutionPolicy.trackableSetListener(sender: DefaultTrackableSetListener(), onActiveTrackableChanged: trackable)
        methods.setProximityThresholdParamHandler?.onProximityReached(threshold: DefaultProximity(spatial: 500) )
        resolutionPolicy.trackableSetListener(sender: DefaultTrackableSetListener(), onActiveTrackableChanged: nil)

        let result = resolutionPolicy.resolve(request: request)

        // Should return nearWithoutSubscriber
        XCTAssertTrue(result == resolutionSet.nearWithoutSubscriber)
    }

    func testResolutionPolicy_resolveResolutions_nearWithSubscriber() {
        let resolutionSet = DefaultResolutionSet(
            farWithoutSubscriber: Resolution(accuracy: .low, desiredInterval: 1, minimumDisplacement: 2),
            farWithSubscriber: Resolution(accuracy: .balanced, desiredInterval: 3, minimumDisplacement: 4),
            nearWithoutSubscriber: Resolution(accuracy: .high, desiredInterval: 5, minimumDisplacement: 6),
            nearWithSubscriber: Resolution(accuracy: .maximum, desiredInterval: 7, minimumDisplacement: 8)
        )
        let constraints = DefaultResolutionConstraints(
            resolutions: resolutionSet,
            proximityThreshold: DefaultProximity(spatial: 500),
            batteryLevelThreshold: 30,
            lowBatteryMultiplier: 20
        )
        let trackable = Trackable(id: "TestTrackableId", constraints: constraints)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: [])

        // Resolving a constrained request when below threshold and no subscriber
        hooks.subscribers?.onSubscriberAdded(subscriber: Subscriber(id: "SubscriberId", trackable: trackable))
        resolutionPolicy.trackableSetListener(sender: DefaultTrackableSetListener(), onActiveTrackableChanged: trackable)
        methods.setProximityThresholdParamHandler?.onProximityReached(threshold: DefaultProximity(spatial: 500))

        let result = resolutionPolicy.resolve(request: request)

        // Should return nearWithSubscriber
        XCTAssertTrue(result == resolutionSet.nearWithSubscriber)
    }
}
