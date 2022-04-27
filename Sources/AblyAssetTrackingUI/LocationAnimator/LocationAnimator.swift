import Foundation
import AblyAssetTrackingCore
import Combine

public protocol LocationAnimator {
    /**
     Time interval (in seconds) for publishing `fragmentaryPosition`.
     Default value is 5.0 seconds
     */
    var fragmentaryPositionInterval: TimeInterval { get set }
    
    /**
     This closure returns position in CADisplayLink framerate
     */
    func trackablePosition(_ closure: @escaping (Position) -> Void)
    
    /**
     This closure returns trackable position every `fragmentaryPositionInterval`
     */
    func fragmentaryPosition(_ closure: @escaping (Position) -> Void)
    
    /**
     Animate location method.
     Use this method to calculate animation keyframes between location updates.
     
     - Parameter location        `LocationUpdate` object
     - Parameter interval        expected interval between location updates in seconds
     
     */
    func animateLocationUpdate(location: LocationUpdate, interval: TimeInterval)
}

public protocol Position {
    var latitude: Double { get }
    var longitude: Double { get }
    var accuracy: Double { get }
    var bearing: Double { get }
}
