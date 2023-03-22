import AblyAssetTrackingInternal
import CoreLocation
import Foundation
import MapboxCoreNavigation

protocol PassiveLocationManagerHandlerDelegate: AnyObject {
    @available(iOS 14.0, *)
    func passiveLocationManagerHandlerDidChangeAuthorization(handler: PassiveLocationManagerHandler)

    func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateEnhancedLocation location: Location)

    func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateRawLocation location: Location)

    func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didUpdateHeading newHeading: CLHeading)

    func passiveLocationManagerHandler(handler: PassiveLocationManagerHandler, didFailWithError error: Error)
}

/**
 An independently testable utility class used by the DefaultLocationService implementation
 that receives, validates, sanitizes and transforms mapbox locations before sending them on to AAT.
*/
internal class PassiveLocationManagerHandler: PassiveLocationManagerDelegate {
    let logHandler: InternalLogHandler?

    weak var delegate: PassiveLocationManagerHandlerDelegate?

    init(logHandler: InternalLogHandler?) {
        self.logHandler = logHandler
    }

    /** Mocking and testing the Mapbox's PassiveLocationManager used in the
    `PassiveLocationManagerDelegate` methods is pretty much impossible, so the
    `handleEnhancedLocationUpdate` and `handleRawLocationUpdate` utility methods
     were created to make the location update data sanitization process testable.
     */
    func handleEnhancedLocationUpdate(location: CLLocation) {
        let enhancedLocationResult = location.toLocation()
        do {
            let enhancedLocationFromResult = try enhancedLocationResult.get()
            delegate?.passiveLocationManagerHandler(handler: self, didUpdateEnhancedLocation: enhancedLocationFromResult)
        } catch {
            logHandler?.verbose(message: "Swallowing invalid enhanced location from Mapbox, validation error was: \(error as? LocationValidationError)", error: error)
        }
    }

    func handleRawLocationUpdate(location: CLLocation) {
        let rawLocationResult = location.toLocation()
        do {
            let rawLocationFromResult = try rawLocationResult.get()
            delegate?.passiveLocationManagerHandler(handler: self, didUpdateRawLocation: rawLocationFromResult)
        } catch {
            logHandler?.verbose(message: "Swallowing invalid raw location from Mapbox, validation error was: \(error as? LocationValidationError)", error: error)
        }
    }

    func passiveLocationManagerDidChangeAuthorization(_ manager: PassiveLocationManager) {
        if #available(iOS 14.0, *) {
            delegate?.passiveLocationManagerHandlerDidChangeAuthorization(handler: self)
        }
    }

    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
        handleRawLocationUpdate(location: rawLocation)
        handleEnhancedLocationUpdate(location: location)
    }

    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.passiveLocationManagerHandler(handler: self, didUpdateHeading: newHeading)
    }

    func passiveLocationManager(_ manager: PassiveLocationManager, didFailWithError error: Error) {
        delegate?.passiveLocationManagerHandler(handler: self, didFailWithError: error)
    }
}
