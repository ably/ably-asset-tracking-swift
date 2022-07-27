import UIKit
import CoreLocation
import Logging
import MapboxDirections
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

// Default logger used in Publisher SDK
let logger: Logger = Logger(label: "com.ably.tracking.Publisher")

class DefaultPublisher: Publisher {
    
    // Publisher state
    private enum State {
        case working
        case stopping
        case stopped

        var isStoppingOrStopped: Bool {
            self == .stopping || self == .stopped
        }
    }
    
    private let workingQueue: DispatchQueue
    private let connectionConfiguration: ConnectionConfiguration
    private let mapboxConfiguration: MapboxConfiguration
    private let logConfiguration: LogConfiguration
    private let locationService: LocationService
    private let resolutionPolicy: ResolutionPolicy
    private let routeProvider: RouteProvider
    private let batteryLevelProvider: BatteryLevelProvider
    private let isSendResolutionEnabled: Bool
    
    private var ablyPublisher: AblyPublisher
    private var enhancedLocationState: TrackableState<EnhancedLocationUpdate>
    private var rawLocationState: TrackableState<RawLocationUpdate>
    private var state: State = .working
    private var presenceData: PresenceData
    private var areRawLocationsEnabled: Bool

    // ResolutionPolicy
    private let hooks: DefaultResolutionPolicyHooks
    private let methods: DefaultResolutionPolicyMethods
    private var proximityThreshold: Proximity?
    private var proximityHandler: ProximityHandler?
    private var requests: [Trackable: [Subscriber: Resolution]]
    private var subscribers: [Trackable: Set<Subscriber>]
    private var resolutions: [Trackable: Resolution]
    private var locationEngineResolution: Resolution
    private var trackables: Set<Trackable>
    private var constantLocationEngineResolution: Resolution?

    private var lastEnhancedLocations: [Trackable: Location]
    private var lastEnhancedTimestamps: [Trackable: Double]
    private var lastRawLocations: [Trackable: Location]
    private var lastRawTimestamps: [Trackable: Double]
    private var route: Route?

    private var receivedAblyClientConnectionState: ConnectionState = .offline
    private var receivedAblyChannelsConnectionStates: [Trackable: ConnectionState] = [:]
    private var currentTrackablesConnectionStates: [Trackable: ConnectionState] = [:]

    public weak var delegate: PublisherDelegate?
    private(set) public var activeTrackable: Trackable?
    private(set) public var routingProfile: RoutingProfile

    init(connectionConfiguration: ConnectionConfiguration,
         mapboxConfiguration: MapboxConfiguration,
         logConfiguration: LogConfiguration,
         routingProfile: RoutingProfile,
         resolutionPolicyFactory: ResolutionPolicyFactory,
         ablyPublisher: AblyPublisher,
         locationService: LocationService,
         routeProvider: RouteProvider,
         enhancedLocationState: TrackableState<EnhancedLocationUpdate> = TrackableState(),
         rawLocationState: TrackableState<RawLocationUpdate> = TrackableState(),
         areRawLocationsEnabled: Bool = false,
         isSendResolutionEnabled: Bool = true,
         constantLocationEngineResolution: Resolution? = nil
    ) {
        
        self.connectionConfiguration = connectionConfiguration
        self.mapboxConfiguration = mapboxConfiguration
        self.logConfiguration = logConfiguration
        self.routingProfile = routingProfile
        self.workingQueue = DispatchQueue(label: "io.ably.asset-tracking.Publisher.DefaultPublisher", qos: .default)
        self.locationService = locationService
        self.ablyPublisher = ablyPublisher
        self.routeProvider = routeProvider
        self.enhancedLocationState = enhancedLocationState
        self.rawLocationState = rawLocationState

        self.batteryLevelProvider = DefaultBatteryLevelProvider()

        self.isSendResolutionEnabled = isSendResolutionEnabled
        self.areRawLocationsEnabled = areRawLocationsEnabled
        self.constantLocationEngineResolution = constantLocationEngineResolution
        self.presenceData = PresenceData(type: .publisher, rawLocations: areRawLocationsEnabled)
        self.hooks = DefaultResolutionPolicyHooks()
        self.methods = DefaultResolutionPolicyMethods()
        self.resolutionPolicy = resolutionPolicyFactory.createResolutionPolicy(hooks: hooks, methods: methods)
        self.locationEngineResolution = resolutionPolicy.resolve(resolutions: [])

        self.requests = [:]
        self.subscribers = [:]
        self.resolutions = [:]
        self.lastEnhancedLocations = [:]
        self.lastEnhancedTimestamps = [:]
        self.lastRawLocations = [:]
        self.lastRawTimestamps = [:]
        self.trackables = []

        self.ablyPublisher.publisherDelegate = self
        self.locationService.delegate = self
        self.methods.delegate = self
        
        self.ablyPublisher.subscribeForAblyStateChange()
        
        /**
         If available, set `constantLocationEngineResolution` for the `LocationService`.
         In this case all further resolution calculations are disabled.
         */
        if let resolution = constantLocationEngineResolution {
            locationService.changeLocationEngineResolution(resolution: resolution)
        }
    }

