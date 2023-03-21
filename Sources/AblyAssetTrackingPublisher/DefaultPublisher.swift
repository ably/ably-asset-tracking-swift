import UIKit
import CoreLocation
import MapboxDirections
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

class DefaultPublisher: Publisher, PublisherInteractor {

    private let workerQueue: WorkerQueue<PublisherWorkerQueueProperties, PublisherWorkSpecification>
    private let locationService: LocationService
    private let resolutionPolicy: ResolutionPolicy
    private let routeProvider: RouteProvider
    private let batteryLevelProvider: BatteryLevelProvider
    private let isSendResolutionEnabled: Bool

    private var ablyPublisher: AblyPublisher
    private var enhancedLocationState: TrackableState<EnhancedLocationUpdate>
    private var rawLocationState: TrackableState<RawLocationUpdate>
    private var state: PublisherState = .idle
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
    private var trackables: Set<Trackable> {
        didSet {
            notifyTrackablesChanged(trackables: trackables)
        }
    }

    private var constantLocationEngineResolution: Resolution?

    private var lastEnhancedLocations: [Trackable: Location]
    private var lastEnhancedTimestamps: [Trackable: Double]
    private var lastRawLocations: [Trackable: Location]
    private var lastRawTimestamps: [Trackable: Double]
    private var route: Route?

    private var logHandler: InternalLogHandler?

    private var receivedAblyClientConnectionState: ConnectionState = .offline
    private var receivedAblyChannelsConnectionStates: [Trackable: ConnectionState] = [:]
    private var currentTrackablesConnectionStates: [Trackable: ConnectionState] = [:]

    private var duplicateTrackableGuard = DuplicateTrackableGuard()

    public weak var delegate: PublisherDelegate?
    private(set) public var activeTrackable: Trackable?
    private(set) public var routingProfile: RoutingProfile

    init(routingProfile: RoutingProfile,
         resolutionPolicyFactory: ResolutionPolicyFactory,
         ablyPublisher: AblyPublisher,
         locationService: LocationService,
         routeProvider: RouteProvider,
         enhancedLocationState: TrackableState<EnhancedLocationUpdate> = TrackableState(),
         rawLocationState: TrackableState<RawLocationUpdate> = TrackableState(),
         areRawLocationsEnabled: Bool = false,
         isSendResolutionEnabled: Bool = true,
         constantLocationEngineResolution: Resolution? = nil,
         logHandler: InternalLogHandler?
    ) {
        self.routingProfile = routingProfile
        self.logHandler = logHandler?.addingSubsystem(Self.self)
        self.workerQueue = WorkerQueue(
            properties: PublisherWorkerQueueProperties(),
            workingQueue: DispatchQueue(label: "io.ably.asset-tracking.Publisher", qos: .default),
            logHandler: self.logHandler,
            workerFactory: PublisherWorkerFactory(),
            asyncWorkWorkingQueue: DispatchQueue(label: "io.ably.asset-tracking.Publisher.async", qos: .default),
            getStoppedError: { return ErrorInformation(type: .publisherStoppedException) }
        )
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

    func track(trackable: Trackable, completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "track(trackable: \(trackable))")
        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .trackTrackable(.init(trackable: trackable, completion: completion)))
    }

    func add(trackable: Trackable, completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "add(trackable: \(trackable))")
        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .addTrackable(.init(trackable: trackable, completion: completion)))
    }

    func remove(trackable: Trackable, completion publicCompletion: @escaping ResultHandler<Bool>) {
        logHandler?.logPublicAPICall(label: "remove(trackable: \(trackable))")
        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .removeTrackable(.init(trackable: trackable, completion: completion)))
    }

    func changeRoutingProfile(profile: RoutingProfile, completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "changeRoutingProfile(profile: \(profile))")
        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .changeRoutingProfile(.init(profile: profile, completion: completion)))
    }

    func stop(completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "stop()")
        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .stop(.init(completion: completion)))
    }
}

