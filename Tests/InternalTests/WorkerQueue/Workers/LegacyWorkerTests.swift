import XCTest
import AblyAssetTrackingInternalTesting
import AblyAssetTrackingInternal

class LegacyWorkerTests: XCTestCase
{
    private let logHandler = InternalLogHandlerMock.configured
    private let properties = WorkerQueuePropertiesMock()

    func test_doWorkShouldCallPassedInWorkCallbackAndReturnProperties()
    {
        properties.isStopped = true
        var called = false;
        let callback = {
            called = true
            return
        }

        let worker = LegacyWorker<WorkerQueuePropertiesMock, WorkerFactoryMock.WorkerSpecificationType>(work: callback, logger: logHandler)
        let updatedProperties = try! worker.doWork(
            properties: properties,
            doAsyncWork: {_ in },
            postWork: {_ in }
        )

        XCTAssertTrue(called, "Work callback was not called")
        XCTAssertTrue(updatedProperties.isStopped)
        XCTAssertTrue(properties === updatedProperties)
    }
}
