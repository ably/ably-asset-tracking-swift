import UIKit
import CoreLocation
import Logging
import MapboxDirections

// Default logger used in Publisher SDK
let logger: Logger = Logger(label: "com.ably.tracking.Publisher")

// swiftlint:disable cyclomatic_complexity 
class DefaultPublisher: Publisher {
    private let workingQueue: DispatchQueue
    private let connectionConfiguration: ConnectionConfiguration
    private let logConfiguration: LogConfiguration
    private let locationService: LocationService
    private let ablyService: AblyPublisherService
    private let resolutionPolicy: ResolutionPolicy
    private let routeProvider: RouteProvider

    // ResolutionPolicy
    private let hooks: DefaultResolutionPolicyHooks
    private let methods: DefaultResolutionPolicyMethods
    private var proximityThreshold: Proximity?
    private var proximityHandler: ProximityHandler?
    private var requests: [Trackable: [Subscriber: Resolution]]
    private var subscribers: [Trackable: Set<Subscriber>]
    private var resolutions: [Trackable: Resolution]
    private var locationEngineResolution: Resolution

    private var lastRawLocations: [Trackable: CLLocation]
    private var lastRawTimestamps: [Trackable: Date]
    private var lastEnhancedLocations: [Trackable: CLLocation]
    private var lastEnhancedTimestamps: [Trackable: Date]
    private var route: Route?

    public let transportationMode: TransportationMode
    public weak var delegate: PublisherDelegate?
    private(set) public var activeTrackable: Trackable?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         transportationMode: TransportationMode,
         resolutionPolicyFactory: ResolutionPolicyFactory,
         ablyService: AblyPublisherService,
         locationService: LocationService,
         routeProvider: RouteProvider) {
        self.connectionConfiguration = connectionConfiguration
        self.logConfiguration = logConfiguration
        self.transportationMode = transportationMode
        self.workingQueue = DispatchQueue(label: "io.ably.tracking.Publisher.DefaultPublisher", qos: .default)
        self.locationService = locationService
        self.ablyService = ablyService
        self.routeProvider = routeProvider

        self.hooks = DefaultResolutionPolicyHooks()
        self.methods = DefaultResolutionPolicyMethods()
        self.resolutionPolicy = resolutionPolicyFactory.createResolutionPolicy(hooks: hooks, methods: methods)
        self.locationEngineResolution = resolutionPolicy.resolve(resolutions: [])

        self.requests = [:]
        self.subscribers = [:]
        self.resolutions = [:]
        self.lastRawLocations = [:]
        self.lastEnhancedLocations = [:]
        self.lastRawTimestamps = [:]
        self.lastEnhancedTimestamps = [:]

        self.ablyService.delegate = self
        self.locationService.delegate = self
        self.methods.delegate = self

        DefaultBatteryLevelProvider.setup()
    }

    func track(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        let event = TrackTrackableEvent(trackable: trackable,
                                        onSuccess: onSuccess,
                                        onError: onError)
        enqueue(event: event)
    }

    func add(trackable: Trackable, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
         let event = AddTrackableEvent(trackable: trackable, onSuccess: onSuccess, onError: onError)
        enqueue(event: event)
     }

    func remove(trackable: Trackable, onSuccess: @escaping (_ wasPresent: Bool) -> Void, onError: @escaping ErrorHandler) {
         let event = RemoveTrackableEvent(trackable: trackable, onSuccess: onSuccess, onError: onError)
         enqueue(event: event)
     }

    func stop() {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
}

