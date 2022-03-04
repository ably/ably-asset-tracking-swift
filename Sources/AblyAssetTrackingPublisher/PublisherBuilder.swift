import Foundation
import AblyAssetTrackingCore

/**
 Default and preferred way to create the `Publisher`.
 */
public protocol PublisherBuilder {
    /**
     Creates a `Publisher` which is ready to publish the asset location to subscribers.
     Notice that it needs asset to to track - it can be set using `Publisher.track()` function.

     - throws: `AssetTrackingError.incompleteConfiguration`  in case of missing mandatory property
     - Returns: `Publisher`  ready to `track` the asset.
     */
    func start() throws -> Publisher

    /**
     Sets the mandatory `ConnectionConfiguration` property
     */
    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder
    
    /**
     Sets the mandatory `MapboxConfiguration` property
    */
    func mapboxConfiguration(_ mapboxConfiguration: MapboxConfiguration) -> PublisherBuilder

    /**
     Sets the mandatory `LogConfiguration` property
     */
    func log(_ configuration: LogConfiguration) -> PublisherBuilder
    
    /**
     Sets the optional `LocationSource` property
     */
    func locationSource(_ source: LocationSource?) -> PublisherBuilder

    /**
     Sets the mandatory `RoutingProfile` property
     */
    func routingProfile(_ profile: RoutingProfile) -> PublisherBuilder

    /**
     Sets the mandatory `ResolutionPolicyFactory` property
     */
    func resolutionPolicyFactory(_ factory: ResolutionPolicyFactory) -> PublisherBuilder

    /**
     Sets the optional `Delegate` property.
     It's optional to pass it via builder, as it can be set directly on `Publisher`.  Maintains weak reference.
     */
    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder
    
    /**
     Sets publishing `raw locations` enabled or not
     It's disabled by default
     */
    func rawLocations(enabled: Bool) -> PublisherBuilder
}
