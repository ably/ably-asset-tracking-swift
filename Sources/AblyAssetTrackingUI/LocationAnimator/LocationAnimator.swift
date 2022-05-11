import Foundation
import AblyAssetTrackingCore
import Combine

public protocol LocationAnimator {
    /**
     Time interval (in seconds) for publishing `subscribeForInfrequentlyUpdatingPosition`.
     Default value is 5.0 seconds
     */
    var infrequentlyUpdatingPositionInterval: TimeInterval { get set }
    
    /**
     This closure returns position in CADisplayLink framerate
     */
    func subscribeForFrequentlyUpdatingPosition(_ closure: @escaping (Position) -> Void)
    
    /**
     This closure returns trackable position every `infrequentlyUpdatingPositionInterval`
     */
    func subscribeForInfrequentlyUpdatingPosition(_ closure: @escaping (Position) -> Void)
    
    /**
     Animate location method.
     Use this method to calculate animation keyframes between location updates.
     
     - Parameter location        `LocationUpdate` object
     - Parameter interval        expected interval between location updates in seconds
     
     */
    func animateLocationUpdate(location: LocationUpdate, interval: TimeInterval)
}

public struct Position: CustomDebugStringConvertible {
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
}
