import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import AblyAssetTrackingCore

class DefaultLocationService: LocationService {
    private let locationManager: PassiveLocationManager
    private let replayLocationManager: ReplayLocationManager?
    private let logHandler: LogHandler?
    private var lastReceivedLocations: (location: CLLocation, rawLocation: CLLocation)?

    weak var delegate: LocationServiceDelegate?

    init(mapboxConfiguration: MapboxConfiguration,
         historyLocation: [CLLocation]?,
         logHandler: LogHandler?) {
        
        let directions = Directions(credentials: mapboxConfiguration.getCredentials())
        NavigationSettings.shared.initialize(directions: directions,
                                             tileStoreConfiguration: .default,
                                             statusUpdatingSettings: .init(updatingPatience: .greatestFiniteMagnitude, updatingInterval: nil))
        
        if let historyLocation = historyLocation {
            replayLocationManager = ReplayLocationManager(locations: historyLocation)
        } else {
            replayLocationManager = nil
        }
        self.logHandler = logHandler

        self.locationManager = PassiveLocationManager(systemLocationManager: replayLocationManager)
        self.locationManager.delegate = self
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        replayLocationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.systemLocationManager.stopUpdatingLocation()
    }

    func changeLocationEngineResolution(resolution: Resolution) {
        /**
         It's not possible to change time interval for location updates in `CLLocationManager` from Apple `CoreLocation` framework.
         Documentation: https://developer.apple.com/documentation/corelocation/cllocationmanager
         */
        locationManager.systemLocationManager.desiredAccuracy = resolution.accuracy.toCoreLocationAccuracy()
        locationManager.systemLocationManager.distanceFilter = resolution.minimumDisplacement
    }
}

extension DefaultLocationService: PassiveLocationManagerDelegate {
    func passiveLocationManagerDidChangeAuthorization(_ manager: PassiveLocationManager) {
        logHandler?.debug(message: "\(String(describing: Self.self)), passiveLocationManager.passiveLocationManagerDidChangeAuthorization", error: nil)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
        logHandler?.verbose(message: "\(String(describing: Self.self)), passiveLocationManager(\(manager), didUpdateLocation: \(String(reflecting: location)), rawLocation: \(String(reflecting: rawLocation)))", error: nil)
        
        if let lastReceivedLocations = lastReceivedLocations {
            logHandler?.verbose(message: "\(String(describing: Self.self)), Differences between location and last received location: \(location.differences(with: lastReceivedLocations.location))", error: nil)
            logHandler?.verbose(message: "\(String(describing: Self.self)), Differences between rawLocation and last received rawLocation: \(rawLocation.differences(with: lastReceivedLocations.rawLocation))", error: nil)
        }
        
        lastReceivedLocations = (location: location, rawLocation: rawLocation)
        delegate?.locationService(sender: self, didUpdateRawLocationUpdate: RawLocationUpdate(location: rawLocation.toLocation()))
        delegate?.locationService(sender: self, didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location.toLocation()))
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateHeading newHeading: CLHeading) {
        logHandler?.debug(message: "\(String(describing: Self.self)), passiveLocationManager.didUpdateHeading", error: nil)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didFailWithError error: Error) {
        logHandler?.error(message: "\(String(describing: Self.self)), passiveLocationManager.didFailWithError", error: error)
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: error.localizedDescription))
        delegate?.locationService(sender: self, didFailWithError: errorInformation)
    }
}

private extension CLLocation {
    enum Property: CustomStringConvertible {
        case coordinate(Double, Double)
        case altitude(Double)
        case ellipsoidalAltitude(Double)
        case horizontalAccuracy(Double)
        case verticalAccuracy(Double)
        case course(Double)
        case courseAccuracy(Double)
        case speed(Double)
        case speedAccuracy(Double)
        case timestamp(TimeInterval)
        
        var description: String {
            switch self {
            case let .coordinate(latitudeDifference, longitudeDifference): return "coordinate(\(latitudeDifference), \(longitudeDifference))"
            case let .altitude(difference): return "altitude(\(difference))"
            case let .ellipsoidalAltitude(difference): return "ellipsoidalAltitude(\(difference))"
            case let .horizontalAccuracy(difference): return "horizontalAccuracy(\(difference))"
            case let .verticalAccuracy(difference): return "verticalAccuracy(\(difference))"
            case let .course(difference): return "course(\(difference))"
            case let .courseAccuracy(difference): return "courseAccuracy(\(difference))"
            case let .speed(difference): return "speed(\(difference))"
            case let .speedAccuracy(difference): return "speedAccuracy(\(difference))"
            case let .timestamp(difference): return "timestamp(\(difference))"
            }
        }
    }
    
    func differences(with other: CLLocation) -> [Property] {
        var result: [Property] = []
        
        if coordinate != other.coordinate { result.append(.coordinate(abs(coordinate.latitude - other.coordinate.latitude), abs(coordinate.longitude - other.coordinate.longitude))) }
        if altitude != other.altitude { result.append(.altitude(abs(altitude - other.altitude))) }
        if #available(iOS 15, *) {
            if ellipsoidalAltitude != other.ellipsoidalAltitude { result.append(.ellipsoidalAltitude(abs(ellipsoidalAltitude - other.ellipsoidalAltitude))) }
        }
        if horizontalAccuracy != other.horizontalAccuracy { result.append(.horizontalAccuracy(abs(horizontalAccuracy - other.horizontalAccuracy))) }
        if verticalAccuracy != other.verticalAccuracy { result.append(.verticalAccuracy(abs(verticalAccuracy - other.verticalAccuracy))) }
        if course != other.course { result.append(.course(abs(course - other.course))) }
        if #available(iOS 13.4, *) {
            if courseAccuracy != other.courseAccuracy { result.append(.courseAccuracy(abs(courseAccuracy - other.courseAccuracy))) }
        }
        if speed != other.speed { result.append(.speed(abs(speed - other.speed))) }
        if speedAccuracy != other.speedAccuracy {  result.append(.speedAccuracy(abs(speedAccuracy - other.speedAccuracy))) }
        if timestamp != other.timestamp { result.append(.timestamp(abs(timestamp.distance(to: other.timestamp)))) }
        
        // TODO floor
        // TODO sourceInformation
        
        return result
    }
}
