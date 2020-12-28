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

    func track(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        let event = TrackTrackableEvent(trackable: trackable,
                                        onSuccess: onSuccess,
                                        onError: onError)
        execute(event: event)
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

// MARK: Threading events handling
extension DefaultPublisher {
    private func execute(event: PublisherEvent) {
        logger.trace("Received event: \(event)")
        switch event {
        case let event as SuccessEvent: performOnWorkingThread { [weak self] in self?.handleSuccessEvent(event) }
        case let event as ErrorEvent: performOnWorkingThread { [weak self] in self?.handleErrorEvent(event) }
        case let event as TrackTrackableEvent: performOnWorkingThread { [weak self] in self?.performTrackTrackableEvent(event) }
        case let event as TrackableReadyToTrackEvent: performOnWorkingThread { [weak self] in self?.performTrackableReadyToTrack(event) }
        case let event as EnhancedLocationChangedEvent: performOnWorkingThread { [weak self] in self?.performEnhancedLocationChanged(event) }
        case let event as RawLocationChangedEvent: performOnWorkingThread { [weak self] in self?.performRawLocationChanged(event) }
        case let event as DelegateErrorEvent: performOnWorkingThread { [weak self] in self?.notifyDelegateDidFailWithError(event.error) }
        default: preconditionFailure("Unhandled event in DefaultPublisher: \(event) ")
        }
    }

    // MARK: Track
    private func performTrackTrackableEvent(_ event: TrackTrackableEvent) {
        guard activeTrackable == nil else {
            let error =  AssetTrackingError.publisherError("For this preview version of the SDK, track() method may only be called once for any given instance of this class.")
            execute(event: ErrorEvent(error: error, onError: event.onError))
            return
        }

        activeTrackable = event.trackable
        self.ablyService.track(trackable: event.trackable) { [weak self] error in
            if let error = error {
                self?.execute(event: ErrorEvent(error: error, onError: event.onError))
                return
            }
            self?.execute(event: TrackableReadyToTrackEvent(trackable: event.trackable, onSuccess: event.onSuccess))
        }
    }

    private func performTrackableReadyToTrack(_ event: TrackableReadyToTrackEvent) {
        locationService.startUpdatingLocation()
        execute(event: SuccessEvent(onSuccess: event.onSuccess))
    }

    // MARK: Location Changed event
    private func performEnhancedLocationChanged(_ event: EnhancedLocationChangedEvent) {
        self.ablyService.sendEnhancedAssetLocation(location: event.location) { [weak self] error in
            if let error = error {
                self?.execute(event: DelegateErrorEvent(error: error))
            }
        }

        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: event.location)
        }
    }

    private func performRawLocationChanged(_ event: RawLocationChangedEvent) {
        ablyService.sendRawAssetLocation(location: event.location) { [weak self] error in
            if let error = error {
                self?.execute(event: DelegateErrorEvent(error: error))
            }
        }

        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateRawLocation: event.location)
        }
    }

    private func handleSuccessEvent(_ event: SuccessEvent) {
        performOnMainThread(event.onSuccess)
    }

    private func handleErrorEvent(_ event: ErrorEvent) {
        performOnMainThread { event.onError(event.error) }
    }

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workingQueue.async(execute: operation)
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }

    // MARK: Delegate
    private func notifyDelegateDidFailWithError(_ error: Error) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didFailWithError: error)
        }
    }


}

// MARK: LocationServiceDelegate
extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        logger.error("locationService.didFailWithError. Error: \(error)", source: "DefaultPublisher")
        execute(event: DelegateErrorEvent(error: error))
    }

    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        logger.debug("locationService.didUpdateRawLocation.", source: "DefaultPublisher")
        execute(event: RawLocationChangedEvent(location: location))
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        logger.debug("locationService.didUpdateEnhancedLocation.", source: "DefaultPublisher")
        execute(event: EnhancedLocationChangedEvent(location: location))
    }
}

// MARK: AblyPublisherServiceDelegate
extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState) {
        logger.debug("publisherService.didChangeConnectionState. State: \(state)", source: "DefaultPublisher")
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didChangeConnectionState: state)
        }
    }
}
