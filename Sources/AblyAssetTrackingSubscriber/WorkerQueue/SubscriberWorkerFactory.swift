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
            let legacyWorkerSpecification = workerSpecification as! SubscriberWorkSpecification.Legacy
            return LegacyWorker(work: legacyWorkerSpecification.callback, logger: legacyWorkerSpecification.logger)
        }

        return LegacyWorker(work: {}, logger: nil)
    }
}
