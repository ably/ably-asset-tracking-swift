import Foundation
import AblyAssetTrackingCore
import Combine

protocol LocationAnimator {
    /**
     Calculated positions stream.
     */
    func positions(_ closure: @escaping (Position) -> ())
    
    /**
     Animate location method.
     Use this method to calculate animation keyframes between location updates.
     
     - Parameter location        `LocationUpdate` object
     - Parameter interval        expected interval between location updates
     
     */
    func animateLocationUpdate(location: LocationUpdate, interval: TimeInterval)
}

protocol Position {
    var latitude: Double { get }
    var longitude: Double { get }
    var accuracy: Double { get }
    var bearing: Double { get }
}
