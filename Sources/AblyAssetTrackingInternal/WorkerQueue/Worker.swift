import Foundation
import AblyAssetTrackingCore

public protocol Worker<PropertiesType, WorkerSpecificationType> {
    associatedtype PropertiesType
    associatedtype WorkerSpecificationType
    
    var completion: ResultHandler<Void> { get }
    
    func doWork(
        properties: PropertiesType,
        doAsyncWork: (() -> Void) -> Void,
        postWork: @escaping (WorkerSpecificationType) -> Void
    ) -> PropertiesType
    
    func doWhenStopped(error: ErrorInformation)
    func onUnexpectedError(error: ErrorInformation, postWork: @escaping (WorkerSpecificationType) -> Void)
    func onUnexpectedAsyncError(error: ErrorInformation, postWork: @escaping (WorkerSpecificationType) -> Void)
}
