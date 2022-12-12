import MapboxDirections
import CoreLocation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockRouteProvider: RouteProvider{
    public init() {}

    public var getRouteCalled: Bool = false
    public var getRouteParamDestination: CLLocationCoordinate2D?
    public var getRouteParamRoutingProfile: RoutingProfile?
    public var getRouteParamResultHandler: ResultHandler<Route>?
    public var getRouteBody: ((ResultHandler<Route>) -> Void)?
    public func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamRoutingProfile = routingProfile
        getRouteParamResultHandler = completion
        getRouteBody?(completion)
    }
}
