import Foundation
import AblyAssetTrackingCore

/// The WorkerQueue is responsible for enqueueing ``Worker``s and executing them.
class WorkerQueue<PropertiesType, WorkerSpecificationType> where PropertiesType: WorkerQueueProperties {
    private var properties: PropertiesType
    private let workingQueue: DispatchQueue
    private let logHandler: InternalLogHandler?
    private let workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>
    private let getStoppedError: () -> Error

    init(properties: PropertiesType, queue: DispatchQueue, logHandler: InternalLogHandler?, workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>, getStoppedError: @escaping () -> Error) {
        self.properties = properties
        self.workingQueue = queue
        self.logHandler = logHandler
        self.workerFactory = workerFactory
        self.getStoppedError = getStoppedError
    }
    
    
    /// Enqueue worker created from passed specification for execution.
    /// - parameters:
    ///    - workerSpecification: ``WorkerSpecificationType`` specification of worker to be executed.
    func enqueue(workerSpecification: WorkerSpecificationType) {
        let worker = workerFactory.createWorker(workerSpecification: workerSpecification)
        
        workingQueue.async { [weak self] in
            guard let self = self
            else { return }
            
            do {
                if self.properties.isStopped {
                    worker.doWhenStopped(error: self.getStoppedError())
                }
                else {
                    try self.properties = worker.doWork(properties: self.properties) { asyncWork in
                        do {
                            try asyncWork()
                        }
                        catch {
                            self.logHandler?.error(message: "Unexpected error thrown from the asynchronous work of \(worker.workerTypeDescription)", error: error)
                            
                            worker.onUnexpectedAsyncError(error: error) { asyncErrorWorker in
                                self.enqueue(workerSpecification: asyncErrorWorker)
                            }
                        }
                    } postWork: { postWorker in
                        self.enqueue(workerSpecification: postWorker)
                    }
                }
            }
            catch {
                self.logHandler?.error(message: "Unexpected error thrown from the asynchronous work of \(worker.workerTypeDescription)", error: error)
                worker.onUnexpectedError(error: error) { postWorker in
                    self.enqueue(workerSpecification: postWorker)
                }
            }
        }
    }
}
