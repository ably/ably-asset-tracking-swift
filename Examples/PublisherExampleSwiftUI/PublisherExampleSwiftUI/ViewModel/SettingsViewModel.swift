//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

protocol SettingsViewModelProtocol: ObservableObject {
    var areRawLocationsEnabled: Bool { get set }
    var isConstantResolutionEnabled: Bool { get set }
    var minimumDisplacement: String { get set }
    var accuracy: String { get set }
    var accuracies: [String] { get }
    
    func save()
}

extension SettingsViewModelProtocol {
    var accuracies: [String] {
        [Accuracy.low.rawValue,
         Accuracy.high.rawValue,
         Accuracy.balanced.rawValue,
         Accuracy.maximum.rawValue,
         Accuracy.minimum.rawValue].sorted()
    }
}

class SettingsViewModel: SettingsViewModelProtocol {
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
    
    func save() {
        if let accuracy = Accuracy(rawValue: self.accuracy), let displacement = Double(minimumDisplacement) {
            SettingsModel.shared.constantResolution = .init(accuracy: accuracy, desiredInterval: .zero, minimumDisplacement: displacement)
        }
    }
}
