import XCTest
import Logging
import AblyAssetTrackingCore
@testable import AblyAssetTrackingSubscriber

class DefaultSubscriberTests: XCTestCase {
    private var ablySubscriber: MockAblySubscriberService!
    private var subscriber: DefaultSubscriber!
    
    private let configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
    private let logger = Logger(label: "com.ably.tracking.DefaultSubscriberTests")
    
    override func setUpWithError() throws {
        let trackableId: String = "Trackable-\(UUID().uuidString)"
        ablySubscriber = MockAblySubscriberService(configuration: configuration, mode: .subscribe, logger: logger)
        
        subscriber = DefaultSubscriber(
            ablySubscriber: ablySubscriber,
            trackableId: trackableId,
            resolution: nil
        )
    }
    
    func test_subscriberStop_called() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.stop { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablySubscriber.closeCalled)
        XCTAssertNotNil(ablySubscriber.closeCompletion)
    }
    
    func test_subscriberStop_success() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success)}
        var isSuccess = false
        
        // When
        subscriber.stop { result in
            switch result {
            case .success:
                isSuccess.toggle()
            case .failure:
                XCTFail("Error not expected.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isSuccess)
    }
    
    func test_subscriberStop_failure() {
        // Given
        let expectation = XCTestExpectation()
        let stopError = ErrorInformation(type: .subscriberError(errorMessage: "test_stop_error"))
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.failure(stopError))}
        var isFailure = false
        var receivedError: ErrorInformation?
        
        // When
        subscriber.stop { result in
            switch result {
            case .success:
                XCTFail("Success not expected.")
            case .failure(let error):
                receivedError = error
                isFailure.toggle()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isFailure)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.message, stopError.message)
    }
    
    func test_subscriberStop_afterStopped() {
        // Given
        var expectation = XCTestExpectation()
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success)}
        var isSuccess = false
        
        // When
        subscriber.stop { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        
        subscriber.stop { result in
            switch result {
            case .failure:
                XCTFail("Error not expected.")
            case .success:
                isSuccess.toggle()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isSuccess)
    }
    
    func test_subscriberReturnsError_afterStopped() {
        // Given
        var expectation = XCTestExpectation()
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success)}
        var receivedError: ErrorInformation?
        let expectedError = ErrorInformation(type: .subscriberStoppedException)
        var isFailure = false

        // When
        subscriber.stop { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        
        subscriber.resolutionPreference(resolution: nil) { result in
            switch result {
            case .success:
                XCTFail("Success not expected.")
            case .failure(let error):
                receivedError = error
                isFailure.toggle()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isFailure)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(expectedError.message, receivedError?.message)
    }
    
    func test_subscriberResolutionPreference_paramsCheck_resolutionIsNotNil() {
        // Given
        let expectation = XCTestExpectation()
        let resolution = Resolution(accuracy: .high, desiredInterval: 1.0, minimumDisplacement: 1.0)
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.resolutionPreference(resolution: resolution) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablySubscriber.updatePresenceDataWasCalled)
        XCTAssertNotNil(ablySubscriber.updatePresenceDataTrackableId)
        XCTAssertNotNil(ablySubscriber.updatePresenceDataPresenceData)
        XCTAssertNotNil(ablySubscriber.updatePresenceDataCompletion)
    }
    
    func test_subscriberResolutionPreference_paramsCheck_resolutionIsNil() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.resolutionPreference(resolution: nil) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then - `updatePresenceData` shouldn't call (nothing to update)
        XCTAssertFalse(ablySubscriber.updatePresenceDataWasCalled)
    }
    
    func test_subscriberResolutionPreference_success() {
        // Given
        let expectation = XCTestExpectation()
        let resolution = Resolution(accuracy: .high, desiredInterval: 1.0, minimumDisplacement: 1.0)
        var isSuccess = false
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.resolutionPreference(resolution: resolution) { result in
            switch result {
            case .success:
                isSuccess.toggle()
                expectation.fulfill()
            case .failure:
                XCTFail("Failure not expected")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isSuccess)
    }
    
    func test_subscriberResolutionPreference_failure() {
        // Given
        let expectation = XCTestExpectation()
        let resolution = Resolution(accuracy: .high, desiredInterval: 1.0, minimumDisplacement: 1.0)
        var isFailure = false
        let expectedError = ErrorInformation(type: .subscriberError(errorMessage: "SendResolutionPreferenceTestError"))
        var receivedError: ErrorInformation?
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.failure(expectedError))}
        
        // When
        subscriber.resolutionPreference(resolution: resolution) { result in
            switch result {
            case .success:
                XCTFail("Success not expected")
            case .failure(let error):
                receivedError = error
                isFailure.toggle()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isFailure)
        XCTAssertEqual(receivedError?.message, expectedError.message)
    }
    
    func test_subscriberStart_called() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.connectCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.start { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablySubscriber.connectCalled)
        XCTAssertNotNil(ablySubscriber.connectCompletion)
    }
    
    func test_subscriberStart_success() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.connectCompletionHandler = { completion in completion?(.success)}
        var isSuccess = false
        
        // When
        subscriber.start { result in
            switch result {
            case .success:
                isSuccess.toggle()
            case .failure:
                XCTFail("Error not expected.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isSuccess)
    }
    
    func test_subscriberStart_failure() {
        // Given
        let expectation = XCTestExpectation()
        let stopError = ErrorInformation(type: .subscriberError(errorMessage: "test_start_error"))
        ablySubscriber.connectCompletionHandler = { completion in completion?(.failure(stopError))}
        var isFailure = false
        var receivedError: ErrorInformation?
        
        // When
        subscriber.start { result in
            switch result {
            case .success:
                XCTFail("Success not expected.")
            case .failure(let error):
                receivedError = error
                isFailure.toggle()
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(isFailure)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.message, stopError.message)
    }
}
