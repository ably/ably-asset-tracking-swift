@testable import Publisher

class MockBatteryLevelProvider: BatteryLevelProvider {
    
    var currentBatteryPercentageGetCalled: Bool = false
    var currentBatteryPercentageReturnValue: Float?
    var currentBatteryPercentage: Float? {
        currentBatteryPercentageGetCalled = true
        return currentBatteryPercentageReturnValue
    }
}
