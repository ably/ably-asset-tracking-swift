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
        self.connection = configuration
        return self
    }

    /**
     Sets the mandatory `LogConfiguration` property
     */
    public func log(_ configuration: LogConfiguration) -> SubscriberBuilder {
        self.logConfiguration = configuration
        return self
    }

    /**
     Sets the mandatory `trackingId` property
     */
    public func trackingId(_ trackingId: String) -> SubscriberBuilder {
        self.trackingId = trackingId
        return self
    }

    // MARK: Optional properties
    /**
     Sets the optional `resolution` property
     */
    public func resolution(_ resolution: Double) -> SubscriberBuilder {
        self.resolution = resolution
        return self
    }

    /**
     Sets the optional `AssetTrackingSubscriberDelegate` property.
     It's optional to pass it via builder, as it can be set directly on `AssetTrackingSubscriber`.  Maintains weak reference.
     */
    public func subscriberDelegate(_ delegate: AssetTrackingSubscriberDelegate) -> SubscriberBuilder {
        self.delegate = delegate
        return self
    }
}