// MARK: Threading events handling
extension DefaultPublisher {
    private func enqueue(event: Event) {
        logHandler?.verbose(message: "Received event: \(event)", error: nil)
        performOnWorkingQueue { [weak self] in
            switch event {
            case .trackTrackable(let event): self?.performTrackTrackableEvent(event)
            case .presenceJoinedSuccessfully(let event): self?.performPresenceJoinedSuccessfullyEvent(event)
            case .trackableReadyToTrack(let event): self?.performTrackableReadyToTrack(event)
            case .enhancedLocationChanged(let event): self?.performEnhancedLocationChanged(event)
            case .sendEnhancedLocationSuccess(let event): self?.performSendEnhancedLocationSuccess(event)
            case .sendEnhancedLocationFailure(let event): self?.performSendEnhancedLocationFailure(event)
            case .rawLocationChanged(let event): self?.performRawLocationChanged(event)
            case .sendRawLocationSuccess(let event): self?.performSendRawLocationSuccess(event)
            case .sendRawLocationFailure(let event): self?.performSendRawLocationFailure(event)
            case .addTrackable(let event): self?.performAddTrackableEvent(event)
            case .removeTrackable(let event): self?.performRemoveTrackableEvent(event)
            case .clearActiveTrackable(let event): self?.performClearActiveTrackableEvent(event)
            case .refreshResolutionPolicy(let event): self?.performRefreshResolutionPolicyEvent(event)
            case .changeLocationEngineResolution(let event): self?.performChangeLocationEngineResolutionEvent(event)
            case .presenceUpdate(let event): self?.performPresenceUpdateEvent(event)
            case .clearRemovedTrackableMetadata(let event): self?.performClearRemovedTrackableMetadataEvent(event)
            case .setDestinationSuccess(let event): self?.performSetDestinationSuccessEvent(event)
            case .delegateResolutionUpdate(let event): self?.notifyDelegateResolutionUpdate(event)
            case .delegateError(let event): self?.notifyDelegateDidFailWithError(event.error)
            case .delegateTrackableConnectionStateChanged(let event): self?.notifyDelegateConnectionStateChanged(event)
            case .delegateEnhancedLocationChanged(let event): self?.notifyDelegateEnhancedLocationChanged(event)
            case .changeRoutingProfile(let event): self?.performChangeRoutingProfileEvent(event)
            case .stop(let event): self?.performStopPublisherEvent(event)
            case .ablyConnectionClosed(let event): self?.performAblyConnectionClosedEvent(event)
            case .ablyClientConnectionStateChanged(let event): self?.performAblyClientConnectionChangedEvent(event)
            case .ablyChannelConnectionStateChanged(let event): self?.performAblyChannelConnectionStateChangedEvent(event)
            }
        }
    }

    private func sendDelegateEvent(_ event: DelegateEvent) {
        logHandler?.verbose(message: "Received event to send to delegate, dispatching call to main thread: \(event)", error: nil)

        Self.performOnMainThread { [weak self] in
            guard let self
            else { return }

            let log = { (description: String) in
                self.logHandler?.logPublicAPIOutput(label: "Calling delegate \(description)")
            }

            switch event {
            case .error(let event):
                log("didFailWithError: \(event.error)")
                self.delegate?.publisher(sender: self, didFailWithError: event.error)
            case .trackableConnectionStateChanged(let event):
                log("didChangeConnectionState: \(event.connectionState), forTrackable: \(event.trackable)")
                self.delegate?.publisher(sender: self, didChangeConnectionState: event.connectionState, forTrackable: event.trackable)
            case .enhancedLocationChanged(let event):
                log("didUpdateEnhancedLocation: \(event.locationUpdate)")
                self.delegate?.publisher(sender: self, didUpdateEnhancedLocation: event.locationUpdate)
            case .finishedRecordingLocationHistoryData(let event):
                // Omitting this because it could be huge and log messages are currently always evaluated regardless of configured level
                log("didFinishRecordingLocationHistoryData: (omitted)")
                self.delegate?.publisher(sender: self, didFinishRecordingLocationHistoryData: event.locationHistoryData)
            case .finishedRecordingRawMapboxData(let event):
                log("didFinishRecordingRawMapboxDataToTemporaryFile: \(event.temporaryFile)")
                self.delegate?.publisher(sender: self, didFinishRecordingRawMapboxDataToTemporaryFile: event.temporaryFile)
            case .didUpdateResolution(let event):
                log("didUpdateResolution: \(event.resolution)")
                self.delegate?.publisher(sender: self, didUpdateResolution: event.resolution)
            case .didChangeTrackables(let event):
                log("didChangeTrackables: \(event.trackables)")
                self.delegate?.publisher(sender: self, didChangeTrackables: event.trackables)
            }
        }
    }

