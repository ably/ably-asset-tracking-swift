import Foundation
import AblyAssetTrackingInternal

class SubscriberWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool

    public init () {
        isStopped = false
    }
}
