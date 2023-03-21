import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    @Published var statusTitle: String = "-"
    @Published var isLocationAuthorizationDenied: Bool = false
    @Published var currentLocation: CLLocation = .init(latitude: 0, longitude: 0)
    @Published var currentRegionCenter = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0
    )
    private let locationManager = CLLocationManager()
    private var didUpdateRegion = false

    override private init() {
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

        updateRegion()
    }

    func updateRegion(_ force: Bool = false) {
        if force {
            didUpdateRegion = false
        }

        if !didUpdateRegion {
            currentRegionCenter = currentLocation.coordinate
            didUpdateRegion = true
        }
    }
}
