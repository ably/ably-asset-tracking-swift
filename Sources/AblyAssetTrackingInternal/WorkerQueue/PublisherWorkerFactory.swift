import Foundation

public class PublisherWorkerFactory: WorkerFactory
{
    public typealias PropertiesType = PublisherProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    public init() {
        
    }
    
    public func createWorker(workerSpecification: PublisherWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<PropertiesType, WorkerSpecificationType> {
        if (workerSpecification is PublisherWorkSpecification.Legacy) {
            return LegacyWorker(work: (workerSpecification as! PublisherWorkSpecification.Legacy).callback)
        }
        
        return LegacyWorker(work: {})
    }
}
