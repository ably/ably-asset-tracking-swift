import AblyAssetTrackingInternal

/// Given a presence message received on the trackable’s channel, updates the provided properties and emits state events to the subscriber’s delegate by passing the presence message to the properties’ ``SubscriberWorkerQueueProperties.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired`` method.
class UpdatePublisherPresenceWorker: DefaultWorker {
    private let presenceMessage: PresenceMessage
    private let logHandler: InternalLogHandler?

    init(presenceMessage: PresenceMessage, logHandler: InternalLogHandler?) {
        self.presenceMessage = presenceMessage
        self.logHandler = logHandler?.addingSubsystem(Self.self)
    }

    func doWork(properties: SubscriberWorkerQueueProperties, doAsyncWork: (@escaping ((Error?) -> Void) -> Void) -> Void, postWork: @escaping (SubscriberWorkSpecification) -> Void) throws -> SubscriberWorkerQueueProperties {
        var newProperties = properties

        newProperties.specific.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(
            presenceMessages: [presenceMessage],
            logHandler: logHandler
        )

        return newProperties
    }
}
