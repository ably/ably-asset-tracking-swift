import Foundation
import AblyAssetTrackingInternal

public class PublisherWorkerFactory: WorkerFactory
{
    public typealias PropertiesType = PublisherWorkerQueueProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    public init() {
        
    }
    
    public func createWorker(workerSpecification: PublisherWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<PropertiesType, WorkerSpecificationType> {

            switch (workerSpecification) {
            case .legacy(callback: let callback, logger: let logger):
                return LegacyWorker(work: callback, logger: logger)
            }
    }
}
