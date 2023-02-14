import Foundation
import AblyAssetTrackingCore

/// The WorkerQueue is responsible for enqueueing ``Worker``s and executing them.
/// - parameters:
///     - PropertiesType - the type of properties used by workers as both input and output. To reduce a risk of shared mutable state, this param must have value
///     semantics
///     - WorkerSpecificationType - the type of specification used to post worker back to the queue
class WorkerQueue<PropertiesType, WorkerSpecificationType> where PropertiesType: WorkerQueueProperties {
    private var properties: PropertiesType
    private let workingQueue: DispatchQueue
    private let logHandler: InternalLogHandler?
    private let workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>
    private let getStoppedError: () -> Error
    private let asyncWorkQueue: DispatchQueue

    init(properties: PropertiesType, queue: DispatchQueue, logHandler: InternalLogHandler?, workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>, asyncWorkWorkingQueue: DispatchQueue,
 getStoppedError: @escaping () -> Error) {
        self.properties = properties
        self.workingQueue = queue
        self.logHandler = logHandler?.addingSubsystem(Self.self)
        self.workerFactory = workerFactory
        self.getStoppedError = getStoppedError
        self.asyncWorkQueue = asyncWorkWorkingQueue
    }
    
    
    /// Enqueue worker created from passed specification for execution.
    /// - parameters:
    ///    - workRequest: an identifiable wrapper for the  ``WorkRequest.workerSpecification`` that contains the specification
    ///    of worker to be executed.
    func enqueue(workRequest: WorkRequest<WorkerSpecificationType>) {
        let workerLogHandler = logHandler?.addingSubsystem(.named("request-\(workRequest.id)"))
        let worker = workerFactory.createWorker(workerSpecification: workRequest.workerSpecification, logHandler: workerLogHandler)

        workerLogHandler?.debug(message: "Worker Queue enqueued worker: \(type(of: worker))", error: nil)
        workingQueue.async { [weak self] in
            guard let self = self
            else { return }
            
            do {
                if self.properties.isStopped {
                    workerLogHandler?.debug(message: "Worker \(type(of: worker)) invoked doWhenStopped", error: nil)
                    worker.doWhenStopped(error: self.getStoppedError())
                }
                else {
                    workerLogHandler?.verbose(message: "Worker Queue's properties before invoking doWork on \(type(of: worker)): \(self.properties)", error: nil)
                    workerLogHandler?.debug(message: "Worker Queue invoking doWork on \(type(of: worker))", error: nil)
                    try self.properties = worker.doWork(properties: self.properties) { asyncWork in
                        self.asyncWorkQueue.async {
                            do {
                                workerLogHandler?.debug(message: "Performing async work posted by worker \(type(of: worker))", error: nil)
                                try asyncWork()
                            }
                            catch {
                                workerLogHandler?.error(message: "Unexpected error thrown from the asynchronous work of \(type(of: worker)). Worker Queue invoking onUnexpectedAsyncError", error: error)
                                worker.onUnexpectedAsyncError(error: error) { asyncErrorWorker in
                                    self.enqueue(workRequest: WorkRequest(workerSpecification: asyncErrorWorker))
                                }
                            }
                        }
                        workerLogHandler?.debug(message: "Worker \(type(of: worker)) finished doWork", error: nil)
                        workerLogHandler?.verbose(message: "Worker Queue's properties after executing doWork on \(type(of: worker)): \(self.properties)", error: nil)
                    } postWork: { postWorker in
                        let postWorkRequest = WorkRequest(workerSpecification: postWorker)
                        workerLogHandler?.debug(message: "Worker \(type(of: worker)) posted further work: \(type(of: postWorker)), with ID: \(postWorkRequest.id)", error: nil)
                        self.enqueue(workRequest: WorkRequest(workerSpecification: postWorker))
                    }
                }
            }
            catch {
                workerLogHandler?.error(message: "Unexpected error thrown from the synchronous work of \(type(of: worker)). Worker Queue invoking onUnexpectedError", error: error)
                worker.onUnexpectedError(error: error) { postWorker in
                    self.enqueue(workRequest: WorkRequest(workerSpecification: postWorker))
                }
            }
        }
    }
}
