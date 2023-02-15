import Foundation

public class PublisherWorkerFactory: WorkerFactory
{
    public typealias PropertiesType = PublisherProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    public init() {
        
    }
    
    public func createWorker(workerSpecification: PublisherWorkSpecification, logHandler: InternalLogHandler?) -> Worker<PropertiesType, WorkerSpecificationType> {
        if (workerSpecification is PublisherWorkSpecification.Legacy) {
            return LegacyWorker(workerSpecification.callback)
        }
        
        return LegacyWorker(() -> Void)
    }
}
