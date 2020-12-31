import UIKit

protocol BatteryLevelProvider {
    var currentBatteryPercentage: Float? { get }
}

class DefaultBatteryLevelProvider: BatteryLevelProvider {
    var currentBatteryPercentage: Float? {
        let level = UIDevice.current.batteryLevel
        if level < 0 || level > 1.0 { return nil }
        return level * 100.0
    }

    static func setup() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
}
