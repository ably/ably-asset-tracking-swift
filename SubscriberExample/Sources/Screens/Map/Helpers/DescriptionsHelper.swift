import UIKit
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber

extension Accuracy {
    var description: String {
        switch self {
        case .minimum: return "Minimum"
        case .low: return "Low"
        case .balanced: return "Balanced"
        case .high: return "High"
        case .maximum: return "Maximum"
        }
    }
}

class DescriptionsHelper {
    // MARK: - ResolutionState
    enum ResolutionState {
        case none
        case notEmpty(_: Resolution)
        case changeError(_: ErrorInformation)
    }
    
    class ResolutionStateHelper {
        static func getDescription(for state: ResolutionState) -> String {
            switch state {
            case .none:
                return "Resolution: None"
            case .notEmpty(let resolution):
                return """
                    Resolution:
                    Accuracy: \(resolution.accuracy.description)
                    Minimum displacement: \(resolution.minimumDisplacement)
                    Desired interval: \(resolution.desiredInterval)
                    """
            case .changeError(let errorInformation):
                return "Cannot change resolution. Error message: \(errorInformation.description)"
            }
        }
    }
    
    enum AssetState {
        case connectionState(_: ConnectionState)
        case none
    }
    
    // MARK: - AssetConnectionState
    class AssetStateHelper {
        static func getDescriptionAndColor(for state: AssetState) -> (desc: String, color: UIColor) {
            switch state {
            case .connectionState(let connectionState):
                switch connectionState {
                case .online:
                    return ("online", .systemGreen)
                case .offline:
                    return ("offline", .systemRed)
                case .failed:
                    return ("failed", .systemRed)
                }
            case .none:
                return ("The asset connection status is not determined", .black)
            }
        }
    }
}
