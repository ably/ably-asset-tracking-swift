import Foundation
import AblyAssetTrackingInternal

class PublisherWorkerFactory: WorkerFactory {
    public init() {}

    public func createWorker(workerSpecification: PublisherWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<PublisherWorkerQueueProperties, PublisherWorkSpecification> {
            switch workerSpecification {
            case .legacy(callback: let callback):
                return LegacyWorker(work: callback, logger: logHandler)
            }
    }
}
