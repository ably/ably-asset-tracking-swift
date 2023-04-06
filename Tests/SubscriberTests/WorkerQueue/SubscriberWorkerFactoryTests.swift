@testable import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import XCTest

class SubscriberWorkerFactoryTests: XCTestCase {
    private let logHandler = InternalLogHandlerMockThreadSafe()
    private let factory = SubscriberWorkerFactory()
    private var subscriber: Subscriber!
    private var ablySubscriber: MockAblySubscriber!
    private var trackableId: String!
    private let logger = InternalLogHandlerMockThreadSafe()
    private var properties: SubscriberWorkerQueueProperties!
    private let configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")

    override func setUp() async throws {
        trackableId = "Trackable-\(UUID().uuidString)"
        ablySubscriber = MockAblySubscriber(configuration: configuration, mode: .subscribe)
        subscriber = DefaultSubscriber(
            ablySubscriber: ablySubscriber,
            trackableId: trackableId,
            resolution: nil,
            logHandler: logger
        )
        properties = SubscriberWorkerQueueProperties(
            isStopped: false,
            specific: SubscriberSpecificWorkerQueuePropertiesImpl(initialResolution: nil, subscriber: subscriber)
        )
    }

    func test_ItBuildsLegacyWork() throws {
        var legacyWorkerCalled = false
        let callback = {
            legacyWorkerCalled = true
            return
        }

        let worker = factory.createWorker(
            workerSpecification: SubscriberWorkSpecification.legacy(callback: callback),
            logHandler: logHandler
        )

        XCTAssertTrue(worker is LegacyWorker<SubscriberWorkerQueueProperties, SubscriberWorkSpecification>)
        _ = try worker.doWork(
            properties: properties,
            doAsyncWork: { _ in },
            postWork: { _ in }
        )
        XCTAssertTrue(legacyWorkerCalled, "Legacy worker work not called")
    }

    func test_updatePublisherPresence() {
        let worker = factory.createWorker(
            workerSpecification: .updatePublisherPresence(
                presenceMessage: .init(action: .present, data: .init(type: .publisher), memberKey: "")
            ),
            logHandler: nil
        )

        XCTAssertTrue(worker is UpdatePublisherPresenceWorker)
    }
}