// MARK: Threading events handling
extension DefaultPublisher {
    private func enqueue(event: PublisherEvent) {
        logger.trace("Received event: \(event)")
        performOnWorkingThread { [weak self] in
            switch event {
            case let event as TrackTrackableEvent:  self?.performTrackTrackableEvent(event)
            case let event as PresenceJoinedSuccessfullyEvent: self?.performPresenceJoinedSuccessfullyEvent(event)
            case let event as TrackableReadyToTrackEvent: self?.performTrackableReadyToTrack(event)
            case let event as EnhancedLocationChangedEvent: self?.performEnhancedLocationChanged(event)
            case let event as RawLocationChangedEvent: self?.performRawLocationChanged(event)
            case let event as AddTrackableEvent: self?.performAddTrackableEvent(event)
            case let event as RemoveTrackableEvent: self?.performRemoveTrackableEvent(event)
            case let event as ClearActiveTrackableEvent: self?.performClearActiveTrackableEvent(event)
            case let event as RefreshResolutionPolicyEvent: self?.performRefreshResolutionPolicyEvent(event)
            case let event as ChangeLocationEngineResolutionEvent: self?.performChangeLocationEngineResolutionEvent(event)
            case let event as PresenceUpdateEvent: self?.performPresenceUpdateEvent(event)
            case let event as ClearRemovedTrackableMetadataEvent: self?.performClearRemovedTrackableMetadataEvent(event)
            case let event as SetDestinationSuccessEvent: self?.performSetDestinationSuccessEvent(event)
            default: preconditionFailure("Unhandled event in DefaultPublisher: \(event) ")
            }
        }
    }

    private func callback(_ handler: @escaping SuccessHandler) {
        performOnMainThread(handler)
    }

    private func callback(error: Error, handler: @escaping ErrorHandler) {
        performOnMainThread { handler(error) }
    }

    private func callback(event: PublisherDelegateEvent) {
        logger.trace("Received delegate event: \(event)")
        performOnMainThread { [weak self] in
            guard let self = self,
                  let delegate = self.delegate
            else { return }

            switch event {
            case let event as DelegateErrorEvent: delegate.publisher(sender: self, didFailWithError: event.error)
            case let event as DelegateConnectionStateChangedEvent: delegate.publisher(sender: self, didChangeConnectionState: event.connectionState)
            case let event as DelegateRawLocationChangedEvent: delegate.publisher(sender: self, didUpdateRawLocation: event.location)
            case let event as DelegateEnhancedLocationChangedEvent: delegate.publisher(sender: self, didUpdateEnhancedLocation: event.location)
            default: preconditionFailure("Unhandled delegate event in DefaultPublisher: \(event) ")
            }
        }
    }

    // MARK: Track
    private func performTrackTrackableEvent(_ event: TrackTrackableEvent) {
        guard activeTrackable == nil else {
            let error =  AssetTrackingError.publisherError("For this preview version of the SDK, track() method may only be called once for any given instance of this class.")
            callback(error: error, handler: event.onError)
            return
        }

        self.ablyService.track(trackable: event.trackable) { [weak self] error in
            if let error = error {
                self?.callback(error: error, handler: event.onError)
                return
            }

            self?.enqueue(event: PresenceJoinedSuccessfullyEvent(
                            trackable: event.trackable,
                            onComplete: { [weak self] in
                                self?.enqueue(event: TrackableReadyToTrackEvent(trackable: event.trackable, onSuccess: event.onSuccess))
                            })
            )
        }
    }

    private func performTrackableReadyToTrack(_ event: TrackableReadyToTrackEvent) {
        if activeTrackable != event.trackable {
            activeTrackable = event.trackable
            hooks.trackables?.onActiveTrackableChanged(trackable: event.trackable)
            if let destination = event.trackable.destination {
                routeProvider.getRoute(
                    to: destination,
                    onSuccess: { [weak self] route in self?.enqueue(event: SetDestinationSuccessEvent(route: route)) },
                    onError: { error in logger.error("Can't fetch route. Error: \(error)") }
                )
            } else {
                self.route = nil
            }
        }
        callback(event.onSuccess)
    }

    private func performPresenceJoinedSuccessfullyEvent(_ event: PresenceJoinedSuccessfullyEvent) {
        locationService.startUpdatingLocation()
        resolveResolution(trackable: event.trackable)
        hooks.trackables?.onTrackableAdded(trackable: event.trackable)
        event.onComplete()
    }

