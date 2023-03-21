@testable import AblyAssetTrackingPublisher

public class MockBatteryLevelProvider: BatteryLevelProvider {
    public init() {}

    public var currentBatteryPercentageGetCalled = false
    public var currentBatteryPercentageReturnValue: Float?
    public var currentBatteryPercentage: Float? {
        currentBatteryPercentageGetCalled = true
        return currentBatteryPercentageReturnValue
    }
}
