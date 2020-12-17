import UIKit
import CoreLocation

class DefaultPublisher: Publisher {
    private let connectionConfiguration: ConnectionConfiguration
    private let logConfiguration: LogConfiguration
    private let locationService: LocationService
    private let ablyService: AblyPublisherService

    public let transportationMode: TransportationMode
    public weak var delegate: PublisherDelegate?
    private(set) public var activeTrackable: Trackable?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         transportationMode: TransportationMode) {
        self.connectionConfiguration = connectionConfiguration
        self.logConfiguration = logConfiguration
        self.transportationMode = transportationMode

        self.locationService = LocationService()
        self.ablyService = AblyPublisherService(configuration: connectionConfiguration)

        self.ablyService.delegate = self
        self.locationService.delegate = self
    }

    func track(trackable: Trackable) {
        activeTrackable = trackable
        ablyService.track(trackable: trackable) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.publisher(sender: self, didFailWithError: error)
            }
            self.locationService.startUpdatingLocation()
        }
    }

    func add(trackable: Trackable) {
        // TODO: Implement method
        failWithNotYetImplemented()
    }

    func remove(trackable: Trackable) -> Bool {
        // TODO: Implement method
        failWithNotYetImplemented()

        return false
    }

    func stop() {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
}

extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.publisher(sender: self, didFailWithError: error)
    }

    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        delegate?.publisher(sender: self, didUpdateRawLocation: location)
        ablyService.sendRawAssetLocation(location: location) { [weak self] error in
            if let self = self,
               let error = error {
                self.delegate?.publisher(sender: self, didFailWithError: error)
            }
        }
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        delegate?.publisher(sender: self, didUpdateEnhancedLocation: location)
        ablyService.sendEnhancedAssetLocation(location: location) { [weak self] error in
            if let self = self,
               let error = error {
                self.delegate?.publisher(sender: self, didFailWithError: error)
            }
        }
    }
}

extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState) {
        delegate?.publisher(sender: self, didChangeConnectionState: state)
    }
}
