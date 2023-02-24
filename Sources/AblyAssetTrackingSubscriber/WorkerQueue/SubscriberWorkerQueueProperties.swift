import Foundation
import AblyAssetTrackingInternal

internal class SubscriberWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool

    public init () {
        isStopped = false
    }
}
