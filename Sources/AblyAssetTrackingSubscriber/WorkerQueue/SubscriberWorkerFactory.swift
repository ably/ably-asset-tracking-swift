import Foundation
import AblyAssetTrackingInternal

public class SubscriberWorkerFactory: WorkerFactory
{
    public typealias PropertiesType = SubscriberWorkerQueueProperties
    public typealias WorkerSpecificationType = SubscriberWorkSpecification

    public init() {

    }

    public func createWorker(workerSpecification: SubscriberWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<PropertiesType, WorkerSpecificationType> {
        if (workerSpecification is SubscriberWorkSpecification.Legacy) {
            return LegacyWorker(work: (workerSpecification as! SubscriberWorkSpecification.Legacy).callback)
        }

        return LegacyWorker(work: {})
    }
}
