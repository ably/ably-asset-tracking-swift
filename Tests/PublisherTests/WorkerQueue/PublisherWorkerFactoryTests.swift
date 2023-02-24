import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting

class PublisherWorkerFactoryTests: XCTestCase
{
    private let logHandler = InternalLogHandlerMock.configured
    private var legacyWorkerCalled = false
    private let properties = PublisherWorkerQueueProperties()
    private let factory = PublisherWorkerFactory()

    func test_ItBuildsLegacyWork()
    {
        let callback = {[weak self] in
            self?.legacyWorkerCalled = true
            return
        }

        let worker = factory.createWorker(
            workerSpecification: PublisherWorkSpecification.legacy(callback: callback),
            logHandler: logHandler
        )

        XCTAssertTrue(worker is LegacyWorker<PublisherWorkerQueueProperties, PublisherWorkSpecification>)
        let _ = try! worker.doWork(
            properties: properties,
            doAsyncWork: {_ in },
            postWork: {_ in }
        )
        XCTAssertTrue(self.legacyWorkerCalled, "Legacy worker work not called")
    }
}
