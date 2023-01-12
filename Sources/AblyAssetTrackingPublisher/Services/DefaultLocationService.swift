import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

class DefaultLocationService: LocationService {
    private let locationManager: PassiveLocationManager
    private let replayLocationManager: ReplayLocationManager?
    private let logHandler: InternalLogHandler?
    private let workQueue = DispatchQueue(label: "com.ably.AssetTracking.DefaultLocationService.workQueue")
    private let locationManagerHandler: LocationManagerHandler

    weak var delegate: LocationServiceDelegate?
    
    init(mapboxConfiguration: MapboxConfiguration,
         historyLocation: [CLLocation]?,
         logHandler: InternalLogHandler?,
         vehicleProfile: VehicleProfile) {
        self.logHandler = logHandler?.addingSubsystem(Self.self)
        self.locationManagerHandler = LocationManagerHandler(logHandler: logHandler)
        
        let directions = Directions(credentials: mapboxConfiguration.getCredentials())

        NavigationSettings.shared.initialize(directions: directions,
                                             tileStoreConfiguration: .default,
                                             navigatorPredictionInterval: 0,
                                             statusUpdatingSettings: .init(updatingPatience: .greatestFiniteMagnitude ,
                                                                                                                        updatingInterval: nil))
        if vehicleProfile == .bicycle {
            let cyclingConfig = [
                        "cache": [
                            "enableAssetsTrackingMode": true
                        ],
                        "navigation": [
                            "routeLineFallbackPolicy": [
                                "policy": 1
                            ]
                        ]
                    ]
            UserDefaults.standard.set(cyclingConfig, forKey: MapboxCoreNavigation.customConfigKey)
        }
        
        // Mapbox told us that we should configure the history storage location _before_ creating the PassiveLocationManager instance:
        // https://github.com/mapbox-collab/Ably-DH-Collab/issues/6#issuecomment-1310126245
        // This was in response to us asking why HistoryReader was returning an empty list of events.
        do {
            try LocationHistoryTemporaryStorageConfiguration.configureMapboxHistoryStorageLocation()
        } catch {
            self.logHandler?.error(message: "Failed to configure Mapbox history storage location", error: error)
        }

        if let historyLocation = historyLocation {
            replayLocationManager = ReplayLocationManager(locations: historyLocation)
        } else {
            replayLocationManager = nil
        }
        //set location manager with profile identifier only if .Bicycle is provided by clients
        if vehicleProfile == .bicycle {
            self.locationManager = PassiveLocationManager(systemLocationManager: replayLocationManager ,datasetProfileIdentifier: .cycling)
        } else {
            self.locationManager = PassiveLocationManager(systemLocationManager: replayLocationManager)
        }

        self.locationManager.delegate = locationManagerHandler
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        replayLocationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.systemLocationManager.stopUpdatingLocation()
    }
    
    enum LocationHistoryTemporaryStorageConfiguration {
        private static let fileManager = FileManager.default
        
        static func configureMapboxHistoryStorageLocation() throws {
            guard PassiveLocationManager.historyDirectoryURL == nil else {
                // Mapbox’s storage already configured
                return
            }
                        
            let storageDirectoryURL = try storageDirectoryURL
            try ensureStorageDirectoryExists(atURL: storageDirectoryURL)
            PassiveLocationManager.historyDirectoryURL = storageDirectoryURL
        }
        
        private static func ensureStorageDirectoryExists(atURL storageDirectoryURL: URL) throws {
            if !fileManager.fileExists(atPath: storageDirectoryURL.path, isDirectory: nil) {
                try fileManager.createDirectory(at: storageDirectoryURL, withIntermediateDirectories: true)
            }
        }
        
        private static var storageDirectoryURL: URL {
            get throws {
                let cachesURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                return cachesURL.appendingPathComponent("com.ably.AblyAssetTracking.publisher")
            }
        }
    }
    
    func startRecordingLocation() {
        PassiveLocationManager.startRecordingHistory()
    }
    
