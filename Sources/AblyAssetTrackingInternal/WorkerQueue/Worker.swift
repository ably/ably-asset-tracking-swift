import Foundation
import AblyAssetTrackingCore

public protocol Worker<PropertiesType, WorkerSpecificationType>: AnyObject {
    associatedtype PropertiesType
    associatedtype WorkerSpecificationType
    
    var completion: ResultHandler<Void> { get }
    var workerTypeDescription: String { get }
    
    func doWork(
        properties: PropertiesType,
        doAsyncWork: (() throws -> Void) -> Void,
        postWork: @escaping (WorkerSpecificationType) -> Void
    ) throws -> PropertiesType
    
    func doWhenStopped(error: Error)
    func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void)
    func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void)
}
