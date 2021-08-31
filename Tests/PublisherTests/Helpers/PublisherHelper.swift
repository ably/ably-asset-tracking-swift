//
//  Created by Łukasz Szyszkowski on 31/08/2021.
//
import XCTest
import CoreLocation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

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
        ablyService: MockAblyPublisherService,
        publisher: DefaultPublisher,
        locationUpdate: EnhancedLocationUpdate,
        trackable: Trackable,
        trackableState: PublisherTrackableState,
        resultPolicy: SendLocationResultPolicy = .success,
        error: ErrorInformation = ErrorInformation(type: .commonError(errorMessage: "Failure"))
    ) {
        /**
         Omit re-adding trackable
         */
        if !addedTrackables.contains(trackable.id) {
            publisher.add(trackable: trackable) { _ in }
            
            /**
             Start publishing trackable
             */
            let trackCompletionHandlerExpectation = XCTestExpectation(description: "Track completion handler expectation")
            ablyService.trackCompletionHandler = { callback in
                callback?(.success)
                self.addedTrackables.append(trackable.id)
                trackCompletionHandlerExpectation.fulfill()
            }
            
            publisher.track(trackable: trackable) { _ in }
            
            switch XCTWaiter.wait(for: [trackCompletionHandlerExpectation], timeout: defaultTimeout) {
            case .timedOut:
                XCTFail("Timeout \(trackCompletionHandlerExpectation.description)")
            default: ()
            }
        }
        
        ablyService.sendEnhancedAssetLocationUpdateCounter = .zero
                
        let expectationDidSendEnhancedLocation = XCTestExpectation(description: "Publisher did send enhanced location")
        
        ablyService.sendEnhancedAssetLocationUpdateParamCompletionHandler = { completion in
            switch resultPolicy {
            case .success:
                expectationDidSendEnhancedLocation.fulfill()
                completion?(.success)
            case .retry:
                if ablyService.sendEnhancedAssetLocationUpdateCounter == trackableState.maxRetryCount {
                    completion?(.failure(error))
                } else {
                    expectationDidSendEnhancedLocation.fulfill()
                    completion?(.success)
                }
            case .fail:
                if ablyService.sendEnhancedAssetLocationUpdateCounter == trackableState.maxRetryCount + 1 {
                    expectationDidSendEnhancedLocation.fulfill()
                }
                completion?(.failure(error))
            }
        }
        
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: locationUpdate)

        switch XCTWaiter.wait(for: [expectationDidSendEnhancedLocation], timeout: defaultTimeout) {
        case .timedOut:
            XCTFail("Timeout \(expectationDidSendEnhancedLocation.description)")
        default: ()
        }
    }
}
