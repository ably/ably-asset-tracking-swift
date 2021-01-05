import CoreLocation
import Foundation
@testable import Publisher

class MockPublisherDelegate: PublisherDelegate {
    var publisherDidFailWithErrorCalled: Bool = false
    var publisherDidFailWithErrorParamSender: Publisher?
    var publisherDidFailWithErrorParamError: Error?
    var publisherDidFailWithErrorCallback: (() -> Void)?
    func publisher(sender: Publisher, didFailWithError error: Error) {
        publisherDidFailWithErrorCalled = true
        publisherDidFailWithErrorParamSender = sender
        publisherDidFailWithErrorParamError = error
        publisherDidFailWithErrorCallback?()
    }

    var publisherDidUpdateRawLocationCalled: Bool = false
    var publisherDidUpdateRawLocationParamSender: Publisher?
    var publisherDidUpdateRawLocationParamLocation: CLLocation?
    var publisherDidUpdateRawLocationCallback: (() -> Void)?
    func publisher(sender: Publisher, didUpdateRawLocation location: CLLocation) {
        publisherDidUpdateRawLocationCalled = true
        publisherDidUpdateRawLocationParamSender = sender
        publisherDidUpdateRawLocationParamLocation = location
        publisherDidUpdateRawLocationCallback?()
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

    var publisherDidChangeConnectionStateCalled: Bool = false
    var publisherDidChangeConnectionStateParamSender: Publisher?
    var publisherDidChangeConnectionStateParamState: ConnectionState?
    var publisherDidChangeConnectionStateCallback: (() -> Void)?
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState) {
        publisherDidChangeConnectionStateCalled = true
        publisherDidChangeConnectionStateParamSender = sender
        publisherDidChangeConnectionStateParamState = state
        publisherDidChangeConnectionStateCallback?()
    }
}
