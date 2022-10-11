import Foundation
import AblyAssetTrackingPublisher
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
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }
    
    @Published var isConnected: Bool
    @Published var errorInfo: String? = nil
    @Published var isDestinationAvailable: Bool = false
    @Published var didChangeRoutingProfile = false
    @Published var connectionStatusAndProfileInfo: [StackedTextModel] = []
    @Published var resolutionInfo: [StackedTextModel] = []
    
    init() {
        isConnected = connectionState == .online
        updateConnectionStatusAndProfileInfo(
            connectionState.asInfo(),
            routingProfile: routingProfile?.asInfo()
        )
        updateResolutionInfo()
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
    
    private func updateResolutionInfo(_ resolution: Resolution? = nil) {
        resolutionInfo.removeAll()
        resolutionInfo.append(.init(label: "Resolution policy", value: "", isHeader: true))
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
    
    struct PublisherInfoViewModel {
        var rawLocationsInfo: [StackedTextModel]
        var constantResolutionInfo: [StackedTextModel]
    }
    
    static func createPublisherInfoViewModel(fromPublisherConfigInfo publisherConfigInfo: ObservablePublisher.PublisherConfigInfo) -> PublisherInfoViewModel {
        let rawLocationsInfo: [StackedTextModel] = [.init(label: "Publish raw locations: ", value: "\(publisherConfigInfo.areRawLocationsEnabled ? "enabled" : "disabled")")]
        
        var constantResolutionInfo: [StackedTextModel] = []
        if let constantResolution = publisherConfigInfo.constantResolution {
            constantResolutionInfo.append(.init(label: "Constant engine resolution", value: "", isHeader: true))
            constantResolutionInfo.append(.init(label: "Desired accuracy: ", value: "\(constantResolution.accuracy)"))
            constantResolutionInfo.append(.init(label: "Min displacement: ", value: "\(constantResolution.minimumDisplacement)m"))
        } else {
            constantResolutionInfo.append(.init(label: "Constant resolution: ", value:  "disabled"))
        }
        
        return .init(rawLocationsInfo: rawLocationsInfo, constantResolutionInfo: constantResolutionInfo)
    }
}

extension MapViewModel: PublisherDelegate {
    func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>) {}
    
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
