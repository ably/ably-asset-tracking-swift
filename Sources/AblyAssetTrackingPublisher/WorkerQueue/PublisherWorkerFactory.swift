import Foundation
import AblyAssetTrackingInternal

internal class PublisherWorkerFactory: WorkerFactory
{
    public typealias PropertiesType = PublisherWorkerQueueProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    public init() {}
    
    public func createWorker(workerSpecification: PublisherWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<PropertiesType, WorkerSpecificationType> {

            switch (workerSpecification) {
            case .legacy(callback: let callback):
                return LegacyWorker(work: callback, logger: logHandler)
            }
    }
}