    func track(trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        let event = TrackTrackableEvent(trackable: trackable,
                                        resultHandler: completion)
        enqueue(event: event)
    }

    func add(trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        let event = AddTrackableEvent(trackable: trackable, resultHandler: completion)
        enqueue(event: event)
    }

    func remove(trackable: Trackable, completion: @escaping ResultHandler<Bool>) {
         let event = RemoveTrackableEvent(trackable: trackable, resultHandler: completion)
         enqueue(event: event)
    }

    func changeRoutingProfile(profile: RoutingProfile, completion: @escaping ResultHandler<Void>) {
        let event = ChangeRoutingProfileEvent(profile: profile, resultHandler: completion)
        enqueue(event: event)
    }

    func stop(completion: @escaping ResultHandler<Void>) {
        enqueue(event: StopEvent(resultHandler: completion))
    }
}

// MARK: Threading events handling
extension DefaultPublisher {
    private func enqueue(event: PublisherEvent) {
        logger.trace("Received event: \(event)")
        performOnWorkingThread { [weak self] in
            switch event {
            case let event as TrackTrackableEvent: self?.performTrackTrackableEvent(event)
            case let event as PresenceJoinedSuccessfullyEvent: self?.performPresenceJoinedSuccessfullyEvent(event)
            case let event as TrackableReadyToTrackEvent: self?.performTrackableReadyToTrack(event)
            case let event as EnhancedLocationChangedEvent: self?.performEnhancedLocationChanged(event)
            case let event as SendEnhancedLocationSuccessEvent: self?.performSendEnhancedLocationSuccess(event)
            case let event as SendEnhancedLocationFailureEvent: self?.performSendEnhancedLocationFailure(event)
            case let event as RawLocationChangedEvent: self?.performRawLocationChanged(event)
            case let event as SendRawLocationSuccessEvent: self?.performSendRawLocationSuccess(event)
            case let event as SendRawLocationFailureEvent: self?.performSendRawLocationFailure(event)
            case let event as AddTrackableEvent: self?.performAddTrackableEvent(event)
            case let event as RemoveTrackableEvent: self?.performRemoveTrackableEvent(event)
            case let event as ClearActiveTrackableEvent: self?.performClearActiveTrackableEvent(event)
            case let event as RefreshResolutionPolicyEvent: self?.performRefreshResolutionPolicyEvent(event)
            case let event as ChangeLocationEngineResolutionEvent: self?.performChangeLocationEngineResolutionEvent(event)
            case let event as PresenceUpdateEvent: self?.performPresenceUpdateEvent(event)
            case let event as ClearRemovedTrackableMetadataEvent: self?.performClearRemovedTrackableMetadataEvent(event)
            case let event as SetDestinationSuccessEvent: self?.performSetDestinationSuccessEvent(event)
            case let event as DelegateResolutionUpdateEvent: self?.notifyDelegateResolutionUpdate(event)
            case let event as DelegateErrorEvent: self?.notifyDelegateDidFailWithError(event.error)
            case let event as DelegateTrackableConnectionStateChangedEvent: self?.notifyDelegateConnectionStateChanged(event)
            case let event as DelegateEnhancedLocationChangedEvent: self?.notifyDelegateEnhancedLocationChanged(event)
            case let event as ChangeRoutingProfileEvent: self?.performChangeRoutingProfileEvent(event)
            case let event as StopEvent: self?.performStopPublisherEvent(event)
            case let event as AblyConnectionClosedEvent: self?.performAblyConnectionClosedEvent(event)
            case let event as AblyClientConnectionStateChangedEvent: self?.performAblyClientConnectionChangedEvent(event)
            case let event as AblyChannelConnectionStateChangedEvent: self?.performAblyChannelConnectionStateChangedEvent(event)
            default: preconditionFailure("Unhandled event in DefaultPublisher: \(event) ")
            }
        }
    }

