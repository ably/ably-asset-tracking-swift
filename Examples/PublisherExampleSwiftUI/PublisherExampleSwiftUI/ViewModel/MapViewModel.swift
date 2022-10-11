import Foundation
import AblyAssetTrackingPublisher
import CoreLocation.CLLocation

class MapViewModel: ObservableObject {
    private var publisher: Publisher?
    private var trackableId: String?
    private var connectionState: ConnectionState = .offline {
        didSet {
            isConnected = connectionState == .online
            updateConnectionStatusInfo(
                connectionState.asInfo()
            )
        }
    }
    var routingProfile: RoutingProfile? = nil {
        didSet {
            updateRoutingProfile(routingProfile)
        }
    }
    private var updatedLocations: Set<CLLocation> = []
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }
    
    @Published var isConnected: Bool
    @Published var didChangeRoutingProfile = false
    @Published var connectionStatusInfo: [StackedTextModel] = []
    
    init() {
        isConnected = connectionState == .online
        updateConnectionStatusInfo(
            connectionState.asInfo()
        )
    }
    
    func connectPublisher(trackableId: String) {
        self.trackableId = trackableId
        
        let connectionConfiguration = ConnectionConfiguration(apiKey: EnvironmentHelper.ABLY_API_KEY, clientId: "Asset Tracking Publisher Example")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)

        let constantResolution: Resolution? = SettingsModel.shared.isConstantResolutionEnabled ? SettingsModel.shared.constantResolution : nil
        let vehicleProfile = SettingsModel.shared.vehicleProfile
        let routingProfile = SettingsModel.shared.routingProfile
        
        publisher = try! PublisherFactory.publishers()
                .connection(connectionConfiguration)
                .mapboxConfiguration(MapboxConfiguration(mapboxKey: EnvironmentHelper.MAPBOX_ACCESS_TOKEN))
//                Uncomment below line to enable simulated location
//                .locationSource(.init(locationSource: SimulatedLocations.recordedLocations()))
                .routingProfile(routingProfile)
                .delegate(self)
                .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
                .rawLocations(enabled: SettingsModel.shared.areRawLocationsEnabled)
                .constantLocationEngineResolution(resolution: constantResolution)
                .logHandler(handler: PublisherLogger())
                .vehicleProfile(vehicleProfile)
                .start()
        
        let destination: LocationCoordinate? = nil
        
        /**
         Uncomment below line if you want to set destination coordinates for your trackable.
         Change `longitude` and `latitude` for your area
         */
        
//        destination = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        let trackable = Trackable(id: trackableId, destination: destination)
        publisher?.track(trackable: trackable) { _ in }
    }
    
    func disconnectPublisher(_ completion: ((Result<Void, ErrorInformation>) -> Void)? = nil) {
        publisher?.stop {[weak self] result in
            self?.publisher = nil
            completion?(result)
        }
    }
    
    private func updateConnectionStatusInfo(_ connectionState: String) {
        connectionStatusInfo.removeAll()
        
        connectionStatusInfo.append(StackedTextModel(label: "Connection status:", value: " \(connectionState)"))
    }
    
    private func updateRoutingProfile(_ profile: RoutingProfile?) {
        guard let profile = profile else {
            return
        }
        
        didChangeRoutingProfile = false
        
        publisher?.changeRoutingProfile(profile: profile) { [weak self] result in
            guard let self = self else {
                return
            }
            self.didChangeRoutingProfile = true
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }
}

extension MapViewModel: PublisherDelegate {
    func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>) {}
    
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {}
    
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {
        updatedLocations.insert(location.location.toCoreLocation())
    }
    
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        connectionState = state
        if isConnected {
            updateConnectionStatusInfo(
                connectionState.asInfo()
            )
            
            didChangeRoutingProfile = true
        }
    }
    
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {}
}
