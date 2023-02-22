import Foundation
import AblyAssetTrackingInternal

/// A worker that runs tasks that the Publisher used to run asynchronously on its
/// own dispatch queue. This worker allows us to tie up legacy work and new asynchronous
/// work, for simplicity and consistency during the transition.
public class LegacyWorker : Worker
{
    public typealias PropertiesType = PublisherProperties
    public typealias WorkerSpecificationType = PublisherWorkSpecification
    
    let work: () -> Void
    
    public init (work: @escaping () -> Void) {
        self.work = work
    }
    
    public func doWork(properties: PropertiesType, doAsyncWork: (@escaping () throws -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) throws -> PropertiesType {
        doAsyncWork({ [work] in
            work()
        })
        
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
