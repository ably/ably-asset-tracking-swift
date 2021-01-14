import MapboxDirections
import CoreLocation
@testable import Publisher

class MockRouteProvider: RouteProvider{
    var getRouteCalled: Bool = false
    var getRouteParamDestination: CLLocationCoordinate2D?
    var getRouteParamRoutingProfile: RoutingProfile?
    var getRouteParamOnSuccess: ((Route) -> Void)?
    var getRouteParamOnError: ErrorHandler?

    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, onSuccess: @escaping (Route) -> Void, onError: @escaping ErrorHandler) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamRoutingProfile = routingProfile
        getRouteParamOnSuccess = onSuccess
        getRouteParamOnError = onError
    }
    
    var changeRoutingProfileCalled: Bool = false
    var changeRoutingProfileParamRoutingProfile: RoutingProfile?
    var changeRoutingProfileOnSuccess: ((Route) -> Void)?
    var changeRoutingProfileOnError: ErrorHandler?
    
    func changeRoutingProfile(to routingProfile: RoutingProfile, onSuccess: @escaping (Route) -> Void, onError: @escaping ErrorHandler) {
        changeRoutingProfileCalled = true
        changeRoutingProfileParamRoutingProfile = routingProfile
        changeRoutingProfileOnSuccess = onSuccess
        changeRoutingProfileOnError = onError
    }
}
