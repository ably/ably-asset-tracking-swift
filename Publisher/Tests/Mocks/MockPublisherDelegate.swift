import CoreLocation
import Foundation
@testable import Publisher

class MockPublisherDelegate: PublisherDelegate {
    var publisherDidFailWithErrorCalled: Bool = false
    var publisherDidFailWithErrorParamSender: Publisher?
    var publisherDidFailWithErrorParamError: ErrorInformation?
    var publisherDidFailWithErrorCallback: (() -> Void)?
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        publisherDidFailWithErrorCalled = true
        publisherDidFailWithErrorParamSender = sender
        publisherDidFailWithErrorParamError = error
        publisherDidFailWithErrorCallback?()
    }

    var publisherDidUpdateEnhancedLocationCalled: Bool = false
    var publisherDidUpdateEnhancedLocationParamSender: Publisher?
    var publisherDidUpdateEnhancedLocationParamLocation: CLLocation?
    var publisherDidUpdateEnhancedLocationCallback: (() -> Void)?
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation) {
        publisherDidUpdateEnhancedLocationCalled = true
        publisherDidUpdateEnhancedLocationParamSender = sender
        publisherDidUpdateEnhancedLocationParamLocation = location
        publisherDidUpdateEnhancedLocationCallback?()
    }

    var publisherDidChangeTrackableConnectionStateCalled: Bool = false
    var publisherDidChangeTrackableConnectionStateParamSender: Publisher?
    var publisherDidChangeTrackableConnectionStateParamState: ConnectionState?
    var publisherDidChangeTrackableConnectionStateParamTrackable: Trackable?
    var publisherDidChangeTrackableConnectionStateCallback: (() -> Void)?
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        publisherDidChangeTrackableConnectionStateCalled = true
        publisherDidChangeTrackableConnectionStateParamSender = sender
        publisherDidChangeTrackableConnectionStateParamState = state
        publisherDidChangeTrackableConnectionStateParamTrackable = trackable
        publisherDidChangeTrackableConnectionStateCallback?()
    }
    
    var publisherDidUpdateResolutionCalled: Bool = false
    var publisherDidUpdateResolutionParamSender: Publisher?
    var publisherDidUpdateResolutionParamResolution: Resolution?
    var publisherDidUpdateResolutionCallback: (() -> Void)?
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        publisherDidUpdateResolutionCalled = true
        publisherDidUpdateResolutionParamSender = sender
        publisherDidUpdateResolutionParamResolution = resolution
        publisherDidUpdateResolutionCallback?()
    }
}
