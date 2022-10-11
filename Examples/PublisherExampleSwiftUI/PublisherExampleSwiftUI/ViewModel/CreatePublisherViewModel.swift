//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

class CreatePublisherViewModel: ObservableObject {
    @Published var areRawLocationsEnabled: Bool = SettingsModel.shared.areRawLocationsEnabled {
        didSet {
            SettingsModel.shared.areRawLocationsEnabled = areRawLocationsEnabled
        }
    }
    
    @Published var isConstantResolutionEnabled: Bool = SettingsModel.shared.isConstantResolutionEnabled {
        didSet {
            SettingsModel.shared.isConstantResolutionEnabled = isConstantResolutionEnabled
        }
    }
    
    @Published var vehicleProfile: VehicleProfile = SettingsModel.shared.vehicleProfile {
        didSet {
            SettingsModel.shared.vehicleProfile = vehicleProfile
        }
    }
    
    @Published var routingProfile: RoutingProfile = SettingsModel.shared.routingProfile {
        didSet {
            SettingsModel.shared.routingProfile = routingProfile
        }
    }
    
    @Published var constantResolutionMinimumDisplacement: String  = "\(SettingsModel.shared.constantResolution.minimumDisplacement)"
    
    var constantResolutionAccuracy: String = SettingsModel.shared.constantResolution.accuracy.rawValue
    var accuracies: [String] {
        [Accuracy.low,
         Accuracy.high,
         Accuracy.balanced,
         Accuracy.maximum,
         Accuracy.minimum].sorted().map(\.rawValue)
    }
    
    var vehicleProfiles: [String] {
        [VehicleProfile.bicycle,
         VehicleProfile.car].map{ $0.description() }
    }
    
    var routingProfiles: [String] {
        [RoutingProfile.cycling,
         RoutingProfile.driving,
         RoutingProfile.drivingTraffic,
         RoutingProfile.walking].map { $0.description() }
    }
    
    func save() {
        if let constantAccuracy = Accuracy(rawValue: constantResolutionAccuracy),
           let constantDisplacement = Double(constantResolutionMinimumDisplacement) {
            SettingsModel.shared.constantResolution = .init(accuracy: constantAccuracy,
                                                            desiredInterval: .zero,
                                                            minimumDisplacement: constantDisplacement)
        }
    }
    
    func createPublisher() -> ObservablePublisher {
        let connectionConfiguration = ConnectionConfiguration(apiKey: EnvironmentHelper.ABLY_API_KEY, clientId: "Asset Tracking Publisher Example")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)

        let constantResolution: Resolution? = SettingsModel.shared.isConstantResolutionEnabled ? SettingsModel.shared.constantResolution : nil
        let vehicleProfile = SettingsModel.shared.vehicleProfile
        let routingProfile = SettingsModel.shared.routingProfile
        
        let areRawLocationsEnabled = SettingsModel.shared.areRawLocationsEnabled
                
        var publisher = try! PublisherFactory.publishers()
            .connection(connectionConfiguration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: EnvironmentHelper.MAPBOX_ACCESS_TOKEN))
            // Uncomment below line to enable simulated location
//          .locationSource(.init(locationSource: SimulatedLocations.recordedLocations()))
            .routingProfile(routingProfile)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .rawLocations(enabled: areRawLocationsEnabled)
            .constantLocationEngineResolution(resolution: constantResolution)
            .logHandler(handler: PublisherLogger())
            .vehicleProfile(vehicleProfile)
            .start()
        
        
        let configInfo = ObservablePublisher.PublisherConfigInfo(areRawLocationsEnabled: areRawLocationsEnabled, constantResolution: constantResolution)
        
        let observablePublisher = ObservablePublisher(publisher: publisher, configInfo: configInfo)
        publisher.delegate = observablePublisher
        
        return observablePublisher
    }
}
