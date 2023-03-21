import Foundation

private enum AccuracyKeys: String {
    case minimum = "MINIMUM"
    case low = "LOW"
    case balanced = "BALANCED"
    case high = "HIGH"
    case maximum = "MAXIMUM"
}

/**
 The accuracy of a geographical coordinate.
 Presents a unified representation of location accuracy (Apple) and quality priority (Android).
 */
public enum Accuracy: Int {
    /**
     - Android: [PRIORITY_NO_POWER](https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest#PRIORITY_NO_POWER)
     (best possible with zero additional power consumption)
     - Apple: [kCLLocationAccuracyReduced](https://developer.apple.com/documentation/corelocation/kcllocationaccuracyreduced)
     (preserves the user’s country, typically preserves the city, and is usually within 1–20 kilometers of the actual location)
     */
    case minimum

    /**
     - Android: [PRIORITY_LOW_POWER](https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest#PRIORITY_LOW_POWER)
     (coarse "city" level, circa 10km accuracy)
     - Apple: Either [kCLLocationAccuracyKilometer](https://developer.apple.com/documentation/corelocation/kcllocationaccuracykilometer)
     or [kCLLocationAccuracyThreeKilometers](https://developer.apple.com/documentation/corelocation/kcllocationaccuracythreekilometers)
     */
    case low

    /**
     - Android: [PRIORITY_BALANCED_POWER_ACCURACY](https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest#PRIORITY_BALANCED_POWER_*   (coarse "block" level, circa 100m accuracy)
     - Apple: Either [kCLLocationAccuracyNearestTenMeters](https://developer.apple.com/documentation/corelocation/kcllocationaccuracynearesttenmeters)
     or [kCLLocationAccuracyHundredMeters](https://developer.apple.com/documentation/corelocation/kcllocationaccuracyhundredmeters)
     */
    case balanced

    /**
     - Android: [PRIORITY_HIGH_ACCURACY](https://developers.google.com/android/reference/com/google/android/gms/location/LocationRequest#PRIORITY_HIGH_ACCURACY)
     (most accurate locations that are available)
     - Apple: [kCLLocationAccuracyBest](https://developer.apple.com/documentation/corelocation/kcllocationaccuracybest)
     (very high accuracy but not to the same level required for navigation apps)
     */
    case high

    /**
     - Android: same as `HIGH`
     - Apple: [kCLLocationAccuracyBestForNavigation](https://developer.apple.com/documentation/corelocation/kcllocationaccuracybestfornavigation)
     (precise position information required at all times, with significant extra power requirement implication)
     */
    case maximum
}

// TODO investigate Int vs String rawValue
extension Accuracy: Codable, RawRepresentable {
    public typealias RawValue = String

    public var rawValue: String {
        switch self {
        case .minimum: return AccuracyKeys.minimum.rawValue
        case .low: return AccuracyKeys.low.rawValue
        case .balanced: return AccuracyKeys.balanced.rawValue
        case .high: return AccuracyKeys.high.rawValue
        case .maximum: return AccuracyKeys.maximum.rawValue
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case AccuracyKeys.minimum.rawValue:
            self = .minimum
        case AccuracyKeys.low.rawValue:
            self = .low
        case AccuracyKeys.balanced.rawValue:
            self = .balanced
        case AccuracyKeys.high.rawValue:
            self = .high
        case AccuracyKeys.maximum.rawValue:
            self = .maximum
        default:
            return nil
        }
    }
}

extension Accuracy: Comparable, Equatable {
    private var index: Int {
        switch self {
        case .minimum: return 1
        case .low: return 2
        case .balanced: return 3
        case .high: return 4
        case .maximum: return 5
        }
    }

    public static func < (lhs: Accuracy, rhs: Accuracy) -> Bool {
        lhs.index < rhs.index
    }

    public static func > (lhs: Accuracy, rhs: Accuracy) -> Bool {
        lhs.index > rhs.index
    }

    public static func == (lhs: Accuracy, rhs: Accuracy) -> Bool {
        lhs.index == rhs.index
    }
}
