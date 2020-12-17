import UIKit
import Core

class DefaultSubscriberBuilder: SubscriberBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var trackingId: String?
    private var resolution: Double?
    private weak var delegate: SubscriberDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 trackingId: String?,
                 resolution: Double?,
                 delegate: SubscriberDelegate?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
    }

    func start() throws -> Subscriber {
        guard let connection = connection
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: ConnectionConfiguration. Did you forgot to call `connection` on builder object?"
            )
        }

        guard let logConfiguration = logConfiguration
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: LogConfiguration. Did you forgot to call `log` on builder object?"
            )
        }

        guard let trackingId = trackingId
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: TrackingId. Did you forgot to call `trackingId` on builder object?"
            )
        }

        let subscriber = DefaultSubscriber(connectionConfiguration: connection,
                                           logConfiguration: logConfiguration,
                                           trackingId: trackingId,
                                           resolution: resolution)
        subscriber.delegate = delegate
        subscriber.start()
        return subscriber
    }

    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: configuration,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func log(_ configuration: LogConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func resolution(_ resolution: Double) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }
}
