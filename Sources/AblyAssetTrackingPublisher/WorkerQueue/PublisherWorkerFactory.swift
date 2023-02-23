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
        if (workerSpecification is PublisherWorkSpecification.Legacy) {
            let legacyWorkerSpecification = workerSpecification as! PublisherWorkSpecification.Legacy
            return LegacyWorker(work: legacyWorkerSpecification.callback, logger: legacyWorkerSpecification.logger)
        }
        
        return LegacyWorker(work: {}, logger: nil)
    }
}
