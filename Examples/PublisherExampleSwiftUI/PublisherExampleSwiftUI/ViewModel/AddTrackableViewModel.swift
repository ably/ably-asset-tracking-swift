import Foundation
import SwiftUI
import AblyAssetTrackingPublisher
import AblyAssetTrackingCore

class AddTrackableViewModel: ObservableObject {
    @Published var trackableId = ""
    @Published var resolutionMinimumDisplacement: String  = "\(SettingsModel.shared.defaultResolution.minimumDisplacement)"
    @Published var resolutionDesiredInterval: String  = "\(SettingsModel.shared.defaultResolution.desiredInterval)"
    @Published var setResolutionConstraints = false
    @Published var destination: LocationCoordinate?
    
    var resolutionAccuracy: String = SettingsModel.shared.defaultResolution.accuracy.rawValue
    var accuracies: [String] {
        [Accuracy.low,
         Accuracy.high,
         Accuracy.balanced,
         Accuracy.maximum,
         Accuracy.minimum].sorted().map(\.rawValue)
    }
    
    var isValid: Bool {
        !(trackableId.isEmpty || (setResolutionConstraints && customResolution == nil))
    }
    
    private var customResolution: Resolution? {
        guard let accuracy = Accuracy(rawValue: resolutionAccuracy),
              let minimumDisplacement = Double(resolutionMinimumDisplacement),
              let desiredInterval = Double(resolutionDesiredInterval) else {
            return nil
        }
        
        return .init(accuracy: accuracy, desiredInterval: desiredInterval, minimumDisplacement: minimumDisplacement)
    }
    
    func getLatitudeString() -> String {
        guard let latitude = destination?.latitude else {
            return ""
        }
        return String(latitude)
    }
    
    func getLongitudeString() -> String {
        guard let longitude = destination?.longitude else {
            return ""
        }
        return String(longitude)
    }
    
    func createTrackable() -> Trackable {
        let constraints: ResolutionConstraints?
        if setResolutionConstraints, let customResolution {
            // Taken from
            // https://github.com/ably/ably-asset-tracking-android/blob/3506aadeaec81f220bf044639dbb000db2d8f96f/publishing-example-app/src/main/java/com/ably/tracking/example/publisher/AddTrackableActivity.kt#L160-L163
            constraints = DefaultResolutionConstraints(resolutions: DefaultResolutionSet(resolution: customResolution),
                                                       proximityThreshold: DefaultProximity(spatial: 1),
                                                       batteryLevelThreshold: 10,
                                                       lowBatteryMultiplier: 2)
        } else {
            constraints = nil
        }
        
        return Trackable(id: trackableId, destination: destination, constraints: constraints)
    }
}
