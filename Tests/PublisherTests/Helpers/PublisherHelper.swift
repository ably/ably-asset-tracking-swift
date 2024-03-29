import AblyAssetTrackingCore
import AblyAssetTrackingCoreTesting
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import CoreLocation
import XCTest

class PublisherHelper {
    enum SendLocationResultPolicy {
        case success
        case retry
        case fail
    }

    private let defaultTimeout: TimeInterval
    private var addedTrackables: [String] = []

    init(defaultTimeout: TimeInterval = 5.0) {
        self.defaultTimeout = defaultTimeout
    }

    func sendLocationUpdate(
        ablyPublisher: MockAblyPublisher,
        publisher: DefaultPublisher,
        locationUpdate: EnhancedLocationUpdate,
        trackable: Trackable,
        locationService: LocationService = MockLocationService(),
        enhancedLocationState: LocationsPublishingState<EnhancedLocationUpdate>,
        resultPolicy: SendLocationResultPolicy = .success,
        error: ErrorInformation = ErrorInformation(type: .commonError(errorMessage: "Failure"))
    ) {
        /**
         Omit re-adding trackable
         */
        if !addedTrackables.contains(trackable.id) {
            /**
             Start publishing trackable
             */
            let connectCompletionHandlerExpectation = XCTestExpectation(description: "Track completion handler expectation")
            ablyPublisher.connectCompletionHandler = { callback in
                callback?(.success)
                self.addedTrackables.append(trackable.id)
                connectCompletionHandlerExpectation.fulfill()
            }

            publisher.track(trackable: trackable) { _ in }

            switch XCTWaiter.wait(for: [connectCompletionHandlerExpectation], timeout: defaultTimeout) {
            case .timedOut:
                XCTFail("Timeout \(connectCompletionHandlerExpectation.description)")
            default:
                ()
            }
        }

        ablyPublisher.sendEnhancedAssetLocationUpdateCounter = .zero

        let expectationDidSendEnhancedLocation = XCTestExpectation(description: "Publisher did send enhanced location")

        ablyPublisher.sendEnhancedAssetLocationUpdateParamCompletionHandler = { completion in
            switch resultPolicy {
            case .success:
                completion?(.success)
                expectationDidSendEnhancedLocation.fulfill()
            case .retry:
                if ablyPublisher.sendEnhancedAssetLocationUpdateCounter == enhancedLocationState.maxRetryCount {
                    completion?(.failure(error))
                } else {
                    completion?(.success)
                    expectationDidSendEnhancedLocation.fulfill()
                }
            case .fail:
                completion?(.failure(error))
                if ablyPublisher.sendEnhancedAssetLocationUpdateCounter == enhancedLocationState.maxRetryCount + 1 {
                    expectationDidSendEnhancedLocation.fulfill()
                }
            }
        }

        publisher.locationService(sender: locationService, didUpdateEnhancedLocationUpdate: locationUpdate)

        switch XCTWaiter.wait(for: [expectationDidSendEnhancedLocation], timeout: defaultTimeout) {
        case .timedOut:
            XCTFail("Timeout \(expectationDidSendEnhancedLocation.description)")
        default:
            ()
        }
    }

    static func createPublisher(
        ablyPublisher: AblyPublisher,
        routingProfile: RoutingProfile = .driving,
        resolutionPolicyFactory: ResolutionPolicyFactory = MockResolutionPolicyFactory(),
        locationService: LocationService = MockLocationService(),
        routeProvider: RouteProvider = MockRouteProvider(),
        enhancedLocationState: LocationsPublishingState<EnhancedLocationUpdate> = LocationsPublishingState<EnhancedLocationUpdate>(),
        logHandler: InternalLogHandlerMockThreadSafe = InternalLogHandlerMockThreadSafe()
    ) -> DefaultPublisher {
        DefaultPublisher(
            routingProfile: routingProfile,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: ablyPublisher,
            locationService: locationService,
            routeProvider: routeProvider,
            enhancedLocationState: enhancedLocationState,
            logHandler: logHandler
        )
    }
}
