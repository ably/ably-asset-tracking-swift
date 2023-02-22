import Foundation
import AblyAssetTrackingInternal

public class SubscriberWorkerQueueProperties: WorkerQueueProperties
{
    public var isStopped: Bool

    public init () {
        isStopped = false
    }
}
