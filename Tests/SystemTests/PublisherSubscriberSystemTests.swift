import Ably
import AblyAssetTrackingCore
import AblyAssetTrackingCoreTesting
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import AblyAssetTrackingSubscriber
import AblyAssetTrackingTesting
import CoreLocation
import XCTest

struct Locations: Codable {
    let locations: [GeoJSONMessage]
}

class PublisherAndSubscriberSystemTests: XCTestCase {
    private var locationChangeTimer: Timer!
    private var locationsData: Locations!

    private let didChangeTrackableStateOnlineExpectation = XCTestExpectation(description: "Trackable State Did Change To Online")
    private let didChangeTrackableStateOfflineExpectation = XCTestExpectation(description: "Trackable State Did Change To Offline")
    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    private let didUpdateRawLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Raw Locations")
    private let didUpdateResolutionExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Resolution")
    private let routeProvider = MockRouteProvider()
    private let resolutionPolicyFactory = MockResolutionPolicyFactory()
    private let trackableId = "Trackable ID 1 - \(UUID().uuidString)"
    private let subscriberClientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()
    private let publisherClientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()

    private let logHandler = TestLogging.sharedLogHandler
    private let publisherInternalLogHandler = TestLogging.sharedInternalLogHandler
        .addingSubsystem(.assetTracking)
        .addingSubsystem(.named("publisher"))

    func testSubscriberReceivesPublisherMessageWithBicycleProfile() throws {
        try subscriberReceivesPublisherMessage(vehicleProfile: .bicycle)
    }

    func testSubscriberReceivesPublisherMessageWithCarProfile() throws {
        try subscriberReceivesPublisherMessage(vehicleProfile: .car)
    }

    func subscriberReceivesPublisherMessage(vehicleProfile: VehicleProfile) throws {
        do {
            locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        } catch {
            XCTFail("Can't find the source of locations `test-locations.json`")
        }

        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)

        let subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .delegate(self)
            .trackingId(trackableId)
            .logHandler(handler: logHandler)
            .start { _ in }!

        delay(5)

        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map { $0.toCoreLocation() },
            logHandler: publisherInternalLogHandler,
            vehicleProfile: vehicleProfile
        )

        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)

        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: publisherConnectionConfiguration,
            host: nil,
            mode: .publish,
            logHandler: publisherInternalLogHandler
        )

        let publisher = DefaultPublisher(
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: true,
            isSendResolutionEnabled: true,
            logHandler: publisherInternalLogHandler
        )

        let trackable = Trackable(id: trackableId)
        didUpdateEnhancedLocationExpectation.expectedFulfillmentCount = Int(floor(Double(locationsData.locations.count) / 2.0))
        publisher.add(trackable: trackable) { _  in }

        wait(for: [didUpdateEnhancedLocationExpectation, didUpdateRawLocationExpectation, didUpdateResolutionExpectation], timeout: 20.0)

        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        let stopSubscriberExpectation = self.expectation(description: "Subscriber did call stop completion closure")

        subscriber.stop { _ in
            stopSubscriberExpectation.fulfill()
        }

        publisher.stop { _ in
            stopPublisherExpectation.fulfill()
        }

        wait(for: [stopPublisherExpectation, stopSubscriberExpectation], timeout: 5)
    }

    func testSubscriberNotReceivesAssetConnectionStatus() throws {
        do {
            locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        } catch {
            XCTFail("Can't find the source of locations `test-locations.json`")
        }

        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)

        let subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .delegate(self)
            .trackingId(trackableId)
            .logHandler(handler: logHandler)
            .start { _ in }!

        delay(5)
        didChangeTrackableStateOnlineExpectation.isInverted = true
        didChangeTrackableStateOfflineExpectation.isInverted = true
        wait(for: [
            didChangeTrackableStateOnlineExpectation, didChangeTrackableStateOfflineExpectation
        ], timeout: 0.0)

        subscriber.stop { _ in }
    }

    func testSubscriberReceivesAssetConnectionStatusWithBicycleProfile() throws {
        try subscriberReceivesAssetConnectionStatus(vehicleProfile: .bicycle)
    }

    func testSubscriberReceivesAssetConnectionStatusWithCarProfile() throws {
        try subscriberReceivesAssetConnectionStatus(vehicleProfile: .car)
    }

    func subscriberReceivesAssetConnectionStatus(vehicleProfile: VehicleProfile) throws {
        do {
            locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        } catch {
            XCTFail("Can't find the source of locations `test-locations.json`")
        }

        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map { $0.toCoreLocation() },
            logHandler: publisherInternalLogHandler,
            vehicleProfile: vehicleProfile
        )

        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)

        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: publisherConnectionConfiguration,
            host: nil,
            mode: .publish,
            logHandler: publisherInternalLogHandler
        )

        let publisher = DefaultPublisher(
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: true,
            isSendResolutionEnabled: true,
            logHandler: publisherInternalLogHandler
        )

        let trackable = Trackable(id: trackableId)
        publisher.add(trackable: trackable) { _  in }

        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)

        let subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .delegate(self)
            .trackingId(trackableId)
            .start { _ in }!

        wait(for: [didChangeTrackableStateOnlineExpectation], timeout: 5.0)

        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        publisher.stop { _ in
            stopPublisherExpectation.fulfill()
        }
        wait(for: [stopPublisherExpectation], timeout: 5)

        wait(for: [didChangeTrackableStateOfflineExpectation], timeout: 5.0)

        subscriber.stop { _ in }
    }

    private func delay(_ timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }
}

extension PublisherAndSubscriberSystemTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}

    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeTrackableState state: TrackableState) {
        switch state {
        case .online:
            didChangeTrackableStateOnlineExpectation.fulfill()
        case .offline:
            didChangeTrackableStateOfflineExpectation.fulfill()
        case .failed:
            ()
        }
    }

    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        didUpdateEnhancedLocationExpectation.fulfill()
    }

    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate) {
        didUpdateRawLocationExpectation.fulfill()
    }

    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateResolution resolution: Resolution) {
        didUpdateResolutionExpectation.fulfill()
    }
}
