import CoreLocation
import MapKit

/// A dummy implementation of LocationManagerProtocol for use in Xcode view previews.
class PreviewLocationManager: LocationManagerProtocol {
    var statusTitle = " authorized (always)"
    var isLocationAuthorizationDenied = false
    
    private static let ablyOffice = CLLocation(latitude: 51.523818013322355, longitude: -0.07944549954398208)
    
    var currentLocation = PreviewLocationManager.ablyOffice
    
    var currentRegion = MKCoordinateRegion(center: PreviewLocationManager.ablyOffice.coordinate,
                                           span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    func requestAuthorization() {}
    
    func updateRegion(force: Bool) {}
}