    func stopRecordingLocation(completion: @escaping ResultHandler<LocationRecordingResult?>) {
        PassiveLocationManager.stopRecordingHistory { [weak self] historyFileURL in
            self?.workQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard let historyFileURL = historyFileURL else {
                    let error = ErrorInformation(type: .commonError(errorMessage: "PassiveLocationManager.stopRecordingHistory did not return a file URL"))
                    self.logHandler?.info(message: "PassiveLocationManager.stopRecordingHistory returned a nil historyFileURL – not treating as an error since it might be that we never started recording history", error: error)
                    completion(.success(nil))
                    return
                }
                
                guard let reader = HistoryReader(fileUrl: historyFileURL) else {
                    let error = ErrorInformation(type: .commonError(errorMessage: "HistoryReader(fileUrl:) returned nil"))
                    self.logHandler?.error(message: "Failed to complete recording of history", error: error)
                    completion(.failure(.init(type: .commonError(errorMessage: "Failed to create HistoryReader"))))
                    return
                }
                
                var locationHistoryData: LocationHistoryData? = nil
                do {
                    let events = try reader.compactMap { event -> GeoJSONMessage? in
                        guard let locationUpdateHistoryEvent = event as? LocationUpdateHistoryEvent else {
                            return nil
                        }
                        
                        let location = try locationUpdateHistoryEvent.location.toLocation().get()
                        return try GeoJSONMessage(location: location)
                    }
                    locationHistoryData = LocationHistoryData(events: events)
                }
                catch let error as LocationValidationError {
                    self.logHandler?.verbose(message: "Swallowing invalid enhanced location from Mapbox, validation error was: \(error)", error: error)
                }
                catch {
                    self.logHandler?.error(message: "Failed to map location history reader events to GeoJSONMessage", error: error)
                    completion(.failure(.init(error: error)))
                    return
                }
                
                let rawHistoryTemporaryFile = TemporaryFile(fileURL: historyFileURL, logHandler: self.logHandler)
                guard let locationHistoryData = locationHistoryData else {
                    return
                }

                completion(.success(.init(locationHistoryData: locationHistoryData, rawHistoryFile: rawHistoryTemporaryFile)))
            }
        }
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

protocol LocationManagerHandlerDelegate: AnyObject {
    @available(iOS 14.0, *)
    func locationManagerHandlerDidChangeAuthorization()
    
    func locationManagerHandler(handler:LocationManagerHandler, didUpdateEnhancedLocation location: Location)
    
    func locationManagerHandler(handler:LocationManagerHandler, didUpdateRawLocation location: Location)
    
    func locationManagerHandler(handler:LocationManagerHandler, didUpdateHeading newHeading: CLHeading)
    
    func locationManagerHandler(handler:LocationManagerHandler, didFailWithError error: Error)
}

/**
 An independently testable utility class used by the DefaultLocationService implementation
 that receives, validates, sanitizes and transforms mapbox locations before sending them on to AAT.
*/
internal class LocationManagerHandler: PassiveLocationManagerDelegate {
    let logHandler: InternalLogHandler?
    
    weak var delegate: LocationManagerHandlerDelegate?
    
    init(logHandler: InternalLogHandler?) {
        self.logHandler = logHandler
    }
    
    func passiveLocationManagerDidChangeAuthorization(_ manager: PassiveLocationManager) {
        if #available(iOS 14.0, *) {
            delegate?.locationManagerHandlerDidChangeAuthorization()
        }
    }
    
    func handleEnhancedLocationUpdate(location: CLLocation) {
        let enhancedLocationResult = location.toLocation()
        do {
            let enhancedLocationFromResult = try enhancedLocationResult.get()
            delegate?.locationManagerHandler(handler: self, didUpdateEnhancedLocation: enhancedLocationFromResult)
        } catch {
            logHandler?.verbose(message: "Swallowing invalid enhanced location from Mapbox, validation error was: \(error as? LocationValidationError)", error: error)
        }
    }
    
    func handleRawLocationUpdate(location: CLLocation) {
        let rawLocationResult = location.toLocation()
        
        do {
            let rawLocationFromResult = try rawLocationResult.get()
            delegate?.locationManagerHandler(handler: self, didUpdateRawLocation: rawLocationFromResult)
        } catch {
            logHandler?.verbose(message: "Swallowing invalid raw location from Mapbox, validation error was: \(error as? LocationValidationError)", error: error)
        }
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
       handleEnhancedLocationUpdate(location: location)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.locationManagerHandler(handler: self, didUpdateHeading: newHeading)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didFailWithError error: Error) {
        delegate?.locationManagerHandler(handler: self, didFailWithError: error)
    }
}

extension DefaultLocationService: LocationManagerHandlerDelegate {
    func locationManagerHandlerDidChangeAuthorization() {
        logHandler?.debug(message: "locationManagerHandler.locationManagerHandlerDidChangeAuthorization", error: nil)
    }
    
    func locationManagerHandler(handler: LocationManagerHandler, didUpdateEnhancedLocation location: Location) {
        delegate?.locationService(sender: self, didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location))
    }
    
    func locationManagerHandler(handler: LocationManagerHandler, didUpdateRawLocation location: Location) {
        delegate?.locationService(sender: self, didUpdateRawLocationUpdate: RawLocationUpdate(location: location))
    }
    
    func locationManagerHandler(handler: LocationManagerHandler, didUpdateHeading newHeading: CLHeading) {
        logHandler?.debug(message: "locationManagerHandler.didUpdateHeading", error: nil)
    }
    
    func locationManagerHandler(handler: LocationManagerHandler, didFailWithError error: Error) {
        logHandler?.error(message: "locationManagerHandler.didFailWithError", error: error)
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: error.localizedDescription))
        delegate?.locationService(sender: self, didFailWithError: errorInformation)
    }
}
