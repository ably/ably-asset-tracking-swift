import AblyAssetTrackingInternal
import AblyAssetTrackingTesting
import XCTest

/// A factory for creating workers to be tested by `DefaultWorkerTestScenarios`.
public protocol DefaultWorkerFactory<Worker> {
    /// The type of worker created by this factory.
    associatedtype Worker: DefaultWorker

    /// Creates a new worker instance.
    func createWorker() -> Worker
}

// An arbitrary error.
private enum ExampleError: Error {
    case example
}

/// Provides a set of unit tests for the default method implementations of the `DefaultWorker` protocol.
///
/// Intended to be used inside the unit tests of a worker type that conforms to `DefaultWorker`, to verify and document that it provides the expected behaviour.
public struct DefaultWorkerTestScenarios<WorkerFactory: DefaultWorkerFactory> {
    private let workerFactory: WorkerFactory

    /// Creates an instance of the test environment, for testing workers created by `factory`.
    public init(factory: WorkerFactory) {
        self.workerFactory = factory
    }

    /// Implements the following test cases:
    ///
    /// Given... a worker created by ${workerFactory},
    /// When... doWhenStopped is called on the worker, with an arbitrary error,
    /// Then... the worker does nothing.
    ///
    /// Given... a worker created by ${workerFactory},
    /// When... onUnexpectedError is called on the worker, with an arbitrary error,
    /// Then... the worker does not post any work.
    ///
    /// Given... a worker created by ${workerFactory},
    /// When... onUnexpectedAsyncError is called on the worker, with an arbitrary error,
    /// Then... the worker does not post any work.
    public func test() throws {
        // swiftlint:disable opening_brace
        let tests = [
            { try performTest_doWhenStopped() },
            { try performTest_onUnexpectedError() },
            { try performTest_onUnexpectedAsyncError() }
        ]
        // swiftlint:enable opening_brace

        try tests.reduce(into: MultipleErrors()) { multipleErrors, test in
            do {
                try test()
            } catch {
                multipleErrors.add(error)
            }
        }
        .check()
    }

    // Implements the following test case:
    //
    // Given... a worker created by ${workerFactory},
    // When... doWhenStopped is called on the worker, with an arbitrary error,
    // Then... the worker does nothing.
    private func performTest_doWhenStopped() throws {
        let worker = workerFactory.createWorker()

        worker.doWhenStopped(error: ExampleError.example)

        // There's not really any assertion to make here
    }

    // Given... a worker created by ${workerFactory},
    // When... onUnexpectedError is called on the worker, with an arbitrary error,
    // Then... the worker does not post any work.
    private func performTest_onUnexpectedError() throws {
        let worker = workerFactory.createWorker()

        var postedWork = false

        worker.onUnexpectedError(error: ExampleError.example) { _ in
            postedWork = true
        }

        XCTAssertFalse(postedWork)
    }

    // Given... a worker created by ${workerFactory},
    // When... onUnexpectedAsyncError is called on the worker, with an arbitrary error,
    // Then... the worker does not post any work.
    private func performTest_onUnexpectedAsyncError() throws {
        let worker = workerFactory.createWorker()

        var postedWork = false

        worker.onUnexpectedAsyncError(error: ExampleError.example) { _ in
            postedWork = true
        }

        XCTAssertFalse(postedWork)
    }
}
