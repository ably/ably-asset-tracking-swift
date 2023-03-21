import XCTest
import AblyAssetTrackingInternalTesting
import AblyAssetTrackingInternal
import AblyAssetTrackingCore
import AblyAssetTrackingCoreTesting
import Ably

class WorkerQueueTests: XCTestCase {
    private let logHandler = InternalLogHandlerMockThreadSafe()
    private let workingQueue = DispatchQueue(label: "com.ably.AssetTracking.WorkerQueue.workingQueue")
    private let workQueue = DispatchQueue(label: "com.ably.AssetTracking.DefaultLocationService.workQueue")
    private let asyncWorkWorkingQueue = DispatchQueue(label: "com.ably.AssetTracking.DefaultLocationService.asyncWorkWorkingQueue")
    let getStoppedError = { return ErrorInformation(code: 1,
                                                    statusCode: 1,
                                                    message: "Stopped",
                                                    cause: nil,
                                                    href: nil)}
    let properties = WorkerQueuePropertiesMock()
    let workerFactory = WorkerFactoryMock()
    let worker = WorkerMock()

    var workRequest: WorkRequest<WorkerMock>!

    var workerQueue: WorkerQueue<WorkerFactoryMock.PropertiesType, WorkerFactoryMock.WorkerSpecificationType>!

    override func setUp() async throws {
        worker.doWorkPropertiesDoAsyncWorkPostWorkReturnValue = properties
        workRequest = WorkRequest(workerSpecification: worker)
        workerFactory.createWorkerWorkerSpecificationLogHandlerReturnValue = worker

        workerQueue = WorkerQueue<WorkerFactoryMock.PropertiesType, WorkerMock>(properties: properties,
                                                                                workingQueue: workingQueue,
                                                                                logHandler: logHandler,
                                                                                workerFactory: workerFactory,
                                                                                asyncWorkWorkingQueue: asyncWorkWorkingQueue,
                                                                                getStoppedError: getStoppedError)
    }

    func test_queueShouldCallWorkersDoWorkMethod() {
        // given
        properties.isStopped = false
        let outputProperties = WorkerQueuePropertiesMock()
        let expectation = expectation(description: "doWorkPropertiesDoAsyncWorkPostWorkClosure invokes")

        // when
        workRequest.workerSpecification.doWorkPropertiesDoAsyncWorkPostWorkClosure = { _, _, _ in
            expectation.fulfill()
            return outputProperties
        }
        workerQueue.enqueue(workRequest: workRequest)
        wait(for: [expectation], timeout: 5.0)

        // then
        XCTAssertEqual(workRequest.workerSpecification.doWorkPropertiesDoAsyncWorkPostWorkCallsCount, 1)
        XCTAssertEqual(workRequest.workerSpecification.doWhenStoppedErrorCallsCount, 0)
    }

    func test_stoppedQueueShouldCallWorkersOnStoppedMethod() {
        // given
        properties.isStopped = true
        let expectation = expectation(description: "doWhenStoppedErrorClosure invokes")

        workerQueue = WorkerQueue<WorkerFactoryMock.PropertiesType, WorkerMock>(properties: properties,
                                                                                workingQueue: workingQueue,
                                                                                logHandler: logHandler,
                                                                                workerFactory: workerFactory,
                                                                                asyncWorkWorkingQueue: asyncWorkWorkingQueue,
                                                                                getStoppedError: getStoppedError)
        // when
        workRequest.workerSpecification.doWhenStoppedErrorClosure = { _ in
            expectation.fulfill()
        }
        workerQueue.enqueue(workRequest: workRequest)
        wait(for: [expectation], timeout: 5.0)

        // then
        XCTAssertEqual(workRequest.workerSpecification.doWhenStoppedErrorCallsCount, 1)
    }

    func test_queueCallsWorkersUnexpectedErrorMethodWhenAnErrorIsThrownByWorkersDoWorkMethod() {
        // given
        properties.isStopped = false
        let expectation = expectation(description: "onUnexpectedErrorErrorPostWorkClosure invokes")
        workRequest.workerSpecification.doWorkPropertiesDoAsyncWorkPostWorkThrowableError = WorkerQueueThrowableError()

        // when
        workRequest.workerSpecification.onUnexpectedErrorErrorPostWorkClosure = { _, _ in
            expectation.fulfill()
        }
        workerQueue.enqueue(workRequest: workRequest)
        wait(for: [expectation], timeout: 5.0)

        // then
        XCTAssertEqual(workRequest.workerSpecification.onUnexpectedErrorErrorPostWorkCallsCount, 1)
    }

    func test_queueCallsWorkersUnexpectedAsyncErrorMethodWhenAnErrorIsThrownByWorkersAsyncWork() {
        // given
        let outputProperties = WorkerQueuePropertiesMock()
        let expectation = expectation(description: "doWorkPropertiesDoAsyncWorkPostWorkClosure invokes")

        workRequest.workerSpecification.doWorkPropertiesDoAsyncWorkPostWorkClosure = { _, asyncWorkClosure, _  in
            asyncWorkClosure({ completion in
                completion(WorkerQueueThrowableError())
            })
            expectation.fulfill()
            return outputProperties
        }
        properties.isStopped = false

        // when
        workerQueue.enqueue(workRequest: workRequest)
        _ = XCTWaiter.wait(for: [expectation], timeout: 2.0)

        // then
        XCTAssertEqual(workRequest.workerSpecification.onUnexpectedAsyncErrorErrorPostWorkCallsCount, 1)
    }
}

class WorkerQueueThrowableError: Error {}
