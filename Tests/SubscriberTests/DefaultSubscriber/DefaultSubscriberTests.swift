import AblyAssetTrackingCore
import AblyAssetTrackingCoreTesting
@testable import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import XCTest

class DefaultSubscriberTests: XCTestCase {
    private var ablySubscriber: MockAblySubscriber!
    private var subscriber: DefaultSubscriber!
    private var trackableId: String!

    private let configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
    private let logger = InternalLogHandlerMockThreadSafe()

    override func setUpWithError() throws {
        trackableId = "Trackable-\(UUID().uuidString)"
        ablySubscriber = MockAblySubscriber(configuration: configuration, mode: .subscribe)

        subscriber = DefaultSubscriber(
            ablySubscriber: ablySubscriber,
            trackableId: trackableId,
            resolution: nil,
            logHandler: logger
        )
    }

    func test_subscriberStop_called() {
        // Given
        let expectation = XCTestExpectation()
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success) }

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
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success) }
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
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.failure(stopError)) }
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
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success) }
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
        ablySubscriber.closeResultCompletionHandler = { completion in completion?(.success) }
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
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success) }

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
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success) }

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
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.success) }

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
        ablySubscriber.updatePresenceDataCompletionHandler = { completion in completion?(.failure(expectedError)) }

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
        ablySubscriber.connectCompletionHandler = { completion in completion?(.success) }

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
        ablySubscriber.connectCompletionHandler = { completion in completion?(.success) }
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
        ablySubscriber.connectCompletionHandler = { completion in completion?(.failure(stopError)) }
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

    func test_whenSubscriberReceivesInvalidMessageErrorFromAblySubscriber_itEmitsAFailedConnectionStatus_andCallsDisconnectOnAblySubscriber() {
        let delegate = SubscriberDelegateMock()
        subscriber.delegate = delegate

        let delegateDidFailWithErrorCalledExpectation = expectation(description: "Subscriber’s delegate receives didFailWithError")
        delegate.subscriberSenderDidFailWithErrorClosure = { _, error in
            XCTAssertEqual(error.code, ErrorCode.invalidMessage.rawValue)
            delegateDidFailWithErrorCalledExpectation.fulfill()
        }

        let delegateDidChangeAssetConnectionStatusExpectation = expectation(description: "Subscriber’s delegate receives didChangeAssetConnectionStatus")
        delegate.subscriberSenderDidChangeAssetConnectionStatusClosure = { _, status in
            XCTAssertEqual(status, .failed)
            delegateDidChangeAssetConnectionStatusExpectation.fulfill()
        }

        // Expectation that disconnect is called
        expectation(for: .init { [weak self] _, _ in self?.ablySubscriber.disconnectCalled == true }, evaluatedWith: nil)

        let invalidMessageError = ErrorInformation(code: ErrorCode.invalidMessage.rawValue, statusCode: 0, message: "", cause: nil, href: nil)
        ablySubscriber.subscriberDelegate?.ablySubscriber(ablySubscriber, didFailWithError: invalidMessageError)

        waitForExpectations(timeout: 10)

        XCTAssertEqual(ablySubscriber.disconnectParamTrackableId, trackableId)
        XCTAssertNil(ablySubscriber.disconnectParamPresenceData)
    }

    func test_whenItHasAlreadyEmittedAFailedConnectionStatus_andItThenReceivesAConnectionStatusThatWouldMakeItOnline_itDoesNotEmitAnyMoreConnectionStatus() {
        let delegate = SubscriberDelegateMock()
        subscriber.delegate = delegate

        let failedStatusExpectation = expectation(description: "Subscriber’s delegate receives didChangeAssetConnectionStatus with failed status")
        delegate.subscriberSenderDidChangeAssetConnectionStatusClosure = { _, status in
            XCTAssertEqual(status, .failed)
            failedStatusExpectation.fulfill()
        }

        ablySubscriber.subscriberDelegate?.ablySubscriber(ablySubscriber, didChangeClientConnectionState: .failed)

        waitForExpectations(timeout: 10)

        delegate.subscriberSenderDidChangeAssetConnectionStatusClosure = { _, _ in
            XCTFail("Subscriber’s delegate received a connection status update")
        }

        ablySubscriber.subscriberDelegate?.ablySubscriber(ablySubscriber, didChangeClientConnectionState: .online)
        ablySubscriber.subscriberDelegate?.ablySubscriber(ablySubscriber, didChangeChannelConnectionState: .online)

        RunLoop.main.run(until: Date() + 0.5)
    }

    func test_whenItReceivesAPublisherPresentPresenceAction_itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresentTrue() {
        test_whenItReceivesAPublisherPresenceAction(.present, itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresent: true)
    }

    func test_whenItReceivesAPublisherEnterPresenceAction_itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresentTrue() {
        test_whenItReceivesAPublisherPresenceAction(.enter, itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresent: true)
    }

    func test_whenItReceivesAPublisherLeavePresenceAction_itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresentFalse() {
        test_whenItReceivesAPublisherPresenceAction(.leave, itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresent: false)
    }

    func test_whenItReceivesAPublisherAbsentPresenceAction_itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresentFalse() {
        test_whenItReceivesAPublisherPresenceAction(.absent, itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresent: false)
    }

    func test_whenItReceivesAPublisherPresenceAction(_ presenceAction: PresenceAction, itCallsDidUpdatePublisherPresenceOnDelegate_withIsPresent expectedIsPresent: Bool) {
        let delegate = SubscriberDelegateMock()
        subscriber.delegate = delegate

        let delegateDidFailWithErrorCalledExpectation = expectation(description: "Subscriber’s delegate receives didUpdatePublisherPresence with isPresent \(expectedIsPresent)")
        delegate.subscriberSenderDidUpdatePublisherPresenceClosure = { _, isPresent in
            XCTAssertEqual(isPresent, expectedIsPresent)
            delegateDidFailWithErrorCalledExpectation.fulfill()
        }
        ablySubscriber.subscriberDelegate?.ablySubscriber(ablySubscriber, didReceivePresenceUpdate: PresenceMessage(action: presenceAction, data: PresenceData(type: .publisher, resolution: nil), memberKey: ""))

        waitForExpectations(timeout: 10)
    }
}
