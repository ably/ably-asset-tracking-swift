import XCTest
import AblyAssetTrackingCore
@testable import AblyAssetTrackingSubscriber

class DefaultSubscriberTests: XCTestCase {
    private var ablyService: MockAblySubscriberService!
    private var subscriber: DefaultSubscriber!
    
    override func setUpWithError() throws {
        ablyService = MockAblySubscriberService()
        
        subscriber = DefaultSubscriber(logConfiguration: LogConfiguration(),
                                       ablyService: ablyService)
    }
    
    func test_subscriberStop_called() {
        // Given
        let expectation = XCTestExpectation()
        ablyService.stopCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.stop { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablyService.stopWasCalled)
        XCTAssertNotNil(ablyService.stopResultHandler)
    }
    
    func test_subscriberStop_success() {
        // Given
        let expectation = XCTestExpectation()
        ablyService.stopCompletionHandler = { completion in completion?(.success)}
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
        ablyService.stopCompletionHandler = { completion in completion?(.failure(stopError))}
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
        ablyService.stopCompletionHandler = { completion in completion?(.success)}
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
        ablyService.stopCompletionHandler = { completion in completion?(.success)}
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
        ablyService.sendResolutionPreferenceCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.resolutionPreference(resolution: resolution) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablyService.sendResolutionPreferenceWasCalled)
        XCTAssertNotNil(ablyService.sendResolutionPreferenceResolutionParam)
        XCTAssertNotNil(ablyService.sendResolutionPreferenceResultHander)
    }
    
    func test_subscriberResolutionPreference_paramsCheck_resolutionIsNil() {
        // Given
        let expectation = XCTestExpectation()
        ablyService.sendResolutionPreferenceCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.resolutionPreference(resolution: nil) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablyService.sendResolutionPreferenceWasCalled)
        XCTAssertNil(ablyService.sendResolutionPreferenceResolutionParam)
        XCTAssertNotNil(ablyService.sendResolutionPreferenceResultHander)
    }
    
    func test_subscriberResolutionPreference_success() {
        // Given
        let expectation = XCTestExpectation()
        let resolution = Resolution(accuracy: .high, desiredInterval: 1.0, minimumDisplacement: 1.0)
        var isSuccess = false
        ablyService.sendResolutionPreferenceCompletionHandler = { completion in completion?(.success)}
        
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
        ablyService.sendResolutionPreferenceCompletionHandler = { completion in completion?(.failure(expectedError))}
        
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
        ablyService.startCompletionHandler = { completion in completion?(.success)}
        
        // When
        subscriber.start { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(ablyService.startWasCalled)
        XCTAssertNotNil(ablyService.startResultHandler)
    }
    
    func test_subscriberStart_success() {
        // Given
        let expectation = XCTestExpectation()
        ablyService.startCompletionHandler = { completion in completion?(.success)}
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
        ablyService.startCompletionHandler = { completion in completion?(.failure(stopError))}
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
