import Foundation
import AblyAssetTrackingInternal

/**
 A worker than runs "legacy" code, but on the worker queue
 */
public class LegacyWorker : Worker
{
    public typealias PropertiesType = PublisherProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    let work: () -> Void
    
    public init (work: @escaping () -> Void) {
        self.work = work
    }
    
    public func doWork(properties: PropertiesType, doAsyncWork: (@escaping () throws -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) throws -> PropertiesType {
        work()
        
        return properties
    }
    
    public func doWhenStopped(error: Error) {
        //TODO
    }
    
    public func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        //TODO
    }
    
    public func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        //TODO
    }
}
