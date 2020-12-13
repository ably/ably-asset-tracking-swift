import UIKit

/**
 Default and preferred way to create AssetTrackingPublisher.
 */
public class PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var transportationMode: TransportationMode?
    private weak var delegate: AssetTrackingPublisherDelegate?

    /**
     Default constructor for `PublisherBuilder`
     */
    public init() { }

    /**
     Creates a `AssetTrackingPublisher` which is ready to publish the asset location to subscribers.
     Notice that it needs asset to to track - it can be set using `AssetTrackingPublisher.track()` function.

     - throws: `AssetTrackingError.incompleteConfiguration`  in case of missing mandatory property
     - Returns: `AssetTrackingPublisher`  ready to `track` the asset.
     */
    public func start() throws -> AssetTrackingPublisher {
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

        guard let transportationMode = transportationMode
        else {
            throw AblyError.incompleteConfiguration(
                "Missing mandatory property: TransportationMode. Did you forgot to call `transportationMode` on builder object?"
            )
        }

        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          logConfiguration: logConfiguration,
                                          transportationMode: transportationMode)
        publisher.delegate = delegate
        return publisher
    }

    /**
     Sets the mandatory `ConnectionConfiguration` property
     */
    public func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        self.connection = configuration
        return self
    }

    /**
     Sets the mandatory `LogConfiguration` property
     */
    public func log(_ configuration: LogConfiguration) -> PublisherBuilder {
        self.logConfiguration = configuration
        return self
    }

    /**
     Sets the mandatory `TransportationMode` property
     */
    public func transportationMode(_ transportationMode: TransportationMode) -> PublisherBuilder {
        self.transportationMode = transportationMode
        return self
    }

    /**
     Sets the optional `AssetTrackingPublisherDelegate` property.
     It's optional to pass it via builder, as it can be set directly on AssetTrackingPublisher.  Maintains weak reference.
     */
    public func publisherDelegate(_ delegate: AssetTrackingPublisherDelegate) -> PublisherBuilder {
        self.delegate = delegate
        return self
    }
}
