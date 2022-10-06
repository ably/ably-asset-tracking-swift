import SwiftUI
import CoreLocation
import MapKit

protocol LocationManagerProtocol: ObservableObject {
    var statusTitle: String { get set }
    var isLocationAuthorizationDenied: Bool { get set }
    var currentLocation: CLLocation { get set }
    var currentRegion: MKCoordinateRegion { get set }
    
    func requestAuthorization()
    func updateRegion(force: Bool)
}

class LocationManager: NSObject, LocationManagerProtocol {
    static let shared = LocationManager()
    
    @Published var statusTitle: String = "-"
    @Published var isLocationAuthorizationDenied: Bool = false
    @Published var currentLocation: CLLocation = .init(latitude: 0, longitude: 0)
    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.2,
            longitudeDelta: 0.2
        )
    )
    private let locationManager = CLLocationManager()
    private var didUpdateRegion = false
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        statusTitle = authStatusAsString()
        isLocationAuthorizationDenied = locationManager.authorizationStatus == .denied
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func authStatusAsString() -> String {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            return " not determined"
        case .restricted:
            return " restricted"
        case .denied:
            return " denied"
        case .authorizedAlways:
            return " authorized (always)"
        case .authorizedWhenInUse:
            return " authorized (in use)"
        case .authorized:
            return " authorized"
        @unknown default:
            return " unknown"
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        statusTitle = authStatusAsString()
        isLocationAuthorizationDenied = locationManager.authorizationStatus == .denied
        if !isLocationAuthorizationDenied {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        
        currentLocation = firstLocation
        
        updateRegion(force: false)
    }
    
    func updateRegion(force: Bool) {
        if force {
            didUpdateRegion = false
        }
        
        if !didUpdateRegion {
            currentRegion.center = currentLocation.coordinate
            didUpdateRegion = true
        }
    }
}
