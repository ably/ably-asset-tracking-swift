import CoreLocation
import MapboxDirections

protocol RouteProvider {
    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>)
    func changeRoutingProfile(to routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>)
}

class DefaultRouteProvider: NSObject, RouteProvider {
    private let locationManager: CLLocationManager
    private var resultHandler: ResultHandler<Route>?
    private var destination: CLLocationCoordinate2D?
    private var routingProfile: RoutingProfile?
    private var directions: Directions?

    init(mapboxConfiguration: MapboxConfiguration) {
        locationManager = CLLocationManager()
        directions = Directions(credentials: mapboxConfiguration.getCredentians())

        super.init()
    }
    
    func changeRoutingProfile(to routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {
        self.routingProfile = routingProfile
        guard let destination = self.destination,
              !isCalculating(resultHandler: completion) else {
            return
        }

        self.getRoute(to: destination,
                 withRoutingProfile: routingProfile,
                 completion: completion)
    }

    func getRoute(to destination: CLLocationCoordinate2D, withRoutingProfile routingProfile: RoutingProfile, completion: @escaping ResultHandler<Route>) {

        if isCalculating(resultHandler: completion) {
            return
        }

        self.resultHandler = completion
        self.destination = destination
        self.routingProfile = routingProfile
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
    }

    private func handleLocationUpdate(location: CLLocation) {
        guard let directions = self.directions else {
            self.handleErrorCallback(error: AssetTrackingError.publisherError("Missing Directions object."))
            return
        }
        
        guard let destination = destination,
              let routingProfile = routingProfile else { return }

        let options = RouteOptions(coordinates: [destination, location.coordinate],
                                   profileIdentifier: routingProfile.toMapboxProfileIdentifier())
        directions.calculate(options) { [weak self] (_, result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.handleErrorCallback(error: error)
            case .success(let response):
                guard let route = response.routes?.first else {
                    self.handleErrorCallback(error: AssetTrackingError.publisherError("Missing route in Directions response."))
                    return
                }
                self.handleRouteCallback(route: route)
            }
        }
    }

    private func handleErrorCallback(error: Error) {
        guard let resultHandler = self.resultHandler else { return }
        resultHandler(.failure(error))

        self.destination = nil
        self.resultHandler = nil
    }

    private func handleRouteCallback(route: Route) {
        guard let resultHandler = self.resultHandler else { return }
        resultHandler(.success(route))
        self.destination = nil
        self.resultHandler = nil
    }
    
    private func isCalculating(resultHandler: ResultHandler<Route>) -> Bool {
        guard self.resultHandler == nil
        else {
            resultHandler(.failure(AssetTrackingError.publisherError("Provider is already calculating route.")))
            return true
        }
        return false
    }
}

extension DefaultRouteProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.delegate = nil
        handleLocationUpdate(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.delegate = nil
        handleErrorCallback(error: error)
    }
}
