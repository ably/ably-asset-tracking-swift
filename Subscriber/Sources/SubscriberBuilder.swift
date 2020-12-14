import UIKit

/**
 Default and preferred way to create the `AssetTrackingSubscriber`
 */
public class SubscriberBuilder: NSObject {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var trackingId: String?
    private var resolution: Double?
    private weak var delegate: AssetTrackingSubscriberDelegate?

    public override init() {
        super.init()
    }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 trackingId: String?,
                 resolution: Double?,
                 delegate: AssetTrackingSubscriberDelegate?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
    }

    /**
     Creates a `AssetTrackingSubscriber` which is already listening and passing location updates of asset with given `trackingId`.
     - throws: `AssetTrackingError.incompleteConfiguration`  in case of missing mandatory property
     - Returns: `AssetTrackingSubscriber` with passed all configuration properties.
     */
    public func start() throws -> AssetTrackingSubscriber {
        guard let connection = connection
        else {
            throw AblyError.incompleteConfiguration(
                "Missing mandatory property: ConnectionConfiguration. Did you forgot to call `connection` on builder object?"
            )
        }

        guard let logConfiguration = logConfiguration
        else {
            throw AblyError.incompleteConfiguration(
                "Missing mandatory property: LogConfiguration. Did you forgot to call `log` on builder object?"
            )
        }

        guard let trackingId = trackingId
        else {
            throw AblyError.incompleteConfiguration(
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

    // MARK: Mandatory properties
    /**
     Sets the mandatory `ConnectionConfiguration` property
     */
    public func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return SubscriberBuilder(connection: configuration,
                                 logConfiguration: logConfiguration,
                                 trackingId: trackingId,
                                 resolution: resolution,
                                 delegate: delegate)
    }

    /**
     Sets the mandatory `LogConfiguration` property
     */
    public func log(_ configuration: LogConfiguration) -> SubscriberBuilder {
        return SubscriberBuilder(connection: connection,
                                 logConfiguration: configuration,
                                 trackingId: trackingId,
                                 resolution: resolution,
                                 delegate: delegate)
    }

    /**
     Sets the mandatory `trackingId` property
     */
    public func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return SubscriberBuilder(connection: connection,
                                 logConfiguration: logConfiguration,
                                 trackingId: trackingId,
                                 resolution: resolution,
                                 delegate: delegate)
    }

    // MARK: Optional properties
    /**
     Sets the optional `resolution` property
     */
    public func resolution(_ resolution: Double) -> SubscriberBuilder {
        return SubscriberBuilder(connection: connection,
                                 logConfiguration: logConfiguration,
                                 trackingId: trackingId,
                                 resolution: resolution,
                                 delegate: delegate)
    }

    /**
     Sets the optional `AssetTrackingSubscriberDelegate` property.
     It's optional to pass it via builder, as it can be set directly on `AssetTrackingSubscriber`.  Maintains weak reference.
     */
    public func subscriberDelegate(_ delegate: AssetTrackingSubscriberDelegate) -> SubscriberBuilder {
        return SubscriberBuilder(connection: connection,
                                 logConfiguration: logConfiguration,
                                 trackingId: trackingId,
                                 resolution: resolution,
                                 delegate: delegate)
    }
}
