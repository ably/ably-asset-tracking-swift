import MapboxCoreNavigation

class MapBoxService {
    private let locationManager: NavigationLocationManager
    
    public init() {
        self.locationManager = NavigationLocationManager()        
    }
}
