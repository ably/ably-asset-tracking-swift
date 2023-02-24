import Foundation
import AblyAssetTrackingInternal

internal class PublisherWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool
    
    public init () {
        isStopped = false
    }
}
