import UIKit
import Core

/**
 Default and preferred way to create the `Subscriber`
 */
public protocol SubscriberBuilder {
    /**
     Creates a `Subscriber` which is already listening and passing location updates of asset with given `trackingId`.
     - throws: `AssetTrackingError.incompleteConfiguration`  in case of missing mandatory property
     - Returns: `AssetTrackingSubscriber` with passed all configuration properties.
     */
    func start() throws -> Subscriber

    /**
     Sets the mandatory `ConnectionConfiguration` property
     */
    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder

    /**
     Sets the mandatory `LogConfiguration` property
     */
    func log(_ configuration: LogConfiguration) -> SubscriberBuilder

    /**
     Sets the mandatory `trackingId` property
     */
    func trackingId(_ trackingId: String) -> SubscriberBuilder
    // MARK: Optional properties
    /**
     Sets the optional `resolution` property
     */
    func resolution(_ resolution: Double) -> SubscriberBuilder

    /**
     Sets the optional `Delegate` property.
     It's optional to pass it via builder, as it can be set directly on `Subscriber`.  Maintains weak reference.
     */
    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder
}
