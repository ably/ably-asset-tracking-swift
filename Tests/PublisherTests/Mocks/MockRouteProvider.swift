import MapboxDirections
import CoreLocation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class MockRouteProvider: RouteProvider{
    var getRouteCalled: Bool = false
    var getRouteParamDestination: CLLocationCoordinate2D?
    var getRouteParamRoutingProfile: RoutingProfile?
    var getRouteParamResultHandler: ResultHandler<Route>?
    var getRouteBody: ((ResultHandler<Route>) -> Void)?
    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamRoutingProfile = routingProfile
        getRouteParamResultHandler = completion
        getRouteBody?(completion)
    }
}
