import CoreLocation
import MapboxCoreNavigation
import MapboxDirections

class RouteLocationService: LocationService {
    private let provider: RouteProvider
    private var controller: RouteController?
    private var route: Route?
    weak var delegate: LocationServiceDelegate?

    init() {
        self.provider = DefaultRouteProvider()
    }

    func setup(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        guard let destination = trackable.destination else {
            onError(AssetTrackingError.publisherError("Missing destination in received trackable"))
            return
        }
        
        provider.getRoute(to: destination,
                          onSuccess: { [weak self] route, options in
                            self?.setupRoute(route: route, options: options, onSuccess: onSuccess, onError: onError)
                          },
                          onError: onError)
    }

    func startUpdatingLocation() {
        guard let manager = controller?.dataSource as? NavigationLocationManager
        else { return }
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        guard let manager = controller?.dataSource as? NavigationLocationManager
        else { return }
        manager.stopUpdatingLocation()
    }

    func changeLocationEngineResolution(resolution: Resolution) { }

    private func setupRoute(route: Route, options: RouteOptions, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        let routeController = RouteController(along: route,
                                              routeIndex: 0,
                                              options: options,
                                              dataSource: NavigationLocationManager())
        routeController.delegate = self
        self.controller = routeController
        self.route = route
    }
}

extension RouteLocationService: RouterDelegate {
    func router(_ router: Router, didRefresh routeProgress: RouteProgress) { }

    func router(_ router: Router, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        delegate?.locationService(sender: self, didUpdateRawLocation: rawLocation)
        delegate?.locationService(sender: self, didUpdateEnhancedLocation: location)
    }

    func router(_ router: Router, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        self.route = route
    }
}
