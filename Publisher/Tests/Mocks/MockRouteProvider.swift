import MapboxDirections
import CoreLocation
@testable import Publisher

class MockRouteProvider: RouteProvider{
    var getRouteCalled: Bool = false
    var getRouteParamDestination: CLLocationCoordinate2D?
    var getRouteParamRoutingProfile: RoutingProfile?
    var getRouteParamResultHandler: ResultHandler<Route>?
    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamRoutingProfile = routingProfile
        getRouteParamResultHandler = completion
    }
    
    var changeRoutingProfileCalled: Bool = false
    var changeRoutingProfileParamRoutingProfile: RoutingProfile?
    var changeRoutingProfileParamResultHandler: ResultHandler<Route>?
    func changeRoutingProfile(to routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        changeRoutingProfileCalled = true
        changeRoutingProfileParamRoutingProfile = routingProfile
        changeRoutingProfileParamResultHandler = completion
    }
}
