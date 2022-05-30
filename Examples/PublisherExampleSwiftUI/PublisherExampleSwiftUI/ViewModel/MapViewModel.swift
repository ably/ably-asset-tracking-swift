import Foundation
import AblyAssetTrackingPublisher
import AblyAssetTrackingCore
import CoreLocation.CLLocation

class MapViewModel: ObservableObject {
    private var publisher: Publisher?
    private var trackableId: String?
    private var connectionState: ConnectionState = .offline {
        didSet {
            isConnected = connectionState == .online
            updateConnectionStatusAndProfileInfo(
                connectionState.asInfo(),
                routingProfile: routingProfile?.asInfo()
            )
        }
    }
    var routingProfile: RoutingProfile? = nil {
        didSet {
            updateRoutingProfile(routingProfile)
        }
    }
    private var updatedLocations: Set<CLLocation> = []
    
    @Published var areRawLocationsEnabled = false {
        didSet {
            rawLocationsEnabledChanged()
        }
    }
    @Published var isConnected: Bool
    @Published var errorInfo: String? = nil
    @Published var isDestinationAvailable: Bool = false
    @Published var didChangeRoutingProfile = false
    @Published var rawLocationsInfo: [StackedTextModel] = []
    @Published var connectionStatusAndProfileInfo: [StackedTextModel] = []
    @Published var resolutionInfo: [StackedTextModel] = []
    
    init() {
        isConnected = connectionState == .online
        updateConnectionStatusAndProfileInfo(
            connectionState.asInfo(),
            routingProfile: routingProfile?.asInfo()
        )
        updateResolutionInfo()
        rawLocationsInfo = [.init(label: "Publish raw locations: ", value: "\(areRawLocationsEnabled ? "enabled" : "disabled")")]
    }
    
    func connectPublisher(trackableId: String) {
        self.trackableId = trackableId
        
        let connectionConfiguration = ConnectionConfiguration(apiKey: EnvironmentHelper.ABLY_API_KEY, clientId: "Asset Tracking Publisher Example")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        
        publisher = try! PublisherFactory.publishers()
                .connection(connectionConfiguration)
                .mapboxConfiguration(MapboxConfiguration(mapboxKey: EnvironmentHelper.MAPBOX_ACCESS_TOKEN))
                .log(LogConfiguration())
                .routingProfile(.driving)
                .delegate(self)
                .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
                .rawLocations(enabled: areRawLocationsEnabled)
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
    
    private func rawLocationsEnabledChanged() {
        rawLocationsInfo = [.init(label: "Publish raw locations: ", value: "\(areRawLocationsEnabled ? "enabled" : "disabled")")]
        
        disconnectPublisher { [weak self] _ in
            guard let trackableId = self?.trackableId else {
                return
            }

            self?.connectPublisher(trackableId: trackableId)
        }
    }
    
    private func updateResolutionInfo(_ resolution: Resolution? = nil) {
        resolutionInfo.removeAll()
        
        if let resolution = resolution {
            resolutionInfo.append(StackedTextModel(label: "Accurancy:", value: " \(resolution.accuracy.asInfo())"))
            resolutionInfo.append(StackedTextModel(label: "Min. displacement:", value: " \(resolution.minimumDisplacement)m"))
            resolutionInfo.append(StackedTextModel(label: "Desired interval:", value: " \(resolution.desiredInterval)ms"))
        } else {
            resolutionInfo.append(StackedTextModel(label: "Accurancy:", value: " -"))
            resolutionInfo.append(StackedTextModel(label: "Min. displacement:", value: " -"))
            resolutionInfo.append(StackedTextModel(label: "Desired interval:", value: " -"))
        }
    }
    
    private func updateConnectionStatusAndProfileInfo(_ connectionState: String, routingProfile: String?) {
        connectionStatusAndProfileInfo.removeAll()
        
        connectionStatusAndProfileInfo.append(StackedTextModel(label: "Connection status:", value: " \(connectionState)"))
        
        if isDestinationAvailable {
            connectionStatusAndProfileInfo.append(StackedTextModel(label: "Routing profile:", value: " \(routingProfile ?? "-")"))
        }
    }
    
    private func updateErrorInfo(_ error: ErrorInformation) {
        errorInfo = """
        Code: \(error.code)
        Status code: \(error.statusCode)
        
        \(error.message)
        """
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
                self.updateConnectionStatusAndProfileInfo(
                    self.connectionState.asInfo(),
                    routingProfile: self.publisher?.routingProfile.asInfo()
                )
            case .failure(let error):
                self.updateErrorInfo(error)
            }
        }
    }
}

extension MapViewModel: PublisherDelegate {
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        updateErrorInfo(error)
    }
    
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {
        updatedLocations.insert(location.location.toCoreLocation())
    }
    
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        isDestinationAvailable = trackable.destination != nil
        connectionState = state
        if isConnected {
            updateConnectionStatusAndProfileInfo(
                connectionState.asInfo(),
                routingProfile: sender.routingProfile.asInfo()
            )
            
            didChangeRoutingProfile = true
        }
    }
    
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        updateResolutionInfo(resolution)
    }
}

private extension ConnectionState {
    func asInfo() -> String {
        switch self {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .failed:
            return "Failed"
        }
    }
}

private extension Accuracy {
    func asInfo() -> String {
        switch self {
        case .minimum:
            return "Minimum"
        case .low:
            return "Low"
        case .balanced:
            return "Balanced"
        case .high:
            return "High"
        case .maximum:
            return "Maximum"
        }
    }
}
