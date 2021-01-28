import MapboxDirections
import CoreLocation
@testable import Publisher

class MockRouteProvider: RouteProvider{
    var getRouteCalled: Bool = false
    var getRouteParamDestination: CLLocationCoordinate2D?
    var getRouteParamRoutingProfile: RoutingProfile?
    var getRouteResultHandler: ResultHandler<Route>?

    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamRoutingProfile = routingProfile
        getRouteResultHandler = completion
    }
    
    var changeRoutingProfileCalled: Bool = false
    var changeRoutingProfileParamRoutingProfile: RoutingProfile?
    var changeRoutingProfileResultHandler: ResultHandler<Route>?
    
    func changeRoutingProfile(to routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        changeRoutingProfileCalled = true
        changeRoutingProfileParamRoutingProfile = routingProfile
        changeRoutingProfileResultHandler = completion
    }
}
