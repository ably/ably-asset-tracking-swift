import Foundation
import AblyAssetTrackingInternal

public class PublisherWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool
    
    public init () {
        isStopped = false
    }
}
