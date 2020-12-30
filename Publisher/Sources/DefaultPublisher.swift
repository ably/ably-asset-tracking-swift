import UIKit
import CoreLocation
import Logging
// swiftlint:disable cyclomatic_complexity

// Default logger used in Publisher SDK
let logger: Logger = Logger(label: "com.ably.asset-tracking.Publisher")

class DefaultPublisher: Publisher {
    private let workingQueue: DispatchQueue
    private let connectionConfiguration: ConnectionConfiguration
    private let logConfiguration: LogConfiguration
    private let locationService: LocationService
    private let ablyService: AblyPublisherService
    private let resolutionPolicy: ResolutionPolicy
    private let hooks: DefaultResolutionPolicyHooks
    private let methods: DefaultResolutionPolicyMethods

    public let transportationMode: TransportationMode
    public weak var delegate: PublisherDelegate?
    private(set) public var activeTrackable: Trackable?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         transportationMode: TransportationMode,
         resolutionPolicyFactory: ResolutionPolicyFactory,
         ablyService: AblyPublisherService,
         locationService: LocationService) {
        self.connectionConfiguration = connectionConfiguration
        self.logConfiguration = logConfiguration
        self.transportationMode = transportationMode
        self.workingQueue = DispatchQueue(label: "io.ably.asset-tracking.Publisher.DefaultPublisher",
                                          qos: .default)
        self.locationService = locationService
        self.ablyService = ablyService

        self.hooks = DefaultResolutionPolicyHooks()
        self.methods = DefaultResolutionPolicyMethods()
        self.resolutionPolicy = resolutionPolicyFactory.createResolutionPolicy(hooks: hooks,
                                                                               methods: methods)

        self.ablyService.delegate = self
        self.locationService.delegate = self
        self.methods.delegate = self
    }

    func track(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        let event = TrackTrackableEvent(trackable: trackable,
                                        onSuccess: onSuccess,
                                        onError: onError)
        execute(event: event)
    }

    func add(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        let event = AddTrackableEvent(trackable: trackable, onSuccess: onSuccess, onError: onError)
        execute(event: event)
    }

    func remove(trackable: Trackable, onSuccess: @escaping (_ wasPresent: Bool) -> Void, onError: @escaping ErrorHandler) {
        let event = RemoveTrackableEvent(trackable: trackable, onSuccess: onSuccess, onError: onError)
        execute(event: event)
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
        performOnWorkingThread { [weak self] in
            switch event {
            case let event as SuccessEvent: self?.handleSuccessEvent(event)
            case let event as ErrorEvent: self?.handleErrorEvent(event)
            case let event as TrackTrackableEvent:  self?.performTrackTrackableEvent(event)
            case let event as PresenceJoinedSuccessfullyEvent: self?.performPresenceJoinedSuccessfullyEvent(event)
            case let event as TrackableReadyToTrackEvent: self?.performTrackableReadyToTrack(event)
            case let event as EnhancedLocationChangedEvent: self?.performEnhancedLocationChanged(event)
            case let event as RawLocationChangedEvent: self?.performRawLocationChanged(event)
            case let event as AddTrackableEvent: self?.performAddTrackableEvent(event)
            case let event as RemoveTrackableEvent: self?.performRemoveTrackableEvent(event)
            case let event as ClearActiveTrackableEvent: self?.performClearActiveTrackableEvent(event)

            case let event as DelegateErrorEvent: self?.notifyDelegateDidFailWithError(event.error)
            case let event as DelegateConnectionStateChangedEvent: self?.notifyDelegateConnectionStateChanged(event)
            case let event as DelegateRawLocationChangedEvent: self?.notifyDelegateRawLocationChanged(event)
            case let event as DelegateEnhancedLocationChangedEvent: self?.notifyDelegateEnhancedLocationChanged(event)
            default: preconditionFailure("Unhandled event in DefaultPublisher: \(event) ")
            }
        }
    }

    // MARK: Track
    private func performTrackTrackableEvent(_ event: TrackTrackableEvent) {
        guard activeTrackable == nil else {
            let error =  AssetTrackingError.publisherError("For this preview version of the SDK, track() method may only be called once for any given instance of this class.")
            execute(event: ErrorEvent(error: error, onError: event.onError))
            return
        }

        self.ablyService.track(trackable: event.trackable) { [weak self] error in
            if let error = error {
                self?.execute(event: ErrorEvent(error: error, onError: event.onError))
                return
            }

            self?.execute(event: PresenceJoinedSuccessfullyEvent(
                            trackable: event.trackable,
                            onComplete: { [weak self] in
                                self?.execute(event: TrackableReadyToTrackEvent(trackable: event.trackable, onSuccess: event.onSuccess))
                            })
            )
        }
    }

    private func performTrackableReadyToTrack(_ event: TrackableReadyToTrackEvent) {
        if activeTrackable != event.trackable {
            activeTrackable = event.trackable
            hooks.trackables?.onActiveTrackableChanged(trackable: event.trackable)
            // TODO: Set destination here while working on route based map matching
        }
        execute(event: SuccessEvent(onSuccess: event.onSuccess))
    }

    private func performPresenceJoinedSuccessfullyEvent(_ event: PresenceJoinedSuccessfullyEvent) {
        locationService.startUpdatingLocation()
        hooks.trackables?.onTrackableAdded(trackable: event.trackable)
        event.onComplete()
    }

    // MARK: Add
    private func performAddTrackableEvent(_ event: AddTrackableEvent) {
        self.ablyService.track(trackable: event.trackable) { [weak self] error in
            if let error = error {
                self?.execute(event: ErrorEvent(error: error, onError: event.onError))
                return
            }
            self?.execute(event: PresenceJoinedSuccessfullyEvent(
                            trackable: event.trackable,
                            onComplete: { [weak self] in self?.execute(event: SuccessEvent(onSuccess: event.onSuccess)) })
            )
        }
    }

    // MARK: Remove
    private func performRemoveTrackableEvent(_ event: RemoveTrackableEvent) {
        hooks.trackables?.onTrackableRemoved(trackable: event.trackable)
        self.ablyService.stopTracking(trackable: event.trackable) { [weak self] wasPresent in
            wasPresent ?
                self?.execute(event: ClearActiveTrackableEvent(trackable: event.trackable, onSuccess: event.onSuccess)) :
                self?.execute(event: SuccessEvent(onSuccess: { event.onSuccess(false) }))
        } onError: { [weak self] error in
            self?.execute(event: ErrorEvent(error: error, onError: event.onError))
        }
    }

    private func performClearActiveTrackableEvent(_ event: ClearActiveTrackableEvent) {
        if activeTrackable == event.trackable {
            activeTrackable = nil
            hooks.trackables?.onActiveTrackableChanged(trackable: nil)
            // TODO: Clear current destination in LocationService while working on route based map matching
        }
        if ablyService.trackables.isEmpty {
            locationService.stopUpdatingLocation()
        }
        execute(event: SuccessEvent(onSuccess: { event.onSuccess(true) }))
    }

    // MARK: Location change
    private func performEnhancedLocationChanged(_ event: EnhancedLocationChangedEvent) {
        self.ablyService.sendEnhancedAssetLocation(location: event.location) { [weak self] error in
            if let error = error {
                self?.execute(event: DelegateErrorEvent(error: error))
            }
        }
    }

    private func performRawLocationChanged(_ event: RawLocationChangedEvent) {
        ablyService.sendRawAssetLocation(location: event.location) { [weak self] error in
            if let error = error {
                self?.execute(event: DelegateErrorEvent(error: error))
            }
        }
    }

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workingQueue.async(execute: operation)
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }

    private func handleSuccessEvent(_ event: SuccessEvent) {
        performOnMainThread(event.onSuccess)
    }

    private func handleErrorEvent(_ event: ErrorEvent) {
        performOnMainThread { event.onError(event.error) }
    }

    // MARK: Delegate
    private func notifyDelegateDidFailWithError(_ error: Error) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didFailWithError: error)
        }
    }

    private func notifyDelegateRawLocationChanged(_ event: DelegateRawLocationChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateRawLocation: event.location)
        }
    }

    private func notifyDelegateEnhancedLocationChanged(_ event: DelegateEnhancedLocationChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: event.location)
        }
    }

    private func notifyDelegateConnectionStateChanged(_ event: DelegateConnectionStateChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didChangeConnectionState: event.connectionState)
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
        execute(event: DelegateRawLocationChangedEvent(location: location))
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        logger.debug("locationService.didUpdateEnhancedLocation.", source: "DefaultPublisher")
        execute(event: EnhancedLocationChangedEvent(location: location))
        execute(event: DelegateEnhancedLocationChangedEvent(location: location))
    }
}

// MARK: AblyPublisherServiceDelegate
extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didFailWithError error: Error) {
        logger.error("publisherService.didFailWithError. Error: \(error)", source: "DefaultPublisher")
        execute(event: DelegateErrorEvent(error: error))
    }

    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState) {
        logger.debug("publisherService.didChangeConnectionState. State: \(state)", source: "DefaultPublisher")
        execute(event: DelegateConnectionStateChangedEvent(connectionState: state))
    }
}

// MARK: ResolutionPolicyMethodsDelegate
extension DefaultPublisher: DefaultResolutionPolicyMethodsDelegate {
    func resolutionPolicyMethods(refreshWithSender sender: DefaultResolutionPolicyMethods) {
        // TODO: Handle
    }

    func resolutionPolicyMethods(cancelProximityThresholdWithSender sender: DefaultResolutionPolicyMethods) {
        // TODO: Handle
    }

    func resolutionPolicyMethods(sender: DefaultResolutionPolicyMethods,
                                 setProximityThreshold threshold: Proximity,
                                 withHandler handler: ProximityHandler) {
        // TODO: Handle
    }
}
