@testable import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import XCTest

class UpdatePublisherPresenceWorkerTests: XCTestCase {
    func test_behavesLikeDefaultWorker() throws {
        class Factory: DefaultWorkerFactory {
            func createWorker() -> UpdatePublisherPresenceWorker {
                let arbitraryPresenceMessage = PresenceMessage(action: .present, data: .init(type: .publisher), memberKey: "")
                return .init(presenceMessage: arbitraryPresenceMessage, logHandler: nil)
            }
        }

        // Given... an instance of UpdatePublisherPresenceWorker, initialized with an arbitrary presence message,
        // When... doWhenStopped is called on the worker, with an arbitrary error,
        // Then... the worker does nothing.
        //
        // Given... an instance of UpdatePublisherPresenceWorker, initialized with an arbitrary presence message,
        // When... onUnexpectedError is called on the worker, with an arbitrary error,
        // Then... the worker does not post any work.
        //
        // Given... an instance of UpdatePublisherPresenceWorker, initialized with an arbitrary presence message,
        // When... onUnexpectedAsyncError is called on the worker, with an arbitrary error,
        // Then... the worker does not post any work.
        try DefaultWorkerTestEnvironment(factory: Factory()).test()
    }

    func test_doWork() throws {
        // Given... an instance of UpdatePublisherPresenceWorker, initialized with an arbitrary presence message,

        // TODO given / when / then
        let arbitraryPresenceMessage = PresenceMessage(action: .present, data: .init(type: .publisher), memberKey: "")
        let worker = UpdatePublisherPresenceWorker(presenceMessage: arbitraryPresenceMessage, logHandler: nil)

        let properties = SubscriberWorkerQueuePropertiesImpl(initialResolution: nil)

        let result = try SubscriberWorkerTestScenario(worker: worker).test_doWork(properties: properties)

        XCTAssertTrue(result.postedAsyncWork.isEmpty)
        XCTAssertTrue(result.postedWork.isEmpty)
        XCTAssertEqual(
            result
                .propertiesMock
                .updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedArguments?
                .presenceMessages,
            [arbitraryPresenceMessage]
        )
    }
}
