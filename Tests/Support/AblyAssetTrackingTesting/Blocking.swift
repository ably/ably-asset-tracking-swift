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
        /// The ``WaiterContext`` was already cancelled by the time the wait began.
        case contextCancelled
    }

    /// Manages a private thread in which ``Blocking.run`` will perform its `XCTWaiter.wait()` operations.
    ///
    /// `XCTWaiter` allows an "inner" waiter to piggy-back on the timeout of an "outer" waiter, as long as these two waiters perform their waits on the same thread (the concept of "inner" and "outer" should be thought of as being defined in terms of the call stack of the waiting thread). For more information, see `Blocking.error.interrupted`. By making sure that all waits happen on the same thread, `WaiterContext` allows ``Blocking.run`` calls made from different threads to also take advantage of this behaviour.
    public class WaiterContext: NSObject {
        private let logHandler: InternalLogHandler
        private let loggingID: String
        private let completionQueue: DispatchQueue

        private var waiterThread: Thread!

        private var queue = Queue()
        // Used to synchronise access to queue
        private let queueLock = NSLock()

        // Signalled when `queue` may contain a new expectation for `waiterThread` to pick up.
        private let expectationAvailabilitySemaphore = DispatchSemaphore(value: 0)

        /// A queue of expectations to be waited for.
        private struct Queue {
            /// Expectations that still need to be waited for.
            private var pending: [AsyncExpectation] = []

            var isEmpty: Bool {
                pending.isEmpty
            }

            /// Removes and returns the first pending expectation, or returns `nil` if there are none.
            mutating func dequeue() -> AsyncExpectation? {
                guard !pending.isEmpty else {
                    return nil
                }

                let dequeued = pending[0]
                pending.remove(at: 0)

                return dequeued
            }

            /// Adds a pending expectation.
            mutating func enqueue(_ expectation: AsyncExpectation) {
                pending.append(expectation)
            }
        }

        /// Creates a context that manages a thread in which ``Blocking.run`` will perform its `XCTWaiter.wait()` operations.
        ///
        /// You must call ``cancel()`` when you are finished with this context, so that its thread can be ended.
        public init(logHandler: InternalLogHandler) {
            // We generate a unique ID to use for the thread name. We truncate it to the first component of the UUID since if I used a full UUID then the thread name didn’t show up in Xcode’s debugger (some sort of length limit I guess 🤷‍♂️)
            self.loggingID = UUID().uuidString.components(separatedBy: "-").first!
            self.logHandler = logHandler.addingSubsystem(.typed(Self.self)).addingSubsystem(.named(loggingID))

            let threadName = "com.ably.tracking.tests.WaiterContext.\(loggingID)"

            self.completionQueue = .init(label: threadName)
            super.init()
            self.waiterThread = startWaiterThread(named: threadName)
        }

        /// Cancels the context’s private thread. The thread will not terminate until the wait for all expectations added using `wait(for:, completion:)` has completed.
        ///
        /// Subsequent calls to `wait(for:, completion:)` will fail with `Error.contextCancelled`.
        public func cancel() {
            logHandler.debug(message: "cancel() called; cancelling waiterThread", error: nil)
            waiterThread.cancel()
            // To end the thread's wait and allow it to exit
            expectationAvailabilitySemaphore.signal()
        }

        /// Contains the details of an expectation that needs to be waited for, and a callback to be executed with the result of the wait.
        private struct AsyncExpectation {
            var expectation: Expectation
            var completion: (Expectation.Result) -> Void
            var completionQueue: DispatchQueue

            /// Calls `expectation.wait()` and then passes the result to `completion` on `completionQueue`.
            func wait() -> Void {
                let result = expectation.wait()
                completionQueue.async {
                    completion(result)
                }
            }
        }

        /// Contains the details of an expectation that needs to be waited for.
        fileprivate struct Expectation {
            private var waiter = XCTWaiter()
            var expectation: XCTestExpectation
            /// See `Blocking.run`’s `timeout` parameter.
            var timeout: TimeInterval?
            var logHandler: InternalLogHandler
            var label: String

            init(expectation: XCTestExpectation, timeout: TimeInterval?, logHandler: InternalLogHandler, label: String) {
                self.expectation = expectation
                self.timeout = timeout
                self.logHandler = logHandler
                self.label = label
            }

            /// The result of waiting for an `XCTWaiter`.
            struct Result {
                var result: XCTWaiter.Result
                /// The timeout that was passed to `XCTWaiter.wait(for:, timeout:)`.
                var resolvedTimeout: TimeInterval
            }

            /// Waits for `expectation` to be fulfilled, using the given `timeout`, and returns the result. The wait is performed on the current thread.
            func wait() -> Result {
                let waiterTimeout: TimeInterval
                if let timeout {
                    logHandler.debug(message: "Blocking.run waiting for \(timeout)s for operation to complete (\(label))", error: nil)
                    waiterTimeout = timeout
                } else {
                    logHandler.debug(message: "Blocking.run waiting indefinitely for operation to complete (\(label))", error: nil)
                    waiterTimeout = .greatestFiniteMagnitude
                }

                let result = waiter.wait(for: [expectation], timeout: waiterTimeout)

                logHandler.debug(message: "Blocking.run finished waiting for operation to complete (\(label)): \(result)", error: nil)

                return .init(result: result, resolvedTimeout: waiterTimeout)
            }
        }

        /// Starts and new returns a new thread with the given name, and executes `waiterThreadBody()` on the new thread.
        private func startWaiterThread(named threadName: String) -> Thread {
            let threadPopulationSemaphore = DispatchSemaphore(value: 0)
            var waiterThread: Thread!

            Thread.detachNewThread { [weak self] in
                let currentThread = Thread.current
                currentThread.name = threadName
                waiterThread = currentThread
                threadPopulationSemaphore.signal()

                self?.waiterThreadBody()
            }

            threadPopulationSemaphore.wait()
            return waiterThread
        }

        /// The body of `waiterThread`.
        ///
        /// Picks up and waits for expectations from `queue` one by one. In the process of waiting for an expectation, it may as a side effect end up waiting for other expectations whilst the `XCTWaiter` runs the run loop (see `checkForExpectations()`).
        private func waiterThreadBody() {
            logHandler.debug(message: "Started thread: \(Thread.current)", error: nil)

            while true {
                guard !Thread.current.isCancelled && queue.isEmpty else {
                    logHandler.debug(message: "Thread has been cancelled; exiting", error: nil)
                    break
                }

                logHandler.debug(message: "Thread waiting to receive an expectation", error: nil)
                expectationAvailabilitySemaphore.wait()

                queueLock.lock()
                let expectation = queue.dequeue()
                queueLock.unlock()

                guard let expectation else {
                    logHandler.debug(message: "No expectations to wait for (direct)", error: nil)
                    continue
                }

                logHandler.debug(message: "Thread calling wait() on expectation (direct)", error: nil)
                // Note that the run loop will run on this thread during the execution of wait()
                expectation.wait()
                logHandler.debug(message: "Thread completed call to wait() on expectation (direct)", error: nil)
            }
        }

        /// Schedules an expectation to be waited for on the context’s private thread.
        ///
        /// If this method returns without throwing an error, it is guaranteed to wait for the expectation (to be fulfilled, time out, or be interrupted) and then call the given completion handler. This will happen even if the context is subsequently cancelled.
        ///
        /// - Parameters:
        ///     - expectation: The expectation to wait for on the context’s private thread.
        ///     - completion: A callback to be called with the result of the wait for `expectation`. Will be called on a dispatch queue private to the context.
        ///
        /// - Throws: `Error.contextCancelled` if the context has _already_ been cancelled using `cancel()`. In this case `completion` will not be called.
        fileprivate func wait(for expectation: Expectation, completion: @escaping (Expectation.Result) -> Void) throws {
            let asyncExpectation = AsyncExpectation(expectation: expectation, completion: completion, completionQueue: completionQueue)

            queueLock.lock()
            queue.enqueue(asyncExpectation)
            queueLock.unlock()

            // (We signal both the main body of `waiterThread` and also its run loop to tell them that there is potentially a new expectation in the queue. Precisely one of them will actually end up dequeueing and waiting for the expectation.)

            expectationAvailabilitySemaphore.signal()

            // If waiterThread is currently blocked by an in-progress `XCTWaiter`, we still want it to be able to wait for additional expectations inside run loop events. So schedule a run loop event to check for expectations and pick this one up if it wasn't already picked up above.
            perform(#selector(checkForExpectations), on: waiterThread, with: nil, waitUntilDone: false)
        }

        /// Executed on the run loop of `waiterThread`.
        @objc func checkForExpectations() {
            logHandler.debug(message: "Thread checking for pending expectations in run loop", error: nil)
            queueLock.lock()
            let expectation = queue.dequeue()
            queueLock.unlock()

            guard let expectation else {
                logHandler.debug(message: "No expectations to wait for (run loop)", error: nil)
                return
            }

            logHandler.debug(message: "Thread calling wait() on expectation (run loop)", error: nil)
            expectation.wait()
            logHandler.debug(message: "Thread completed call to wait() on expectation (run loop)", error: nil)
        }
    }

    /// Blocks the current thread until an asynchronous operation completes, returning its result.
    ///
    /// This method internally uses ``XCTWaiter``, which runs the run loop for the current thread so that run loop events can still be delivered whilst waiting.
    ///
    /// - Parameters:
    ///     - label: A description of the operation. Will be used for logging and error messages.
    ///     - timeout: The maximum amount of time to wait for the operation to complete. If this duration is exceeded, then ``Blocking.Error.timedOut`` will be thrown. If nil, then no timeout will be enforced, and this method will run until the operation completes or the wait is interrupted by an "outer" waiter (see ``Blocking.Error.interrupted``).
    ///     - logHandler: A log handler that this method will log to.
    ///     - waiterContext: An optional context, which provides a thread on which this method will perform its `XCTWaiter.wait()` call. The default value is `nil`, which causes the wait to be performed on the calling thread. You are likely to only want to pass a non-nil value if you wish to take advantage of `XCTWaiter`’s interruption behaviour across calls to `Blocking.run` made from different threads.
    ///     - operation: The operation to be executed.
    ///
    /// - Throws: ``Blocking.Error`` if the operation does not succeed, or if it times out or is interrupted by an "outer" ``XCTWaiter`` timing out first.
    /// - Returns: The operation’s result if it succeeds.
    public static func run<Success, Failure>(label: String, timeout: TimeInterval?, logHandler: InternalLogHandler, waiterContext: WaiterContext? = nil, _ operation: (@escaping (Result<Success, Failure>) -> Void) -> Void) throws -> Success {
        logHandler.debug(message: "Start Blocking.run (\(label))", error: nil)

        let expectation = XCTestExpectation(description: label)

        var result: Result<Success, Failure>?

        logHandler.debug(message: "Perform Blocking.run’s operation (\(label))", error: nil)
        operation { asyncResult in
            logHandler.debug(message: "Blocking.run’s operation called its result handler (\(label)) with result \(asyncResult)", error: nil)
            result = asyncResult
            expectation.fulfill()
        }

        let contextExpectation = WaiterContext.Expectation(
            expectation: expectation,
            timeout: timeout,
            logHandler: logHandler,
            label: label
        )

        let expectationWaitResult: WaiterContext.Expectation.Result

        if let waiterContext {
            var maybeExpectationWaitResult: WaiterContext.Expectation.Result?

            let outerExpectation = XCTestExpectation(description: "Outer expectation (\(label))")
            logHandler.debug(message: "Blocking.run adding expectation to waiter context (\(label))", error: nil)
            try waiterContext.wait(for: contextExpectation) { result in
                maybeExpectationWaitResult = result
                outerExpectation.fulfill()
            }

            // This outer waiter serves to run the run loop on the _calling_ thread (not that of the waiter context).
            let outerWaiter = XCTWaiter()
            logHandler.debug(message: "Blocking.run waiting indefinitely for outer waiter wait to complete (\(label))", error: nil)
            let outerResult = outerWaiter.wait(for: [outerExpectation], timeout: .greatestFiniteMagnitude /* A timeout is already enforced by contextExpectation’s waiter */)
            logHandler.debug(message: "Blocking.run outer waiter wait completed (\(label)): \(outerResult)", error: nil)

            expectationWaitResult = maybeExpectationWaitResult!
        } else {
            expectationWaitResult = contextExpectation.wait()
        }

        switch expectationWaitResult.result {
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
            throw Error.timedOut(duration: expectationWaitResult.resolvedTimeout, label: logHandler.tagMessage(label))
        case .interrupted:
            logHandler.debug(message: "Blocking.run was interrupted (\(label))", error: nil)
            throw Error.interrupted(label: logHandler.tagMessage(label))
        default:
            fatalError("Unexpected expectationWaitResult \(expectationWaitResult)")
        }
    }
}
