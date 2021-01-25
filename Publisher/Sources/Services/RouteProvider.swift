import CoreLocation
import MapboxDirections

protocol RouteProvider {
    func getRoute(to destination: CLLocationCoordinate2D, onSuccess: @escaping (Route) -> Void, onError: @escaping ErrorHandler)
}

class DefaultRouteProvider: NSObject, RouteProvider {
    private let locationManager: CLLocationManager
    private var onSuccess: ((Route) -> Void)?
    private var onError: ErrorHandler?
    private var destination: CLLocationCoordinate2D?

    override init() {
        locationManager = CLLocationManager()
        super.init()
    }

    func getRoute(to destination: CLLocationCoordinate2D, onSuccess: @escaping (Route) -> Void, onError: @escaping ErrorHandler) {
        guard self.onError == nil,
              self.onSuccess == nil
        else {
            onError(AssetTrackingError.publisherError("Provider is already calculating route."))
            return
        }

        self.onSuccess = onSuccess
        self.onError = onError
        self.destination = destination
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
    }

    private func handleLocationUpdate(location: CLLocation) {
        guard let destination = destination else { return }

        let options = RouteOptions(coordinates: [destination, location.coordinate])
        Directions.shared.calculate(options) { [weak self] (_, result) in
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
        guard let onError = onError else { return }
        onError(error)

        self.destination = nil
        self.onSuccess = nil
        self.onError = nil
    }

    private func handleRouteCallback(route: Route) {
        guard let onSuccess = onSuccess else { return }
        onSuccess(route)

        self.destination = nil
        self.onSuccess = nil
        self.onError = nil
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
