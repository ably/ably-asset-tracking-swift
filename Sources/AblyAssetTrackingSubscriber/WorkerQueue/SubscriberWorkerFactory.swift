import AblyAssetTrackingInternal
import Foundation

class SubscriberWorkerFactory: WorkerFactory {
    public init() {}

    public func createWorker(workerSpecification: SubscriberWorkSpecification, logHandler: InternalLogHandler?)
        -> any Worker<SubscriberWorkerQueueProperties, SubscriberWorkSpecification> {
            switch workerSpecification {
            case .legacy(callback: let callback):
                return LegacyWorker(work: callback, logger: logHandler)
            case .updatePublisherPresence(presenceMessage: let presenceMessage):
                return UpdatePublisherPresenceWorker(presenceMessage: presenceMessage, logHandler: logHandler)
            }
    }
}
