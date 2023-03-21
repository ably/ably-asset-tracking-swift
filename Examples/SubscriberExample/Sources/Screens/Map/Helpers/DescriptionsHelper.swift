import AblyAssetTrackingSubscriber
import UIKit

extension Accuracy {
    var description: String {
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

enum DescriptionsHelper {
    // MARK: - ResolutionState
    enum ResolutionState {
        case none
        case notEmpty(_: Resolution)
        case changeError(_: ErrorInformation)
    }

    enum ResolutionStateHelper {
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
        case connectionState(_: ConnectionState?)
        case subscriberPresence(isPresent: Bool?)
    }

    // MARK: - AssetConnectionState
    enum AssetStateHelper {
        static func getDescriptionAndColor(for state: AssetState) -> (desc: String, color: UIColor) {
            switch state {
            case .connectionState(let connectionState):
                if let connectionState {
                    switch connectionState {
                    case .online:
                        return ("online", .systemGreen)
                    case .offline:
                        return ("offline", .systemRed)
                    case .failed:
                        return ("failed", .systemRed)
                    }
                } else {
                    return ("The asset connection status is not determined", .black)
                }
            case .subscriberPresence(let isPresent):
                if let isPresent {
                    if isPresent {
                        return ("present", .systemGreen)
                    } else {
                        return ("not present", .systemRed)
                    }
                } else {
                    return ("The publisher’s presence is not determined", .black)
                }
            }
        }
    }
}