    private func performSetDestinationSuccessEvent(_ event: SetDestinationSuccessEvent) {
        self.route = event.route
    }

    // MARK: Add/Remove trackable
    private func performAddTrackableEvent(_ event: AddTrackableEvent) {
        self.ablyService.track(trackable: event.trackable) { [weak self] error in
            if let error = error {
                self?.callback(error: error, handler: event.onError)
                return
            }
            self?.enqueue(event: PresenceJoinedSuccessfullyEvent(
                            trackable: event.trackable,
                            onComplete: { [weak self] in self?.callback(event.onSuccess) })
            )
        }
    }

    // MARK: Remove
    private func performRemoveTrackableEvent(_ event: RemoveTrackableEvent) {
        self.ablyService.stopTracking(trackable: event.trackable) { [weak self] wasPresent in
            if wasPresent {
                self?.enqueue(event: ClearRemovedTrackableMetadataEvent(trackable: event.trackable, onSuccess: event.onSuccess))
            } else {
                self?.callback({ event.onSuccess(false) })
            }
        } onError: { [weak self] error in
            self?.callback(error: error, handler: event.onError)
        }
    }

    private func performClearRemovedTrackableMetadataEvent(_ event: ClearRemovedTrackableMetadataEvent) {
        hooks.trackables?.onTrackableRemoved(trackable: event.trackable)
        removeAllSubscribers(forTrackable: event.trackable)
        resolutions.removeValue(forKey: event.trackable)
        requests.removeValue(forKey: event.trackable)
        lastRawLocations.removeValue(forKey: event.trackable)
        lastEnhancedLocations.removeValue(forKey: event.trackable)

        enqueue(event: ClearActiveTrackableEvent(trackable: event.trackable, onSuccess: event.onSuccess))
    }

    private func performClearActiveTrackableEvent(_ event: ClearActiveTrackableEvent) {
        if activeTrackable == event.trackable {
            activeTrackable = nil
            hooks.trackables?.onActiveTrackableChanged(trackable: nil)
            route = nil
        }
        if ablyService.trackables.isEmpty {
            locationService.stopUpdatingLocation()
        }
        callback { event.onSuccess(true) }
    }

    private func removeAllSubscribers(forTrackable trackable: Trackable) {
        guard let trackableSubscribers = subscribers[trackable],
              !trackableSubscribers.isEmpty
        else { return }
        trackableSubscribers.forEach {
            hooks.subscribers?.onSubscriberRemoved(subscriber: $0)
        }
        subscribers[trackable] = []
    }

    // MARK: Location change
    private func performEnhancedLocationChanged(_ event: EnhancedLocationChangedEvent) {
        let trackablesToSend = ablyService.trackables.filter { trackable -> Bool in
            return shouldSendLocation(location: event.location,
                                      lastLocation: lastEnhancedLocations[trackable],
                                      lastTimestamp: lastEnhancedTimestamps[trackable],
                                      resolution: resolutions[trackable])
        }

        trackablesToSend.forEach { trackable in
            lastEnhancedLocations[trackable] = event.location
            lastEnhancedTimestamps[trackable] = event.location.timestamp

            ablyService.sendEnhancedAssetLocation(location: event.location, forTrackable: trackable) { [weak self] error in
                if let error = error {
                    self?.callback(event: DelegateErrorEvent(error: error))
                }
            }
        }

        checkThreshold(location: event.location)
    }

    private func performRawLocationChanged(_ event: RawLocationChangedEvent) {
        let trackablesToSend = ablyService.trackables.filter { trackable -> Bool in
            return shouldSendLocation(location: event.location,
                                      lastLocation: lastRawLocations[trackable],
                                      lastTimestamp: lastRawTimestamps[trackable],
                                      resolution: resolutions[trackable])
        }

        trackablesToSend.forEach { trackable in
            lastRawLocations[trackable] = event.location
            lastRawTimestamps[trackable] = event.location.timestamp

            ablyService.sendRawAssetLocation(location: event.location, forTrackable: trackable) { [weak self] error in
                if let error = error {
                    self?.callback(event: DelegateErrorEvent(error: error))
                }
            }
        }

        checkThreshold(location: event.location)
    }

