//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

class SettingsViewModel: ObservableObject {
    private let routingProfileDrivingString = "driving"
    private let routingProfileCyclingString = "cycling"
    private let routingProfileDrivingTrafficString = "drivingTraffic"
    private let routingProfileWalkingString = "walking"
    
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
    @Published var defaultResolutionMinimumDisplacement: String  = "\(SettingsModel.shared.defaultResolution.minimumDisplacement)"
    @Published var defaultResolutionDesiredInterval: String  = "\(SettingsModel.shared.defaultResolution.desiredInterval)"
    
    var constantResolutionAccuracy: String = SettingsModel.shared.constantResolution.accuracy.rawValue
    var defaultResolutionAccuracy: String = SettingsModel.shared.defaultResolution.accuracy.rawValue
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
         RoutingProfile.walking].map { getRoutingProfileDescription(routingProfile: $0) }
    }
    
    func getRoutingProfileDescription(routingProfile: RoutingProfile) -> String {
        switch routingProfile {
        case .driving:
            return routingProfileDrivingString
        case .cycling:
            return routingProfileCyclingString
        case .walking:
            return routingProfileWalkingString
        case .drivingTraffic:
            return routingProfileDrivingTrafficString
        }
    }
    
    func getRoutingProfileFromDescription(description: String) -> RoutingProfile {
        if description == routingProfileDrivingString {
            return .driving
        }
        if description == routingProfileCyclingString {
            return .cycling
        }
        if description == routingProfileWalkingString {
            return .walking
        }
        if description ==  routingProfileDrivingTrafficString {
            return .drivingTraffic
        }
        
        return .driving
    }
        
    func save() {
        if let constantAccuracy = Accuracy(rawValue: constantResolutionAccuracy),
           let constantDisplacement = Double(constantResolutionMinimumDisplacement) {
            SettingsModel.shared.constantResolution = .init(accuracy: constantAccuracy,
                                                            desiredInterval: .zero,
                                                            minimumDisplacement: constantDisplacement)
        }
        
        if let defaultAccuracy = Accuracy(rawValue: defaultResolutionAccuracy),
        let defaultDisplacement = Double(defaultResolutionMinimumDisplacement),
        let defaultDesiredInterval = Double(defaultResolutionDesiredInterval) {
            SettingsModel.shared.defaultResolution = .init(accuracy: defaultAccuracy,
                                                           desiredInterval: defaultDesiredInterval,
                                                           minimumDisplacement: defaultDisplacement)
        }
    }
}
