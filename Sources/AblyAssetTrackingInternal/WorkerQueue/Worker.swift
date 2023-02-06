import Foundation
import AblyAssetTrackingCore

/// A [Worker] interface represents workers which execute work inside [WorkerQueue].
/// PropertiesType: - the type of properties used by this worker as both input and output.
/// WorkerSpecificationType - the type of specification used to post another worker back to the queue.
public protocol Worker<PropertiesType, WorkerSpecificationType>: AnyObject {
    associatedtype PropertiesType
    associatedtype WorkerSpecificationType
    
    var completion: ResultHandler<Void> { get }
    var workerTypeDescription: String { get }
    
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
        doAsyncWork: (() throws -> Void) -> Void,
        postWork: @escaping (WorkerSpecificationType) -> Void
    ) throws -> PropertiesType
    
    /// This function is provided in order for implementers to define what should happen when the worker
    /// cannot ``doWork(properties:doAsyncWork:postWork:)`` because the queue was stopped
    /// and no workers should be executed.
    /// This should usually be a call to the worker's completion function with a failure with the ``Error``.
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
    
    /**
     * This function is provided in order for implementors to define what should happen when the worker
     * breaks due to an unexpected exception while the async work from [doWork] is being executed.
     * This should usually be a rollback operation and/or a call to the worker's callback function
     * with a failure with the [exception].
     *
     * @param exception The unexpected exception that broke the worker.
     * @param postWork this function allows worker to add other workers to the queue calling it.
     */
    
    
    /// This function is used to define what should happen when the worker breaks due to an unexpected error while the
    /// async work from ``dowWork`` is being executed.
    /// This should usually be a rollback operation and/or a call to the worker's ``completion`` function with a failure
    /// with an ``Error``
    /// - parameters:
    ///    - error: an unexpected error that broke the worker.
    ///    - postWork: functionn that allows the worker to add other workers to the queue.
    func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void)
}
