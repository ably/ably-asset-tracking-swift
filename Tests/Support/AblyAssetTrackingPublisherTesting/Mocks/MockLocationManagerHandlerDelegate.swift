@testable import AblyAssetTrackingPublisher
import CoreLocation
import MapboxCoreNavigation

public class MockPassiveLocationManagerHandlerDelegate: PassiveLocationManagerHandlerDelegate {

    public init() {}

    public var passiveLocationManagerHandlerDidChangeAuthorizationCalled = false
    public func passiveLocationManagerHandlerDidChangeAuthorization(handler: PassiveLocationManagerHandler) {
        passiveLocationManagerHandlerDidChangeAuthorizationCalled = true
    }

    public var passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation: Location?
    public var passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled = false
    public func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateEnhancedLocation location: Location) {
        passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled = true
        passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation = location
    }

    public var passiveLocationManagerHandlerDidUpdateRawLocationParamLocation: Location?
    public var passiveLocationManagerHandlerDidUpdateRawLocationCalled = false
    public func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateRawLocation location: Location) {
        passiveLocationManagerHandlerDidUpdateRawLocationCalled = true
        passiveLocationManagerHandlerDidUpdateRawLocationParamLocation = location
    }

    public var passiveLocationManagerHandlerDidUpdateHeadingCalled = false
    public var passiveLocationManagerHandlerDidUpdateHeadingParamNewHeading: CLHeading?
    public func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateHeading newHeading: CLHeading) {
        passiveLocationManagerHandlerDidUpdateHeadingCalled = true
        passiveLocationManagerHandlerDidUpdateHeadingParamNewHeading = newHeading
    }

    public var passiveLocationManagerHandlerErrorDidFailWithErrorCalled = false
    public var passiveLocationManagerHandlerErrorDidFailWithErrorParamError: Error?
    public func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didFailWithError error: Error) {
        passiveLocationManagerHandlerErrorDidFailWithErrorCalled = true
        passiveLocationManagerHandlerErrorDidFailWithErrorParamError = error
    }
}
