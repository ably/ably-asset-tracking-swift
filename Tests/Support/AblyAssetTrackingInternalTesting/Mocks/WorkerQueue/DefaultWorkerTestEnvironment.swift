import XCTest
import AblyAssetTrackingInternal

private enum ExampleError: Error {
    case example
}

public protocol DefaultWorkerFactory<Worker> {
    associatedtype Worker: DefaultWorker

    func createWorker() -> Worker
}

// TODO document and put in InternalTesting
public class DefaultWorkerTestEnvironment<WorkerFactory: DefaultWorkerFactory> {
    private let workerFactory: WorkerFactory

    public init(factory: WorkerFactory) {
        self.workerFactory = factory
    }

    /// Implements the following test cases:
    ///
    /// Given... a worker created by workerFactory
    /// When... doWhenStopped is called on the worker, with an arbitrary error
    /// Then... the worker does nothing
    ///
    /// Given... a worker created by workerFactory
    /// When... onUnexpectedError is called on the worker, with an arbitrary error
    /// Then... the worker does not post any work
    ///
    /// Given... a worker created by workerFactory
    /// When... onUnexpectedAsyncError is called on the worker, with an arbitrary error
    /// Then... the worker does not post any work
    public func test() throws {
        // TODO MultipleErrors
        try test_doWhenStopped()
        try test_onUnexpectedError()
        try test_onUnexpectedAsyncError()
    }

    // Implements the following test case:
    //
    // Given... a worker created by workerFactory
    // When... doWhenStopped is called on the worker, with an arbitrary error
    // Then... the worker does nothing
    private func test_doWhenStopped() throws {
        let worker = workerFactory.createWorker()

        worker.doWhenStopped(error: ExampleError.example)

        // There's not really any assertion to make here
    }

    // Given... a worker created by workerFactory
    // When... onUnexpectedError is called on the worker, with an arbitrary error
    // Then... the worker does not post any work
    private func test_onUnexpectedError() throws {
        let worker = workerFactory.createWorker()

        var postedWork = false

        worker.onUnexpectedError(error: ExampleError.example) { _ in
            postedWork = true
        }

        XCTAssertFalse(postedWork)
    }

    // Given... a worker created by workerFactory
    // When... onUnexpectedAsyncError is called on the worker, with an arbitrary error
    // Then... the worker does not post any work
    private func test_onUnexpectedAsyncError() throws {
        let worker = workerFactory.createWorker()

        var postedWork = false

        worker.onUnexpectedAsyncError(error: ExampleError.example) { _ in
            postedWork = true
        }

        XCTAssertFalse(postedWork)
    }
}
