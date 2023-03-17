import Foundation
import XCTest
import AblyAssetTrackingInternal

/// Provides convenience methods for blocking the current thread until an asynchronous piece of work completes.
public enum Blocking {
    private enum Error: Swift.Error {
        /// The operation did not complete within the specified timeout.
        case timedOut(duration: TimeInterval, label: String)
        /// From the documentation of ``XCTWaiter.Result.interrupted``: "This occurs when an "outer" waiter times out, resulting in any waiters nested inside it being interrupted to allow the call stack to quickly unwind."
        case interrupted(label: String)
    }

    /// Blocks the current thread until an asynchronous operation completes, returning its result.
    ///
    /// This method internally uses ``XCTWaiter``, which runs the run loop for the current thread so that run loop events can still be delivered whilst waiting.
    ///
    /// - Parameters:
    ///     - label: A description of the operation. Will be used for logging and error messages.
    ///     - timeout: The maximum amount of time to wait for the operation to complete. If this duration is exceeded, then ``Blocking.Error.timedOut`` will be thrown. If nil, then no timeout will be enforced, and this method will run until the operation completes or the wait is interrupted by an "outer" waiter (see ``Blocking.Error.interrupted``).
    ///     - logHandler: A log handler that this method will log to.
    ///     - operation: The operation to be executed.
    ///
    /// - Throws: ``Blocking.Error`` if the operation does not succeed, or if it times out or is interrupted by an "outer" ``XCTWaiter`` timing out first.
    /// - Returns: The operation’s result if it succeeds.
    public static func run<Success, Failure>(label: String, timeout: TimeInterval?, logHandler: InternalLogHandler, _ operation: (@escaping (Result<Success, Failure>) -> Void) -> Void) throws -> Success {
        logHandler.debug(message: "Start Blocking.run (\(label))", error: nil)

        let waiter = XCTWaiter()
        let expectation = XCTestExpectation(description: label)

        var result: Result<Success, Failure>?

        logHandler.debug(message: "Perform Blocking.run’s operation (\(label))", error: nil)
        operation { asyncResult in
            logHandler.debug(message: "Blocking.run’s operation called its result handler (\(label)) with result \(asyncResult)", error: nil)
            result = asyncResult
            expectation.fulfill()
        }


        let waiterTimeout: TimeInterval
        if let timeout {
            logHandler.debug(message: "Blocking.run waiting for \(timeout)s for operation to complete (\(label))", error: nil)
            waiterTimeout = timeout
        } else {
            logHandler.debug(message: "Blocking.run waiting indefinitely for operation to complete (\(label))", error: nil)
            waiterTimeout = .greatestFiniteMagnitude
        }
        let expectationWaitResult = waiter.wait(for: [expectation], timeout: waiterTimeout)

        switch expectationWaitResult {
        case .completed:
            switch result! {
            case .success(let value):
                logHandler.debug(message: "Blocking.run’s operation completed successfully (\(label))", error: nil)
                return value
            case .failure(let error):
                logHandler.error(message: "Blocking.run’s operation failed (\(label))", error: error)
                throw error
            }
        case .timedOut:
            logHandler.debug(message: "Blocking.run timed out (\(label))", error: nil)
            throw Error.timedOut(duration: waiterTimeout, label: logHandler.tagMessage(label))
        case .interrupted:
            logHandler.debug(message: "Blocking.run was interrupted (\(label))", error: nil)
            throw Error.interrupted(label: logHandler.tagMessage(label))
        default:
            fatalError("Unexpected expectationWaitResult \(expectationWaitResult)")
        }
    }
}
