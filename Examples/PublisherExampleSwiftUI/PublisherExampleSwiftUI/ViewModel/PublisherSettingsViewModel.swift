//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

class PublisherSettingsViewModel: ObservableObject {
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
}