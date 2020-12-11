import UIKit
import CoreLocation

public class DefaultPublisher: AssetTrackingPublisher {
    private let configuration: AssetTrackingPublisherConfiguration
    private let locationService: LocationService
    private let ablyService: AblyPublisherService

    public weak var delegate: AssetTrackingPublisherDelegate?
    private(set) public var activeTrackable: Trackable?
    public var transportationMode: TransportationMode

    /**
     Default constructor. Initializes Publisher with given `AssetTrackingPublisherConfiguration`.
     Publisher starts listening (and notifying delegate) after initialization.
     - Parameters:
     -  configuration: Configuration struct to use in this instance.
     */
    public init(configuration: AssetTrackingPublisherConfiguration) {
        self.configuration = configuration
        self.locationService = LocationService()
        self.ablyService = AblyPublisherService(apiKey: configuration.apiKey,
                                                clientId: configuration.clientId)

        // TODO: Set proper values from configuration
        self.activeTrackable = nil
        self.transportationMode = TransportationMode()
        self.ablyService.delegate = self
        self.locationService.delegate = self
    }

    public func track(trackable: Trackable) {
        activeTrackable = trackable
        ablyService.track(trackable: trackable) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
            }
            self.locationService.startUpdatingLocation()
        }
    }

    public func add(trackable: Trackable) {
        // TODO: Implement method
        failWithNotYetImplemented()
    }

    public func remove(trackable: Trackable) -> Bool {
        // TODO: Implement method
        failWithNotYetImplemented()

        return false
    }

    public func stop() {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
}

extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
    }

    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        delegate?.assetTrackingPublisher(sender: self, didUpdateRawLocation: location)
        ablyService.sendRawAssetLocation(location: location) { [weak self] error in
            if let self = self,
               let error = error {
                self.delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
            }
        }
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        delegate?.assetTrackingPublisher(sender: self, didUpdateEnhancedLocation: location)
        ablyService.sendEnhancedAssetLocation(location: location) { [weak self] error in
            if let self = self,
               let error = error {
                self.delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
            }
        }
    }
}

extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didChangeConnectionStatus status: AblyConnectionStatus) {
        delegate?.assetTrackingPublisher(sender: self, didChangeConnectionStatus: status)
    }
}
