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
    
    @Published var minimumDisplacement: String  = "\(SettingsModel.shared.constantResolution.minimumDisplacement)"
    
    var accuracy: String = SettingsModel.shared.constantResolution.accuracy.rawValue
    var accuracies: [String] {
        [Accuracy.low,
         Accuracy.high,
         Accuracy.balanced,
         Accuracy.maximum,
         Accuracy.minimum].sorted().map(\.rawValue)
    }
    
    func save() {
        if let accuracy = Accuracy(rawValue: self.accuracy), let displacement = Double(minimumDisplacement) {
            SettingsModel.shared.constantResolution = .init(accuracy: accuracy, desiredInterval: .zero, minimumDisplacement: displacement)
        }
    }
}
