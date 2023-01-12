@testable import AblyAssetTrackingPublisher
import CoreLocation
import MapboxCoreNavigation

public class MockLocationManagerHandlerDelegate: LocationManagerHandlerDelegate {
    public init() {}

    public var locationManagerHandlerDidChangeAuthorizationCalled = false
    public func locationManagerHandlerDidChangeAuthorization() {
        locationManagerHandlerDidChangeAuthorizationCalled = true
    }
    
    public var locationManagerHandlerDidUpdateEnhancedLocationParamLocation: Location?
    public var locationManagerHandlerDidUpdateEnhancedLocationCalled = false
    public func locationManagerHandler(handler: LocationManagerHandler, didUpdateEnhancedLocation location: Location) {
        locationManagerHandlerDidUpdateEnhancedLocationCalled = true
        locationManagerHandlerDidUpdateEnhancedLocationParamLocation = location
    }
    
    public var locationManagerHandlerDidUpdateRawLocationParamLocation: Location?
    public var locationManagerHandlerDidUpdateRawLocationCalled = false
    public func locationManagerHandler(handler: LocationManagerHandler, didUpdateRawLocation location: Location) {
        locationManagerHandlerDidUpdateRawLocationCalled = true
        locationManagerHandlerDidUpdateRawLocationParamLocation = location
    }
    
    public var locationManagerHandlerDidUpdateHeadingCalled = false
    public var locationManagerHandlerDidUpdateHeadingParamNewHeading: CLHeading?
    public func locationManagerHandler(handler: LocationManagerHandler, didUpdateHeading newHeading: CLHeading) {
        locationManagerHandlerDidUpdateHeadingCalled = true
        locationManagerHandlerDidUpdateHeadingParamNewHeading = newHeading
    }
    
    public var locationManagerHandlerErrorDidFailWithErrorCalled = false
    public var locationManagerHandlerErrorDidFailWithErrorParamError: Error?
    public func locationManagerHandler(handler: LocationManagerHandler, didFailWithError error: Error) {
        locationManagerHandlerErrorDidFailWithErrorCalled = true
        locationManagerHandlerErrorDidFailWithErrorParamError = error
    }
    
}
