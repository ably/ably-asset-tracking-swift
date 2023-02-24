import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting

class SubscriberWorkerFactoryTests: XCTestCase
{
    private let logHandler = InternalLogHandlerMock.configured
    private var legacyWorkerCalled = false
    private let properties = SubscriberWorkerQueueProperties()
    private let factory = SubscriberWorkerFactory()

    func test_ItBuildsLegacyWork()
    {
        let callback = {[weak self] in
            self?.legacyWorkerCalled = true
            return
        }

        let worker = factory.createWorker(
            workerSpecification: SubscriberWorkSpecification.legacy(callback: callback),
            logHandler: logHandler
        )

        XCTAssertTrue(worker is LegacyWorker<SubscriberWorkerQueueProperties, SubscriberWorkSpecification>)
        let _ = try! worker.doWork(
            properties: properties,
            doAsyncWork: {_ in },
            postWork: {_ in }
        )
        XCTAssertTrue(self.legacyWorkerCalled, "Legacy worker work not called")
    }
}
