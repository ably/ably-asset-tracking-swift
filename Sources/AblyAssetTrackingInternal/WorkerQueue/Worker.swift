import AblyAssetTrackingCore
import Foundation

/// A [Worker] interface represents workers which execute work inside [WorkerQueue].
/// PropertiesType: - the type of properties used by this worker as both input and output.
/// WorkerSpecificationType - the type of specification used to post another worker back to the queue.
public protocol Worker<PropertiesType, WorkerSpecificationType>: AnyObject {
    associatedtype PropertiesType
    associatedtype WorkerSpecificationType

    typealias WorkerAsyncWorkCompletionHandler = (Error?) -> Void
    /// This function is provided in order for implementors to implement synchronous work. Any asynchronous tasks
    /// should be executed inside [doAsyncWork] function. If a worker needs to delegate another task to the queue
    /// pass it to [postWork] function.
    /// - parameters:
    ///    - properties: current state of publisher to be used by this worker.
    ///    - doAsyncWork: wrapper function for asynchronous work.
    ///    - postWork: function that allows worker to add other workers to the queue calling it.
    /// - Returns: updated Properties modified by this worker.
    func doWork(
        properties: PropertiesType,
        doAsyncWork: (@escaping (WorkerAsyncWorkCompletionHandler) -> Void) -> Void,
        postWork: @escaping (WorkerSpecificationType) -> Void
    ) throws -> PropertiesType
    /// This function is provided in order for implementers to define what should happen when the worker
    /// cannot ``doWork(properties:doAsyncWork:postWork:)`` because the queue was stopped
    /// and no workers should be executed.
    /// This should usually be a call to the worker's completion function with a failure with an Error.
    ///  - parameters:
    ///     - error: an error created by the stopped worker queue.
    func doWhenStopped(error: Error)

    /// This function is used to to define what should happen when the worker breaks due to an unexpected error while
    /// ``doWork`` or ``doWhenStopped`` is being executed.
    /// This should usually be a rollback operation and/or a call to the worker's ``completion`` function
    /// with a failure with an ``Error``
    ///  - parameters:
    ///     - error: an unexpected error that broke the worker.
    ///     - postWork: a function that allows a worker to add othe workers to a queue.
    func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void)

    /// This function is used to define what should happen when the worker breaks due to an unexpected error while the
    /// async work from ``doWork`` is being executed.
    /// This should usually be a rollback operation and/or a call to the worker's ``completion`` function with a failure
    /// with an ``Error``
    /// - parameters:
    ///    - error: an unexpected error that broke the worker.
    ///    - postWork: functionn that allows the worker to add other workers to the queue.
    func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void)
}

/// A protocol used to avoid duplication of default ``doWork``, ``doWhenStopped``,  ``onUnexpectedError`` and
/// ``onUnexpectedAsyncError`` implementation for workers without callbacks
public protocol DefaultWorker<PropertiesType, WorkerSpecificationType>: Worker {}

/// A protocol used to avoid duplication of default ``doWork``, ``doWhenStopped``,  ``onUnexpectedError`` and
/// ``onUnexpectedAsyncError`` implementation for workers with a callback
public protocol CallbackWorker<PropertiesType, WorkerSpecificationType>: Worker {
    var callbackFunction: ResultHandler<Void> { get set }
}

public extension DefaultWorker {
    /// Provides a default implementation of this method, which does nothing.
    func doWork(properties: PropertiesType, doAsyncWork: (@escaping (WorkerAsyncWorkCompletionHandler) -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) throws -> PropertiesType {
        properties
    }

    /// Provides a default implementation of this method, which does nothing.
    func doWhenStopped(error: Error) {}
    /// Provides a default implementation of this method, which does nothing.
    func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {}
    /// Provides a default implementation of this method, which does nothing.
    func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {}
}

public extension CallbackWorker {
    /// Provides a default implementation of this method, which does nothing.
    func doWork(properties: PropertiesType, doAsyncWork: (@escaping (WorkerAsyncWorkCompletionHandler) -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) throws -> PropertiesType {
        properties
    }

    /// Provides a default implementation of this method, which calls the callback with the given error.
    func doWhenStopped(error: Error) {
        callbackFunction(Result.failure(ErrorInformation(error: error)))
    }

    /// Provides a default implementation of this method, which calls the callback with the given error.
    func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        callbackFunction(Result.failure(ErrorInformation(error: error)))
    }

    /// Provides a default implementation of this method, which calls the callback with the given error.
    func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        callbackFunction(Result.failure(ErrorInformation(error: error)))
    }
}
