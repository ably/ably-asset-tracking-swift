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
            switch (workerSpecification) {
            case .legacy(callback: let callback, logger: let logger):
                return LegacyWorker(work: callback, logger: logger)
            }
    }
}
