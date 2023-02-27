import Foundation
import AblyAssetTrackingInternal

class PublisherWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool
    
    public init () {
        isStopped = false
    }
}
