import AblyAssetTrackingCore
import Combine
import Foundation

// swiftlint:disable:next missing_docs
public protocol LocationAnimator {
    /**
     Defines how many animation steps need to be completed to publish `subscribeForCameraPositionUpdates`
     Default value is 1
     */
    var animationStepsBetweenCameraUpdates: Int { get set }

    /**
     This closure returns position in CADisplayLink framerate
     */
    func subscribeForPositionUpdates(_ closure: @escaping (Position) -> Void)

    /**
     This closure returns trackable position every `animationStepsBetweenCameraUpdates`
     */
    func subscribeForCameraPositionUpdates(_ closure: @escaping (Position) -> Void)

    /**
     Animate location method.
     Use this method to calculate animation keyframes between location updates.
     
     - Parameter location       `LocationUpdate` object
     - Parameter expectedIntervalBetweenLocationUpdatesInMilliseconds       The expected interval of location updates in milliseconds.
     
     */
    func animateLocationUpdate(location: LocationUpdate, expectedIntervalBetweenLocationUpdatesInMilliseconds: TimeInterval)

    /**
     Stops the animation loop
     */
    func stop()
}

public struct Position: CustomDebugStringConvertible, CustomStringConvertible {
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let bearing: Double

    public var debugDescription: String {
        """
        latitude: \(latitude)
        longitude: \(longitude)
        accuracy: \(accuracy)
        bearing: \(bearing)
        """
    }

    public var description: String {
        "\(latitude),\(longitude)"
    }
}
