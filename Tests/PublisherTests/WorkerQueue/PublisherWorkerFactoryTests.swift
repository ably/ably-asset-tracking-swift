import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import XCTest

class PublisherWorkerFactoryTests: XCTestCase {
    private let logHandler = InternalLogHandlerMockThreadSafe()
    private let properties = PublisherWorkerQueueProperties()
    private let factory = PublisherWorkerFactory()

    func test_ItBuildsLegacyWork() throws {
        var legacyWorkerCalled = false
        let callback = {
            legacyWorkerCalled = true
            return
        }

        let worker = factory.createWorker(
            workerSpecification: PublisherWorkSpecification.legacy(callback: callback),
            logHandler: logHandler
        )

        XCTAssertTrue(worker is LegacyWorker<PublisherWorkerQueueProperties, PublisherWorkSpecification>)
        _ = try worker.doWork(
            properties: properties,
            doAsyncWork: { _ in },
            postWork: { _ in }
        )
        XCTAssertTrue(legacyWorkerCalled, "Legacy worker work not called")
    }
}
