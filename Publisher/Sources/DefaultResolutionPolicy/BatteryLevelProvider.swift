import UIKit

protocol BatteryLevelProvider {
    var currentBatteryPercentage: Float { get }
    func setup()
}

class DefaultBatteryLevelProvider: BatteryLevelProvider {
    var currentBatteryPercentage: Float { return UIDevice.current.batteryLevel }

    func setup() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
}
