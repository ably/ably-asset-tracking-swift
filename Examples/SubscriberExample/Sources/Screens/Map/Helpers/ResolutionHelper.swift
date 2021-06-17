import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber

enum ResolutionType {
    case minimum
    case low
    case balanced
    case high
    case maximum
}

class ResolutionHelper {
    static func createResolution(forZoom zoom: Double) -> Resolution {
        let resolutionType = getResolutionType(for: zoom)
        switch resolutionType {
        case .minimum:
            return Resolution(accuracy: .minimum, desiredInterval: 120 * 1000, minimumDisplacement: 10000)
        case .low:
            return Resolution(accuracy: .low, desiredInterval: 60 * 1000, minimumDisplacement: 5000)
        case .balanced:
            return Resolution(accuracy: .balanced, desiredInterval: 30 * 1000, minimumDisplacement: 100)
        case .high:
            return Resolution(accuracy: .high, desiredInterval: 10 * 1000, minimumDisplacement: 30)
        case .maximum:
            return Resolution(accuracy: .maximum, desiredInterval: 5 * 1000, minimumDisplacement: 1)
        }
    }
    
    private static func getResolutionType(for zoom: Double) -> ResolutionType {
        switch zoom {
        case 0..<10:
            return .minimum
        case 10.0...12.0:
            return .low
        case 12.0...14.0:
            return .balanced
        case 14.0...16.0:
            return .high
        default:
            return .maximum
        }
    }
}
