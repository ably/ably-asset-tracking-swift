import Ably
import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import XCTest

class SubscriberSystemTests: XCTestCase {
    func test_whenSubscriberReceivesMalformedMessageDataFromAbly_itEmitsAFailedConnectionStatus() {
        let trackingId = UUID().uuidString

        let delegate = SubscriberDelegateMock()

        let subscriberStartExpectation = expectation(description: "Subscriber successfully starts")
        let subscriber = SubscriberFactory.subscribers()
            .trackingId(trackingId)
            .connection(ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: UUID().uuidString))
            .delegate(delegate)
            .start { result in
                switch result {
                case .success: subscriberStartExpectation.fulfill()
                case let .failure(error): XCTFail("Subscriber failed to start: \(error)")
                }
            }

        waitForExpectations(timeout: 10)

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

        let ably = ARTRealtime(key: Secrets.ablyApiKey)
        let channel = ably.channels.get("tracking:\(trackingId)")

        let publishExpectation = expectation(description: "Message published to channel")
        channel.publish("enhanced", data: "{\"something\": \"anotherThing\"}") { error in
            if let error {
                XCTFail("Failed to publish message: \(error)")
            } else {
                publishExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10)

        let subscriberStopExpectation = expectation(description: "Wait for subscriber to stop")
        subscriber?.stop(completion: { result in
            switch result {
            case .success:
                subscriberStopExpectation.fulfill()
            case let .failure(errorInfo):
                XCTFail("Failed to stop subscriber, with error \(errorInfo)")
            }
        })
        waitForExpectations(timeout: 10)
    }
}
