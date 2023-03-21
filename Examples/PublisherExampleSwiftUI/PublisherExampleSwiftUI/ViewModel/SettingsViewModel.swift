import Foundation
import SwiftUI
import AblyAssetTrackingPublisher

class SettingsViewModel: ObservableObject {
    @Published var useMapboxMap: Bool = SettingsModel.shared.useMapboxMap {
        didSet {
            SettingsModel.shared.useMapboxMap = useMapboxMap
        }
    }

    @Published var logLocationHistoryJSON: Bool = SettingsModel.shared.logLocationHistoryJSON {
        didSet {
            SettingsModel.shared.logLocationHistoryJSON = logLocationHistoryJSON
        }
    }

    @Published var defaultResolutionMinimumDisplacement: String  = "\(SettingsModel.shared.defaultResolution.minimumDisplacement)"
    @Published var defaultResolutionDesiredInterval: String  = "\(SettingsModel.shared.defaultResolution.desiredInterval)"

    var defaultResolutionAccuracy: String = SettingsModel.shared.defaultResolution.accuracy.rawValue
    var accuracies: [String] {
        [
            Accuracy.low,
            Accuracy.high,
            Accuracy.balanced,
            Accuracy.maximum,
            Accuracy.minimum
        ].sorted().map(\.rawValue)
    }

    func save() {
        if let defaultAccuracy = Accuracy(rawValue: defaultResolutionAccuracy),
        let defaultDisplacement = Double(defaultResolutionMinimumDisplacement),
        let defaultDesiredInterval = Double(defaultResolutionDesiredInterval) {
            SettingsModel.shared.defaultResolution = .init(
                accuracy: defaultAccuracy,
                desiredInterval: defaultDesiredInterval,
                minimumDisplacement: defaultDisplacement
            )
        }
    }
}
