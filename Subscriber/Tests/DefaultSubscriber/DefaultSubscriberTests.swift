import XCTest
@testable import Subscriber

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
        
        subscriber.sendChangeRequest(resolution: nil) { result in
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
}
