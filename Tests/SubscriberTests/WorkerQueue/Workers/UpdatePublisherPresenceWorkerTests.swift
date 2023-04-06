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
        try DefaultWorkerTestScenarios(factory: Factory()).test()
    }

    func test_doWork() throws {
        // Given... an instance of UpdatePublisherPresenceWorker, initialized with an arbitrary presence message `presenceMessage`,
        let presenceMessage = PresenceMessage(action: .present, data: .init(type: .publisher), memberKey: "") // arbitrarily chosen
        let worker = UpdatePublisherPresenceWorker(presenceMessage: presenceMessage, logHandler: nil)

        // When... doWork is called on the worker, passing an arbitrary properties object,

        let propertiesMock = SubscriberWorkerQueuePropertiesMock(isStopped: false /* arbitarily chosen */)
        let result = try WorkerTestScenario(worker: worker).test_doWork(properties: propertiesMock.properties)

        // Then...

        // ...it does not post any worker specifications...
        XCTAssertTrue(result.postedWork.isEmpty)

        // ...and does not post any async work...
        XCTAssertTrue(result.postedAsyncWork.isEmpty)

        // ...and it calls the properties object’s updateForPresenceMessagesAndThenDelegateStateEventsIfRequired method, passing an array containing `presenceMessage`.
        XCTAssertEqual(
            propertiesMock
                .specificMock
                .updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedArguments?
                .presenceMessages,
            [presenceMessage]
        )
    }
}
