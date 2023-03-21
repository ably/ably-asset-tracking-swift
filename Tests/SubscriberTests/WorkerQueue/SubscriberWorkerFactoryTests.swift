import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting

class SubscriberWorkerFactoryTests: XCTestCase {
    private let logHandler = InternalLogHandlerMockThreadSafe()
    private let properties = SubscriberWorkerQueueProperties()
    private let factory = SubscriberWorkerFactory()

    func test_ItBuildsLegacyWork() {
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
        _ = try! worker.doWork(
            properties: properties,
            doAsyncWork: { _ in },
            postWork: { _ in }
        )
        XCTAssertTrue(legacyWorkerCalled, "Legacy worker work not called")
    }
}