    private func callback<T: Any>(value: T, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.success(value)) }
    }

    private func callback<T: Any>(error: ErrorInformation, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.failure(error)) }
    }

    private func publisherStoppedCallback<T: Any>(handler: @escaping ResultHandler<T>) {
        let error = ErrorInformation(type: .publisherStoppedException)
        performOnMainThread { handler(.failure(error)) }
    }

    private func callback(event: PublisherDelegateEvent) {
        logger.trace("Received delegate event: \(event)")

        performOnMainThread { [weak self] in
            guard let self = self
            else { return }

            switch event {
            case let event as DelegateErrorEvent:
                self.delegate?.publisher(sender: self, didFailWithError: event.error)
            case let event as DelegateTrackableConnectionStateChangedEvent:
                self.delegate?.publisher(sender: self, didChangeConnectionState: event.connectionState, forTrackable: event.trackable)
            case let event as DelegateEnhancedLocationChangedEvent:
                self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: event.locationUpdate)
            default: preconditionFailure("Unhandled delegate event in DefaultPublisher: \(event) ")
            }
        }
    }

    // MARK: Track
    private func performTrackTrackableEvent(_ event: TrackTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        guard !trackables.contains(event.trackable) else {
            enqueue(event: TrackableReadyToTrackEvent(trackable: event.trackable, resultHandler: event.resultHandler))
            return
        }

        ablyPublisher.connect(
            trackableId: event.trackable.id,
            presenceData: presenceData,
            useRewind: false
        ) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: PresenceJoinedSuccessfullyEvent(trackable: event.trackable) { [weak self] result in
                    switch result {
                    case .success:
                        self?.enqueue(event: TrackableReadyToTrackEvent(trackable: event.trackable, resultHandler: event.resultHandler))
                    default:
                        return
                    }
                })
            case .failure(let error):
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    private func performTrackableReadyToTrack(_ event: TrackableReadyToTrackEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        if activeTrackable != event.trackable {
            activeTrackable = event.trackable
            hooks.trackables?.onActiveTrackableChanged(trackable: event.trackable)
            if let destination = event.trackable.destination {
                routeProvider.getRoute(to: destination.toCoreLocationCoordinate2d(), withRoutingProfile: routingProfile) { [weak self] result in
                    switch result {
                    case .success(let route):
                        self?.enqueue(event: SetDestinationSuccessEvent(route: route))
                    case .failure(let error):
                        logger.error("Can't fetch route. Error: \(error.message)")
                        event.resultHandler(.failure(error))
                    }
                }
            } else {
                self.route = nil
            }
        }

        callback(value: Void(), handler: event.resultHandler)
    }

    private func performPresenceJoinedSuccessfullyEvent(_ event: PresenceJoinedSuccessfullyEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        ablyPublisher.subscribeForPresenceMessages(trackable: event.trackable)
        ablyPublisher.subscribeForChannelStateChange(trackable: event.trackable)
        
        trackables.insert(event.trackable)
        locationService.startUpdatingLocation()
        resolveResolution(trackable: event.trackable)
        hooks.trackables?.onTrackableAdded(trackable: event.trackable)
        event.resultHandler(.success)
    }

    // MARK: RoutingProfile
    private func performChangeRoutingProfileEvent(_ event: ChangeRoutingProfileEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        routeProvider.changeRoutingProfile(to: routingProfile) { [weak self] result in
            switch result {
            case .success(let route):
                self?.routingProfile = event.profile
                self?.enqueue(event: SetDestinationSuccessEvent(route: route))
                self?.callback(value: Void(), handler: event.resultHandler)
            case .failure(let error):
                logger.error("Can't change RoutingProfile. Error: \(error)")
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    // MARK: Destination
    private func performSetDestinationSuccessEvent(_ event: SetDestinationSuccessEvent) {
        self.route = event.route
    }

    // MARK: Add trackable
    private func performAddTrackableEvent(_ event: AddTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        guard !trackables.contains(event.trackable) else {
            let error = ErrorInformation(type: .trackableAlreadyExist(trackableId: event.trackable.id))
            callback(error: error, handler: event.resultHandler)
            return
        }
     
     
        ablyPublisher.connect(
            trackableId: event.trackable.id,
            presenceData: presenceData,
            useRewind: false
        ) { [weak self] result in
     
            switch result {
            case .success:
                self?.enqueue(event: PresenceJoinedSuccessfullyEvent(trackable: event.trackable) { [weak self] _ in
                    self?.callback(value: Void(), handler: event.resultHandler)
                })
            case .failure(let error):
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    // MARK: Remove trackable
    private func performRemoveTrackableEvent(_ event: RemoveTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }
        
        self.ablyPublisher.disconnect(
            trackableId: event.trackable.id,
            presenceData: presenceData
        ) { [weak self] result in
            
            switch result {
            case .success(let wasPresent):
                self?.enhancedLocationState.remove(trackableId: event.trackable.id)
                wasPresent
                    ? self?.enqueue(event: ClearRemovedTrackableMetadataEvent(trackable: event.trackable, resultHandler: event.resultHandler))
                    : self?.callback(value: false, handler: event.resultHandler)
            case .failure(let error):
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    // MARK: Stop publisher
    private func performStopPublisherEvent(_ event: StopEvent) {
        if state.isStoppingOrStopped {
            callback(value: Void(), handler: event.resultHandler)
            return
        }

        state = .stopping

        ablyPublisher.close(presenceData: presenceData) { [weak self] result in
            switch result {
            case .success:
                self?.locationService.stopUpdatingLocation()
                self?.enqueue(event: AblyConnectionClosedEvent(resultHandler: event.resultHandler))
            case .failure(let error):
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    private func performAblyConnectionClosedEvent(_ event: AblyConnectionClosedEvent) {
        state = .stopped
        enhancedLocationState.removeAll()
        rawLocationState.removeAll()
        callback(value: Void(), handler: event.resultHandler)
    }

    private func performAblyClientConnectionChangedEvent(_ event: AblyClientConnectionStateChangedEvent) {
        receivedAblyClientConnectionState = event.connectionState
        trackables.forEach {
            handleConnectionStateChange(forTrackable: $0)
        }
    }

    private func performAblyChannelConnectionStateChangedEvent(_ event: AblyChannelConnectionStateChangedEvent) {
        receivedAblyChannelsConnectionStates[event.trackable] = event.connectionState
        handleConnectionStateChange(forTrackable: event.trackable)
    }

    private func handleConnectionStateChange(forTrackable trackable: Trackable) {
        var newTrackableState: ConnectionState = .offline
        let channelConnectionState = receivedAblyChannelsConnectionStates[trackable] ?? .offline

        switch receivedAblyClientConnectionState {
        case .online:
            switch channelConnectionState {
            case .online:
                newTrackableState = hasSentAtLeastOneLocation(forTrackable: trackable)
                    ? .online
                    : .offline
            case .offline:
                newTrackableState = .offline
            case .failed:
                newTrackableState = .failed
            }
        case .offline:
            newTrackableState = .offline
        case .failed:
            newTrackableState = .failed
        }

        if newTrackableState != currentTrackablesConnectionStates[trackable] {
            currentTrackablesConnectionStates[trackable] = newTrackableState
            callback(event: DelegateTrackableConnectionStateChangedEvent(trackable: trackable, connectionState: newTrackableState))
        }
    }

    private func hasSentAtLeastOneLocation(forTrackable trackable: Trackable) -> Bool {
        return lastEnhancedLocations[trackable] != nil
    }

    private func performClearRemovedTrackableMetadataEvent(_ event: ClearRemovedTrackableMetadataEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        trackables.remove(event.trackable)
        hooks.trackables?.onTrackableRemoved(trackable: event.trackable)
        removeAllSubscribers(forTrackable: event.trackable)
        resolutions.removeValue(forKey: event.trackable)
        requests.removeValue(forKey: event.trackable)
        lastEnhancedLocations.removeValue(forKey: event.trackable)
        lastRawLocations.removeValue(forKey: event.trackable)

        enqueue(event: ClearActiveTrackableEvent(trackable: event.trackable, resultHandler: event.resultHandler))
    }

    private func performClearActiveTrackableEvent(_ event: ClearActiveTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            publisherStoppedCallback(handler: event.resultHandler)
            return
        }

        if activeTrackable == event.trackable {
            activeTrackable = nil
            hooks.trackables?.onActiveTrackableChanged(trackable: nil)
            route = nil
        }

        if trackables.isEmpty {
            locationService.stopUpdatingLocation()
        }

        callback(value: true, handler: event.resultHandler)
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
        guard !state.isStoppingOrStopped else {
            logger.error("Cannot perform EnhancedLocationChangedEvent. Publisher is not working.")
            return
        }

        let trackablesToSend = trackables.filter { trackable in
            guard !enhancedLocationState.hasPendingMessage(for: trackable.id) else {
                enhancedLocationState.addToWaiting(locationUpdate: event.locationUpdate, for: trackable.id)
                return false
            }
            
            let shouldSend = shouldSendLocation(
                location: event.locationUpdate.location,
                lastLocation: lastEnhancedLocations[trackable],
                lastTimestamp: lastEnhancedTimestamps[trackable],
                resolution: resolutions[trackable]
            )
            
            if !shouldSend {
                enhancedLocationState.addLocation(for: trackable.id, location: event.locationUpdate)
            }
            
            return shouldSend
        }

        trackablesToSend.forEach { trackable in
            sendEnhancedLocationUpdate(event: event, trackable: trackable)
        }

        checkThreshold(location: event.locationUpdate.location)
    }
    
    private func processNextWaitingEnhancedLocationUpdate(for trackableId: String) {
        guard let enhancedLocationUpdate = enhancedLocationState.nextWaitingLocation(for: trackableId) else {
            return
        }
        
        performEnhancedLocationChanged(EnhancedLocationChangedEvent(locationUpdate: enhancedLocationUpdate))
    }
    
    private func processNextWaitingRawLocationUpdate(for trackableId: String) {
        guard let rawLocationUpdate = rawLocationState.nextWaitingLocation(for: trackableId) else {
            return
        }
        
        performRawLocationChanged(RawLocationChangedEvent(locationUpdate: rawLocationUpdate))
    }
    
    private func sendEnhancedLocationUpdate(event: EnhancedLocationChangedEvent, trackable: Trackable) {
        lastEnhancedLocations[trackable] = event.locationUpdate.location
        lastEnhancedTimestamps[trackable] = event.locationUpdate.location.timestamp
        
        event.locationUpdate.skippedLocations = enhancedLocationState.locationsList(for: trackable.id).map { $0.location }

        enhancedLocationState.markMessageAsPending(for: trackable.id)
        
        ablyPublisher.sendEnhancedLocation(locationUpdate: event.locationUpdate, trackable: trackable) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.enqueue(event: SendEnhancedLocationFailureEvent(error: error, locationUpdate: event.locationUpdate, trackable: trackable))
            case .success:
                self?.enqueue(event: SendEnhancedLocationSuccessEvent(trackable: trackable, location: event.locationUpdate.location))
            }
        }
    }
    
    private func sendRawLocationUpdate(event: RawLocationChangedEvent, trackable: Trackable) {        
        lastRawLocations[trackable] = event.locationUpdate.location
        lastRawTimestamps[trackable] = event.locationUpdate.location.timestamp

        event.locationUpdate.skippedLocations = rawLocationState.locationsList(for: trackable.id).map { $0.location }

        rawLocationState.markMessageAsPending(for: trackable.id)

        ablyPublisher.sendRawLocation(location: event.locationUpdate, trackable: trackable) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.enqueue(event: SendRawLocationFailureEvent(error: error, locationUpdate: event.locationUpdate, trackable: trackable))
            case .success:
                self?.enqueue(event: SendRawLocationSuccessEvent(trackable: trackable, location: event.locationUpdate.location))
            }
        }
    }
    
    private func saveEnhancedLocationForFurtherSending(trackableId: String, location: EnhancedLocationUpdate) {
        enhancedLocationState.addLocation(for: trackableId, location: location)
    }
    
    private func saveRawLocationForFurtherSending(trackableId: String, location: RawLocationUpdate) {
        rawLocationState.addLocation(for: trackableId, location: location)
    }
    
    private func performRawLocationChanged(_ event: RawLocationChangedEvent) {
        guard !state.isStoppingOrStopped else {
            logger.error("Cannot perform EnhancedLocationChangedEvent. Publisher is not working.")
            return
        }
        
        guard areRawLocationsEnabled == true else {
            return
        }

        let trackablesToSend = trackables.filter { trackable in
            guard !rawLocationState.hasPendingMessage(for: trackable.id) else {
                rawLocationState.addToWaiting(locationUpdate: event.locationUpdate, for: trackable.id)
                return false
            }
            
            let shouldSend = shouldSendLocation(
                location: event.locationUpdate.location,
                lastLocation: lastRawLocations[trackable],
                lastTimestamp: lastRawTimestamps[trackable],
                resolution: resolutions[trackable]
            )
            
            if !shouldSend {
                rawLocationState.addLocation(for: trackable.id, location: event.locationUpdate)
            }
            
            return shouldSend
        }

        trackablesToSend.forEach { trackable in
            sendRawLocationUpdate(event: event, trackable: trackable)
        }
    }
    
    private func performSendRawLocationSuccess(_ event: SendRawLocationSuccessEvent) {
        rawLocationState.unmarkMessageAsPending(for: event.trackable.id)
        rawLocationState.clearLocation(for: event.trackable.id)
        rawLocationState.resetRetryCounter(for: event.trackable.id)
        processNextWaitingRawLocationUpdate(for: event.trackable.id)
    }
    
    private func performSendRawLocationFailure(_ event: SendRawLocationFailureEvent) {
        guard rawLocationState.shouldRetry(trackableId: event.trackable.id) else {
            rawLocationState.unmarkMessageAsPending(for: event.trackable.id)
            saveRawLocationForFurtherSending(trackableId: event.trackable.id, location: event.locationUpdate)
            callback(event: DelegateErrorEvent(error: event.error))
            processNextWaitingRawLocationUpdate(for: event.trackable.id)
            return
        }
        
        retrySendingRawLocation(
            trackable: event.trackable,
            locationUpdate: event.locationUpdate
        )
    }
    
    private func performSendEnhancedLocationSuccess(_ event: SendEnhancedLocationSuccessEvent) {
        enhancedLocationState.unmarkMessageAsPending(for: event.trackable.id)
        enhancedLocationState.clearLocation(for: event.trackable.id)
        enhancedLocationState.resetRetryCounter(for: event.trackable.id)
        processNextWaitingEnhancedLocationUpdate(for: event.trackable.id)
    }
    
    private func performSendEnhancedLocationFailure(_ event: SendEnhancedLocationFailureEvent) {
        guard enhancedLocationState.shouldRetry(trackableId: event.trackable.id) else {
            enhancedLocationState.unmarkMessageAsPending(for: event.trackable.id)
            saveEnhancedLocationForFurtherSending(trackableId: event.trackable.id, location: event.locationUpdate)
            callback(event: DelegateErrorEvent(error: event.error))
            processNextWaitingEnhancedLocationUpdate(for: event.trackable.id)
            return
        }
        
        retrySendingEnhancedLocation(
            trackable: event.trackable,
            locationUpdate: event.locationUpdate
        )
    }
    
    private func retrySendingEnhancedLocation(trackable: Trackable, locationUpdate: EnhancedLocationUpdate) {
        enhancedLocationState.incrementRetryCounter(for: trackable.id)
        
        sendEnhancedLocationUpdate(
            event: EnhancedLocationChangedEvent(locationUpdate: locationUpdate),
            trackable: trackable
        )
    }
    
    private func retrySendingRawLocation(trackable: Trackable, locationUpdate: RawLocationUpdate) {
        rawLocationState.incrementRetryCounter(for: trackable.id)
        
        sendRawLocationUpdate(
            event: RawLocationChangedEvent(locationUpdate: locationUpdate),
            trackable: trackable
        )
    }

    private func shouldSendLocation(location: Location,
                                    lastLocation: Location?,
                                    lastTimestamp: Double?,
                                    resolution: Resolution?) -> Bool {
        guard let resolution = resolution,
              let lastLocation = lastLocation,
              let lastTimestamp = lastTimestamp
        else { return true }

        let distance = location.distance(from: lastLocation)
        let timeInterval = location.timestamp - lastTimestamp

        // desiredInterval in resolution is in milliseconds, while timeInterval from timestamp is in seconds
        let desiredIntervalInSeconds = resolution.desiredInterval / 1000
        return distance >= resolution.minimumDisplacement || timeInterval >= desiredIntervalInSeconds
    }

    // MARK: ResolutionPolicy
    private func performRefreshResolutionPolicyEvent(_ event: RefreshResolutionPolicyEvent) {
        guard !state.isStoppingOrStopped else {
            logger.error("Cannot perform RefreshResolutionPolicyEvent. Publisher is not working.")
            return
        }

        trackables.forEach {
            resolveResolution(trackable: $0)
        }
    }

    private func resolveResolution(trackable: Trackable) {
        let currentRequests = requests[trackable]?.values
        let resolutionSet: Set<Resolution> = currentRequests == nil ? [] : Set(currentRequests!)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: resolutionSet)
        let resolution = resolutionPolicy.resolve(request: request)
        resolutions[trackable] = resolution
        enqueue(event: ChangeLocationEngineResolutionEvent())
        if isSendResolutionEnabled {
            ablyPublisher.updatePresenceData(trackableId: trackable.id, presenceData: presenceData.copy(with: resolution), completion: nil)
        }
    }

    private func performChangeLocationEngineResolutionEvent(_ event: ChangeLocationEngineResolutionEvent) {
        locationEngineResolution = resolutionPolicy.resolve(resolutions: Set(resolutions.values))
        changeLocationEngineResolution(resolution: locationEngineResolution)
    }

    private func changeLocationEngineResolution(resolution: Resolution) {
        guard !state.isStoppingOrStopped else {
            logger.error("Cannot perform changeLocationEngineResolution. Publisher is not working.")
            return
        }
        
        if constantLocationEngineResolution == nil {
            locationService.changeLocationEngineResolution(resolution: resolution)
        }
        
        enqueue(event: DelegateResolutionUpdateEvent(resolution: resolution))
    }

    private func checkThreshold(location: Location) {
        guard let threshold = proximityThreshold,
              let handler = proximityHandler
        else { return }

        let checker = ThresholdChecker()
        let destination = activeTrackable?.destination != nil ?
        CLLocation(latitude: activeTrackable!.destination!.latitude, longitude: activeTrackable!.destination!.longitude).toLocation() : nil
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
        guard !state.isStoppingOrStopped else {
            logger.error("Cannot perform PresenceUpdateEvent. Publisher is not working.")
            return
        }

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

    // MARK: Delegate
    private func notifyDelegateDidFailWithError(_ error: ErrorInformation) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didFailWithError: error)
        }
    }

    private func notifyDelegateEnhancedLocationChanged(_ event: DelegateEnhancedLocationChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: event.locationUpdate)
        }
    }

    private func notifyDelegateConnectionStateChanged(_ event: DelegateTrackableConnectionStateChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didChangeConnectionState: event.connectionState, forTrackable: event.trackable)
        }
    }

    private func notifyDelegateResolutionUpdate(_ event: DelegateResolutionUpdateEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.publisher(sender: self, didUpdateResolution: event.resolution)
        }
    }
}