    // MARK: Track
    private func performTrackTrackableEvent(_ event: Event.TrackTrackableEvent) {
        let completion = Callback<Void>(source: .internallyCreated, logHandler: logHandler) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: .trackableReadyToTrack(.init(trackable: event.trackable, completion: event.completion)))
            case .failure(let error):
                event.completion.handleError(error)
            }
        }
        performAddOrTrack(event.trackable, completion: completion)
    }

    private func performTrackableReadyToTrack(_ event: Event.TrackableReadyToTrackEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
            return
        }

        if activeTrackable != event.trackable {
            activeTrackable = event.trackable
            hooks.trackables?.onActiveTrackableChanged(trackable: event.trackable)
            if let destination = event.trackable.destination {
                routeProvider.getRoute(to: destination.toCoreLocationCoordinate2d(), withRoutingProfile: routingProfile) { [weak self] result in
                    switch result {
                    case .success(let route):
                        self?.enqueue(event: .setDestinationSuccess(.init(route: route)))
                    case .failure(let error):
                        self?.logHandler?.error(message: "Can't fetch route.", error: error)
                        event.completion.handleError(error)
                    }
                }
            } else {
                self.route = nil
            }
        }

        event.completion.handleSuccess()
    }

    private func performPresenceJoinedSuccessfullyEvent(_ event: Event.PresenceJoinedSuccessfullyEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
            return
        }

        ablyPublisher.subscribeForPresenceMessages(trackable: event.trackable)
        ablyPublisher.subscribeForChannelStateChange(trackable: event.trackable)

        trackables.insert(event.trackable)
        // Start updating location only after the first trackable
        if trackables.count == 1 {
            locationService.startRecordingLocation()
            locationService.startUpdatingLocation()
        }
        resolveResolution(trackable: event.trackable)
        hooks.trackables?.onTrackableAdded(trackable: event.trackable)
        event.completion.handleSuccess()
        duplicateTrackableGuard.finishAddingTrackableWithId(event.trackable.id, result: .success)
    }

    // MARK: RoutingProfile
    private func performChangeRoutingProfileEvent(_ event: Event.ChangeRoutingProfileEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
            return
        }

        guard let destination = activeTrackable?.destination else {
            self.routingProfile = event.profile
            event.completion.handleSuccess()
            return
        }

        routeProvider.getRoute(to: destination.toCoreLocationCoordinate2d(), withRoutingProfile: event.profile) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let route):
                self.routingProfile = event.profile
                self.enqueue(event: .setDestinationSuccess(.init(route: route)))
                event.completion.handleSuccess()
            case .failure(let error):
                self.logHandler?.error(message: "Can't change RoutingProfile", error: error)
                event.completion.handleError(error)
            }
        }
    }

    // MARK: Destination
    private func performSetDestinationSuccessEvent(_ event: Event.SetDestinationSuccessEvent) {
        self.route = event.route
    }

    private func performAddOrTrack(_ trackable: Trackable, completion: Callback<Void>) {
        guard !duplicateTrackableGuard.isCurrentlyAddingTrackableWithId(trackable.id) else {
            self.logHandler?.debug(message: "\(Self.self): Trackable with ID \(trackable.id) is already being added; saving completion handler.", error: nil)
            duplicateTrackableGuard.saveDuplicateAddCompletionHandler(completion, forTrackableWithId: trackable.id)
            return
        }

        guard !state.isStoppingOrStopped else {
            completion.handlePublisherStopped()
            return
        }

        guard !trackables.contains(trackable) else {
            completion.handleSuccess()
            return
        }

        duplicateTrackableGuard.startAddingTrackableWithId(trackable.id)

        ablyPublisher.connect(
                trackableId: trackable.id,
                presenceData: presenceData,
                useRewind: false
        ) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: .presenceJoinedSuccessfully(.init(trackable: trackable, completion: completion)))
            case .failure(let error):
                completion.handleError(error)
                self?.duplicateTrackableGuard.finishAddingTrackableWithId(trackable.id, result: .failure(error))
            }
        }
    }
    // MARK: Add trackable
    private func performAddTrackableEvent(_ event: Event.AddTrackableEvent) {
        performAddOrTrack(event.trackable, completion: event.completion)
    }

    // MARK: Remove trackable
    private func performRemoveTrackableEvent(_ event: Event.RemoveTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
            return
        }

        self.ablyPublisher.disconnect(
            trackableId: event.trackable.id,
            presenceData: presenceData
        ) { [weak self] result in

            switch result {
            case .success(let wasPresent):
                self?.enhancedLocationState.remove(trackableId: event.trackable.id)

                if wasPresent {
                    self?.enqueue(event: .clearRemovedTrackableMetadata(.init(trackable: event.trackable, completion: event.completion)))
                } else {
                    event.completion.handleValue(false)
                }
            case .failure(let error):
                event.completion.handleError(error)
            }
        }
    }

    // MARK: Stop publisher
    private func performStopPublisherEvent(_ event: Event.StopEvent) {
        if state.isStoppingOrStopped {
            event.completion.handleSuccess()
            return
        }

        state = .stopping

        self.locationService.stopUpdatingLocation()

        locationService.stopRecordingLocation { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .failure(let error):
                self.logHandler?.error(message: "Failed to stop recording location", error: error)
            case .success(let locationRecordingResult):
                if let locationRecordingResult {
                    self.sendDelegateEvent(.finishedRecordingLocationHistoryData(.init(locationHistoryData: locationRecordingResult.locationHistoryData)))
                    self.sendDelegateEvent(.finishedRecordingRawMapboxData(.init(temporaryFile: locationRecordingResult.rawHistoryFile)))
                }
            }

            self.ablyPublisher.close(presenceData: self.presenceData) { [weak self] result in
                switch result {
                case .success:
                    self?.enqueue(event: .ablyConnectionClosed(.init(completion: event.completion)))
                case .failure(let error):
                    event.completion.handleError(error)
                }
            }
        }
    }

    private func performAblyConnectionClosedEvent(_ event: Event.AblyConnectionClosedEvent) {
        state = .stopped
        enhancedLocationState.removeAll()
        rawLocationState.removeAll()
        event.completion.handleSuccess()
    }

    private func performAblyClientConnectionChangedEvent(_ event: Event.AblyClientConnectionStateChangedEvent) {
        receivedAblyClientConnectionState = event.connectionState
        trackables.forEach { trackable in
            handleConnectionStateChange(forTrackable: trackable)
        }
    }

    private func performAblyChannelConnectionStateChangedEvent(_ event: Event.AblyChannelConnectionStateChangedEvent) {
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
            sendDelegateEvent(.trackableConnectionStateChanged(.init(trackable: trackable, connectionState: newTrackableState)))
        }
    }

    private func hasSentAtLeastOneLocation(forTrackable trackable: Trackable) -> Bool {
        return lastEnhancedLocations[trackable] != nil
    }

    private func performClearRemovedTrackableMetadataEvent(_ event: Event.ClearRemovedTrackableMetadataEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
            return
        }

        trackables.remove(event.trackable)
        hooks.trackables?.onTrackableRemoved(trackable: event.trackable)
        removeAllSubscribers(forTrackable: event.trackable)
        resolutions.removeValue(forKey: event.trackable)
        requests.removeValue(forKey: event.trackable)
        lastEnhancedLocations.removeValue(forKey: event.trackable)
        lastRawLocations.removeValue(forKey: event.trackable)

        enqueue(event: .clearActiveTrackable(.init(trackable: event.trackable, completion: event.completion)))
    }

    private func performClearActiveTrackableEvent(_ event: Event.ClearActiveTrackableEvent) {
        guard !state.isStoppingOrStopped else {
            event.completion.handlePublisherStopped()
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

        event.completion.handleValue(true)
    }

    private func removeAllSubscribers(forTrackable trackable: Trackable) {
        guard let trackableSubscribers = subscribers[trackable],
              !trackableSubscribers.isEmpty
        else { return }
        trackableSubscribers.forEach { subscriber in
            hooks.subscribers?.onSubscriberRemoved(subscriber: subscriber)
        }
        subscribers[trackable] = []
    }

    // MARK: Location change
    private func performEnhancedLocationChanged(_ event: Event.EnhancedLocationChangedEvent) {
        guard !state.isStoppingOrStopped else {
            logHandler?.error(error: ErrorInformation(type: .publisherError(errorMessage: "Cannot perform EnhancedLocationChangedEvent. Publisher is either stopped or stopping.")))
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

        performEnhancedLocationChanged(.init(locationUpdate: enhancedLocationUpdate))
    }

    private func processNextWaitingRawLocationUpdate(for trackableId: String) {
        guard let rawLocationUpdate = rawLocationState.nextWaitingLocation(for: trackableId) else {
            return
        }

        performRawLocationChanged(.init(locationUpdate: rawLocationUpdate))
    }

    private func sendEnhancedLocationUpdate(event: Event.EnhancedLocationChangedEvent, trackable: Trackable) {
        lastEnhancedLocations[trackable] = event.locationUpdate.location
        lastEnhancedTimestamps[trackable] = event.locationUpdate.location.timestamp

        event.locationUpdate.skippedLocations = enhancedLocationState.locationsList(for: trackable.id).map { $0.location }

        enhancedLocationState.markMessageAsPending(for: trackable.id)

        ablyPublisher.sendEnhancedLocation(locationUpdate: event.locationUpdate, trackable: trackable) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.enqueue(event: .sendEnhancedLocationFailure(.init(error: error, locationUpdate: event.locationUpdate, trackable: trackable)))
            case .success:
                self?.enqueue(event: .sendEnhancedLocationSuccess(.init(trackable: trackable, location: event.locationUpdate.location)))
            }
        }
    }

    private func sendRawLocationUpdate(event: Event.RawLocationChangedEvent, trackable: Trackable) {
        lastRawLocations[trackable] = event.locationUpdate.location
        lastRawTimestamps[trackable] = event.locationUpdate.location.timestamp

        event.locationUpdate.skippedLocations = rawLocationState.locationsList(for: trackable.id).map { $0.location }

        rawLocationState.markMessageAsPending(for: trackable.id)

        ablyPublisher.sendRawLocation(location: event.locationUpdate, trackable: trackable) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.enqueue(event: .sendRawLocationFailure(.init(error: error, locationUpdate: event.locationUpdate, trackable: trackable)))
            case .success:
                self?.enqueue(event: .sendRawLocationSuccess(.init(trackable: trackable, location: event.locationUpdate.location)))
            }
        }
    }

    private func saveEnhancedLocationForFurtherSending(trackableId: String, location: EnhancedLocationUpdate) {
        enhancedLocationState.addLocation(for: trackableId, location: location)
    }

    private func saveRawLocationForFurtherSending(trackableId: String, location: RawLocationUpdate) {
        rawLocationState.addLocation(for: trackableId, location: location)
    }

    private func performRawLocationChanged(_ event: Event.RawLocationChangedEvent) {
        guard !state.isStoppingOrStopped else {
            logHandler?.error(error: ErrorInformation(type: .publisherError(errorMessage: "Cannot perform RawLocationChanged. Publisher is either stopped or stopping.")))
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

    private func performSendRawLocationSuccess(_ event: Event.SendRawLocationSuccessEvent) {
        rawLocationState.unmarkMessageAsPending(for: event.trackable.id)
        rawLocationState.clearLocation(for: event.trackable.id)
        rawLocationState.resetRetryCounter(for: event.trackable.id)
        processNextWaitingRawLocationUpdate(for: event.trackable.id)
    }

    private func performSendRawLocationFailure(_ event: Event.SendRawLocationFailureEvent) {
        guard rawLocationState.shouldRetry(trackableId: event.trackable.id) else {
            rawLocationState.unmarkMessageAsPending(for: event.trackable.id)
            saveRawLocationForFurtherSending(trackableId: event.trackable.id, location: event.locationUpdate)
            sendDelegateEvent(.error(.init(error: event.error)))
            processNextWaitingRawLocationUpdate(for: event.trackable.id)
            return
        }

        retrySendingRawLocation(
            trackable: event.trackable,
            locationUpdate: event.locationUpdate
        )
    }

    private func performSendEnhancedLocationSuccess(_ event: Event.SendEnhancedLocationSuccessEvent) {
        enhancedLocationState.unmarkMessageAsPending(for: event.trackable.id)
        enhancedLocationState.clearLocation(for: event.trackable.id)
        enhancedLocationState.resetRetryCounter(for: event.trackable.id)
        processNextWaitingEnhancedLocationUpdate(for: event.trackable.id)
    }

    private func performSendEnhancedLocationFailure(_ event: Event.SendEnhancedLocationFailureEvent) {
        guard enhancedLocationState.shouldRetry(trackableId: event.trackable.id) else {
            enhancedLocationState.unmarkMessageAsPending(for: event.trackable.id)
            saveEnhancedLocationForFurtherSending(trackableId: event.trackable.id, location: event.locationUpdate)
            sendDelegateEvent(.error(.init(error: event.error)))
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
            event: .init(locationUpdate: locationUpdate),
            trackable: trackable
        )
    }

    private func retrySendingRawLocation(trackable: Trackable, locationUpdate: RawLocationUpdate) {
        rawLocationState.incrementRetryCounter(for: trackable.id)

        sendRawLocationUpdate(
            event: .init(locationUpdate: locationUpdate),
            trackable: trackable
        )
    }

    private func shouldSendLocation(location: Location,
                                    lastLocation: Location?,
                                    lastTimestamp: Double?,
                                    resolution: Resolution?) -> Bool {
        guard let resolution,
              let lastLocation,
              let lastTimestamp
        else { return true }

        let distance = location.distance(from: lastLocation)
        let timeInterval = location.timestamp - lastTimestamp

        // desiredInterval in resolution is in milliseconds, while timeInterval from timestamp is in seconds
        let desiredIntervalInSeconds = resolution.desiredInterval / 1000
        return distance >= resolution.minimumDisplacement || timeInterval >= desiredIntervalInSeconds
    }

    // MARK: ResolutionPolicy
    private func performRefreshResolutionPolicyEvent(_ event: Event.RefreshResolutionPolicyEvent) {
        guard !state.isStoppingOrStopped else {
            logHandler?.error(error: ErrorInformation(type: .publisherError(errorMessage: "Cannot perform RefreshResolutionPolicyEvent. Publisher is either stopped or stopping.")))
            return
        }

        trackables.forEach { trackable in
            resolveResolution(trackable: trackable)
        }
    }

    private func resolveResolution(trackable: Trackable) {
        let currentRequests = requests[trackable]?.values
        let resolutionSet: Set<Resolution> = currentRequests == nil ? [] : Set(currentRequests!)
        let request = TrackableResolutionRequest(trackable: trackable, remoteRequests: resolutionSet)
        let resolution = resolutionPolicy.resolve(request: request)
        resolutions[trackable] = resolution
        enqueue(event: .changeLocationEngineResolution(.init()))
        if isSendResolutionEnabled {
            ablyPublisher.updatePresenceData(trackableId: trackable.id, presenceData: presenceData.copy(with: resolution), completion: nil)
        }
    }

    private func performChangeLocationEngineResolutionEvent(_ event: Event.ChangeLocationEngineResolutionEvent) {
        locationEngineResolution = resolutionPolicy.resolve(resolutions: Set(resolutions.values))
        changeLocationEngineResolution(resolution: locationEngineResolution)
    }

    private func changeLocationEngineResolution(resolution: Resolution) {
        guard !state.isStoppingOrStopped else {
            logHandler?.error(error: ErrorInformation(type: .publisherError(errorMessage: "Cannot perform ChangeLocationEngineResolution. Publisher is either stopped or stopping.")))
            return
        }

        if constantLocationEngineResolution == nil {
            locationService.changeLocationEngineResolution(resolution: resolution)
        }

        enqueue(event: .delegateResolutionUpdate(.init(resolution: resolution)))
    }

    private func checkThreshold(location: Location) {
        guard let threshold = proximityThreshold,
              let handler = proximityHandler
        else { return }

        let checker = ThresholdChecker()
        var destination: Location?
        do {
            destination = try activeTrackable?.destination != nil ?
            CLLocation(latitude: activeTrackable!.destination!.latitude, longitude: activeTrackable!.destination!.longitude).toLocation().get() : nil
        } catch {
            logHandler?.verbose(message: "Invalid destination, validation error was: \(error)", error: error as? LocationValidationError)
            return
        }
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
    private func performPresenceUpdateEvent(_ event: Event.PresenceUpdateEvent) {
        guard !state.isStoppingOrStopped else {
            logHandler?.error(error: ErrorInformation(type: .publisherError(errorMessage: "Cannot perform PresenceUpdateEvent. Publisher is either stopped or stopping.")))
            return
        }

        guard event.presenceData.type == .subscriber else { return }

        if event.presence.action == .enter {
            addSubscriber(clientId: event.clientId, trackable: event.trackable, data: event.presenceData)
        } else if event.presence.action == .leave {
            removeSubscriber(clientId: event.clientId, trackable: event.trackable)
        } else if event.presence.action == .update {
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
    private func performOnWorkingQueue(_ operation: @escaping () -> Void) {
        workerQueue.enqueue(
            workRequest: WorkRequest<PublisherWorkSpecification>(
                workerSpecification: PublisherWorkSpecification.legacy(callback: operation)
            )
        )
    }

    static private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }

    // MARK: Delegate
    private func notifyDelegateDidFailWithError(_ error: ErrorInformation) {
        sendDelegateEvent(.error(.init(error: error)))
    }

    private func notifyDelegateEnhancedLocationChanged(_ event: Event.DelegateEnhancedLocationChangedEvent) {
        sendDelegateEvent(.enhancedLocationChanged(.init(locationUpdate: event.locationUpdate)))
    }

    private func notifyDelegateConnectionStateChanged(_ event: Event.DelegateTrackableConnectionStateChangedEvent) {
        sendDelegateEvent(.trackableConnectionStateChanged(.init(trackable: event.trackable, connectionState: event.connectionState)))
    }

    private func notifyDelegateResolutionUpdate(_ event: Event.DelegateResolutionUpdateEvent) {
        sendDelegateEvent(.didUpdateResolution(.init(resolution: event.resolution)))
    }

    private func notifyTrackablesChanged(trackables: Set<Trackable>) {
        sendDelegateEvent(.didChangeTrackables(.init(trackables: trackables)))
    }
}

// MARK: LocationServiceDelegate
extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: ErrorInformation) {
        logHandler?.error(message: "locationService.didFailWithError.", error: error)
        sendDelegateEvent(.error(.init(error: error)))
    }

    func locationService(sender: LocationService, didUpdateRawLocationUpdate locationUpdate: RawLocationUpdate) {
        logHandler?.debug(message: "locationService.didUpdateRawLocation.", error: nil)
        enqueue(event: .rawLocationChanged(.init(locationUpdate: locationUpdate)))
    }

    func locationService(sender: LocationService, didUpdateEnhancedLocationUpdate locationUpdate: EnhancedLocationUpdate) {
        logHandler?.debug(message: "locationService.didUpdateEnhancedLocation.", error: nil)
        enqueue(event: .enhancedLocationChanged(.init(locationUpdate: locationUpdate)))
        sendDelegateEvent(.enhancedLocationChanged(.init(locationUpdate: locationUpdate)))
    }
}

// MARK: AblyPublisherDelegate
extension DefaultPublisher: AblyPublisherDelegate {
    func ablyPublisher(_ sender: AblyPublisher, didChangeChannelConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        logHandler?.debug(message: "ablyPublisher.didChangeChannelConnectionState. State: \(state) for trackable: \(trackable.id)", error: nil)
        enqueue(event: .ablyChannelConnectionStateChanged(.init(trackable: trackable, connectionState: state)))
    }

    func ablyPublisher(_ sender: AblyPublisher, didFailWithError error: ErrorInformation) {
        logHandler?.error(message: "ablyPublisher.didFailWithError.", error: error)
        sendDelegateEvent(.error(.init(error: error)))
    }

    func ablyPublisher(_ sender: AblyPublisher, didChangeConnectionState state: ConnectionState) {
        logHandler?.debug(message: "ablyPublisher.didChangeConnectionState. State: \(state.description)", error: nil)
        enqueue(event: .ablyClientConnectionStateChanged(.init(connectionState: state)))
    }

    func ablyPublisher(_ sender: AblyPublisher,
                       didReceivePresenceUpdate presence: Presence,
                       forTrackable trackable: Trackable,
                       presenceData: PresenceData,
                       clientId: String) {

        logHandler?.debug(message: "publisherService.didReceivePresenceUpdate. Presence: \(presence), Trackable: \(trackable)", error: nil)
        enqueue(event: .presenceUpdate(.init(trackable: trackable, presence: presence, presenceData: presenceData, clientId: clientId)))
    }
}

// MARK: ResolutionPolicyMethodsDelegate
extension DefaultPublisher: DefaultResolutionPolicyMethodsDelegate {
    func resolutionPolicyMethods(refreshWithSender sender: DefaultResolutionPolicyMethods) {
        enqueue(event: .refreshResolutionPolicy(.init()))
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