    private func shouldSendLocation(location: CLLocation,
                                    lastLocation: CLLocation?,
                                    lastTimestamp: Date?,
                                    resolution: Resolution?) -> Bool {
        guard let resolution = resolution,
              let lastLocation = lastLocation,
              let lastTimestamp = lastTimestamp
        else { return true }

        let distance = location.distance(from: lastLocation)
        let timeInterval = location.timestamp.timeIntervalSince1970 - lastTimestamp.timeIntervalSince1970

        // desiredInterval in resolution is in milliseconds, while timeInterval from timestamp is in seconds
        let desiredIntervalInSeconds = resolution.desiredInterval / 1000
        return distance >= resolution.minimumDisplacement || timeInterval >= desiredIntervalInSeconds
    }

    // MARK: ResolutionPolicy
    private func performRefreshResolutionPolicyEvent(_ event: RefreshResolutionPolicyEvent) {
        ablyService.trackables.forEach { resolveResolution(trackable: $0) }
    }

    private func resolveResolution(trackable: Trackable) {
        let currentRequests = requests[trackable]?.values
        let resolutionSet: Set<Resolution> = currentRequests == nil ? [] : Set(currentRequests!)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: resolutionSet)
        resolutions[trackable] = resolutionPolicy.resolve(request: request)
        enqueue(event: ChangeLocationEngineResolutionEvent())
    }

    private func performChangeLocationEngineResolutionEvent(_ event: ChangeLocationEngineResolutionEvent) {
        locationEngineResolution = resolutionPolicy.resolve(resolutions: Set(resolutions.values))
        changeLocationEngineResolution(resolution: locationEngineResolution)
    }

    private func changeLocationEngineResolution(resolution: Resolution) {
        locationService.changeLocationEngineResolution(resolution: resolution)
    }

    private func checkThreshold(location: CLLocation) {
        guard let threshold = proximityThreshold,
              let handler = proximityHandler
        else { return }

        let checker = ThresholdChecker()
        let destination = activeTrackable?.destination != nil ?
            CLLocation(latitude: activeTrackable!.destination!.latitude, longitude: activeTrackable!.destination!.longitude) : nil
        let estimatedArrivalTime = route?.expectedTravelTime == nil ? nil :
            route!.expectedTravelTime + Date().timeIntervalSince1970

        let isReached: Bool = checker.isThresholdReached(threshold: threshold,
                                                         currentLocation: location,
                                                         currentTime: Date().timeIntervalSince1970,
                                                         destination: destination,
                                                         estimatedArrivalTime: estimatedArrivalTime)
        if isReached {
            handler.onProximityReached(threshold: threshold)
        }
    }

    // MARK: Subscribers handling
    private func performPresenceUpdateEvent(_ event: PresenceUpdateEvent) {
        guard event.presenceData.type == .subscriber else { return }
        if event.presence == .enter {
            addSubscriber(clientId: event.clientId, trackable: event.trackable, data: event.presenceData)
        } else if event.presence == .leave {
            removeSubscriber(clientId: event.clientId, trackable: event.trackable)
        } else if event.presence == .update {
            updateSubscriber(clientId: event.clientId, trackable: event.trackable, data: event.presenceData)
        }
    }

    private func addSubscriber(clientId: String, trackable: Trackable, data: PresenceData) {
        let subscriber = Subscriber(id: clientId, trackable: trackable)
        var trackableSubscribers: Set<Subscriber> = subscribers[trackable] ?? []
        trackableSubscribers.insert(subscriber)
        subscribers[trackable] = trackableSubscribers
        saveOrRemoveResolutionRequest(resolution: data.resolution, trackable: trackable, subscriber: subscriber)
        hooks.subscribers?.onSubscriberAdded(subscriber: subscriber)
        resolveResolution(trackable: trackable)
    }

    private func updateSubscriber(clientId: String, trackable: Trackable, data: PresenceData) {
        guard let trackableSubscribers = subscribers[trackable],
              let subscriber = trackableSubscribers.first(where: { $0.id == clientId })
        else { return }
        saveOrRemoveResolutionRequest(resolution: data.resolution, trackable: trackable, subscriber: subscriber)
        resolveResolution(trackable: trackable)
    }

    private func removeSubscriber(clientId: String, trackable: Trackable) {
        guard var trackableSubscribers = subscribers[trackable],
              let subscriber = trackableSubscribers.first(where: { $0.id == clientId })
        else { return }

        trackableSubscribers.remove(subscriber)
        subscribers[trackable] = trackableSubscribers

        if var trackableRequests = requests[trackable] {
            trackableRequests.removeValue(forKey: subscriber)
            requests[trackable] = trackableRequests
        }

        hooks.subscribers?.onSubscriberRemoved(subscriber: subscriber)
        resolveResolution(trackable: trackable)
    }

    private func saveOrRemoveResolutionRequest(resolution: Resolution?, trackable: Trackable, subscriber: Subscriber) {
        var trackableRequests: [Subscriber: Resolution] = requests[trackable] ?? [:]
        trackableRequests[subscriber] = resolution
        requests[trackable] = trackableRequests
    }

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workingQueue.async(execute: operation)
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }
}