// MARK: LocationServiceDelegate
extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: ErrorInformation) {
        logger.error("locationService.didFailWithError. Error: \(error.message)", source: "DefaultPublisher")
        callback(event: DelegateErrorEvent(error: error))
    }

    func locationService(sender: LocationService, didUpdateRawLocationUpdate locationUpdate: RawLocationUpdate) {
        logger.debug("locationService.didUpdateRawLocation.", source: String(describing: Self.self))
        enqueue(event: RawLocationChangedEvent(locationUpdate: locationUpdate))
    }
    
    func locationService(sender: LocationService, didUpdateEnhancedLocationUpdate locationUpdate: EnhancedLocationUpdate) {
        logger.debug("locationService.didUpdateEnhancedLocation.", source: String(describing: Self.self))
        enqueue(event: EnhancedLocationChangedEvent(locationUpdate: locationUpdate))
        callback(event: DelegateEnhancedLocationChangedEvent(locationUpdate: locationUpdate))
    }
}

// MARK: AblyPublisherServiceDelegate
extension DefaultPublisher: AblyPublisherServiceDelegate {
    func publisherService(sender: AblyPublisher, didChangeChannelConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        logger.debug("publisherService.didChangeChannelConnectionState. State: \(state) for trackable: \(trackable.id)", source: String(describing: Self.self))
        enqueue(event: AblyChannelConnectionStateChangedEvent(trackable: trackable, connectionState: state))
    }

    func publisherService(sender: AblyPublisher, didFailWithError error: ErrorInformation) {
        logger.error("publisherService.didFailWithError. Error: \(error.message)", source: "DefaultPublisher")
        callback(event: DelegateErrorEvent(error: error))
    }

    func publisherService(sender: AblyPublisher, didChangeConnectionState state: ConnectionState) {
        logger.debug("publisherService.didChangeConnectionState. State: \(state.description)", source: String(describing: Self.self))
        enqueue(event: AblyClientConnectionStateChangedEvent(connectionState: state))
    }

    func publisherService(sender: AblyPublisher,
                          didReceivePresenceUpdate presence: Presence,
                          forTrackable trackable: Trackable,
                          presenceData: PresenceData,
                          clientId: String) {
        logger.debug("publisherService.didReceivePresenceUpdate. Presence: \(presence), Trackable: \(trackable)",
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
