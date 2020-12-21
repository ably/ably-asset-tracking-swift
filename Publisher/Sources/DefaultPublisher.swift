import UIKit
import CoreLocation
import Logging

// Default logger used in Publisher SDK
let logger: Logger = Logger(label: "com.ably.asset-tracking.Publisher")

class DefaultPublisher: Publisher {
    private let workingQueue: DispatchQueue
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
        self.workingQueue = DispatchQueue(label: "io.ably.asset-tracking.Publisher.DefaultPublisher",
                                          qos: .default)
        self.locationService = LocationService()
        self.ablyService = AblyPublisherService(configuration: connectionConfiguration)

        self.ablyService.delegate = self
        self.locationService.delegate = self
    }

    func track(trackable: Trackable) {
        performOnWorkingThread { [weak self] in
            guard let self = self else { return }

            self.activeTrackable = trackable
            self.ablyService.track(trackable: trackable) { [weak self] error in
                if let error = error {
                    self?.notifyDelegateDidFailWithError(error)
                }
                self?.performOnWorkingThread { [weak self] in
                    self?.locationService.startUpdatingLocation()
                }
            }
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

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workingQueue.async(execute: operation)
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }

    private func notifyDelegateDidFailWithError(_ error: Error) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didFailWithError: error)
        }
    }
}

extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        logger.error("locationService.didFailWithError. Error: \(error)", source: "DefaultPublisher")
        notifyDelegateDidFailWithError(error)
    }

    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        logger.debug("locationService.didUpdateRawLocation.", source: "DefaultPublisher")
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateRawLocation: location)
        }

        ablyService.sendRawAssetLocation(location: location) { [weak self] error in
            if let error = error {
                self?.notifyDelegateDidFailWithError(error)
            }
        }
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        logger.debug("locationService.didUpdateEnhancedLocation.", source: "DefaultPublisher")
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: location)
        }

        performOnWorkingThread { [weak self] in
            guard let self = self else { return }
            self.ablyService.sendEnhancedAssetLocation(location: location) { [weak self] error in
                if let error = error {
                    self?.notifyDelegateDidFailWithError(error)
                }
            }
        }
    }
}

extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState) {
        logger.debug("publisherService.didChangeConnectionState. State: \(state)", source: "DefaultPublisher")
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didChangeConnectionState: state)
        }
    }
}