// MARK: LocationServiceDelegate
extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        logger.error("locationService.didFailWithError. Error: \(error)", source: "DefaultPublisher")
        callback(event: DelegateErrorEvent(error: error))
    }

    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        logger.debug("locationService.didUpdateRawLocation.", source: "DefaultPublisher")
        enqueue(event: RawLocationChangedEvent(location: location))
        callback(event: DelegateRawLocationChangedEvent(location: location))
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        logger.debug("locationService.didUpdateEnhancedLocation.", source: "DefaultPublisher")
        enqueue(event: EnhancedLocationChangedEvent(location: location))
        callback(event: DelegateEnhancedLocationChangedEvent(location: location))
    }
}

// MARK: AblyPublisherServiceDelegate
extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisherService, didFailWithError error: Error) {
        logger.error("publisherService.didFailWithError. Error: \(error)", source: "DefaultPublisher")
        callback(event: DelegateErrorEvent(error: error))
    }

    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState) {
        logger.debug("publisherService.didChangeConnectionState. State: \(state)", source: "DefaultPublisher")
        callback(event: DelegateConnectionStateChangedEvent(connectionState: state))
    }

    func publisherService(sender: AblyPublisherService,
                          didReceivePresenceUpdate presence: AblyPublisherPresence,
                          forTrackable trackable: Trackable,
                          presenceData: PresenceData,
                          clientId: String) {
        logger.error("publisherService.didReceivePresenceUpdate. Presence: \(presence), Trackable: \(trackable)",
                     source: "DefaultPublisher")
        enqueue(event: PresenceUpdateEvent(trackable: trackable, presence: presence, presenceData: presenceData, clientId: clientId))
    }
}

// MARK: ResolutionPolicyMethodsDelegate
extension DefaultPublisher: DefaultResolutionPolicyMethodsDelegate {
    func resolutionPolicyMethods(refreshWithSender sender: DefaultResolutionPolicyMethods) {
        enqueue(event: RefreshResolutionPolicyEvent())
    }

    func resolutionPolicyMethods(cancelProximityThresholdWithSender sender: DefaultResolutionPolicyMethods) {
        proximityHandler?.onProximityCancelled()
    }

    func resolutionPolicyMethods(sender: DefaultResolutionPolicyMethods,
                                 setProximityThreshold threshold: Proximity,
                                 withHandler handler: ProximityHandler) {
        self.proximityHandler = handler
        self.proximityThreshold = threshold
    }
}
