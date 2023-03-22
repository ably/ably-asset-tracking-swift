import UIKit

protocol BatteryLevelProvider {
    var currentBatteryPercentage: Float? { get }
}

class DefaultBatteryLevelProvider: BatteryLevelProvider {
    var currentBatteryPercentage: Float? {
        let level = UIDevice.current.batteryLevel
        guard 0...1.0 ~= level else {
            return nil
        }
        return level * 100.0
    }

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
}
