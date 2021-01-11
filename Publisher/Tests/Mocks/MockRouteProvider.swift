import MapboxDirections
import CoreLocation
@testable import Publisher

class MockRouteProvider: RouteProvider{
    var getRouteCalled: Bool = false
    var getRouteParamDestination: CLLocationCoordinate2D?
    var getRouteParamOnSuccess: ((Route) -> Void)?
    var getRouteParamOnError: ErrorHandler?

    func getRoute(to destination: CLLocationCoordinate2D, onSuccess: @escaping (Route) -> Void, onError: @escaping ErrorHandler) {
        getRouteCalled = true
        getRouteParamDestination = destination
        getRouteParamOnSuccess = onSuccess
        getRouteParamOnError = onError
    }
}
