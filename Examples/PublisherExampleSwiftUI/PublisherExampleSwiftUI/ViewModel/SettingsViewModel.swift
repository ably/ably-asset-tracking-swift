//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

class SettingsViewModel: ObservableObject {
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
