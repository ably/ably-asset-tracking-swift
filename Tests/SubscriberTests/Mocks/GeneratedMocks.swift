// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import AblyAssetTrackingInternal

@testable import AblyAssetTrackingSubscriber




















class SubscriberSpecificWorkerQueuePropertiesProtocolMock: SubscriberSpecificWorkerQueuePropertiesProtocol {


    var presenceData: PresenceData {
        get { return underlyingPresenceData }
        set(value) { underlyingPresenceData = value }
    }
    var underlyingPresenceData: PresenceData!
    var presentPublisherMemberKeys: Set<String> {
        get { return underlyingPresentPublisherMemberKeys }
        set(value) { underlyingPresentPublisherMemberKeys = value }
    }
    var underlyingPresentPublisherMemberKeys: Set<String>!
    var lastEmittedValueOfIsPublisherVisible: Bool?
    var lastEmittedTrackableState: TrackableState {
        get { return underlyingLastEmittedTrackableState }
        set(value) { underlyingLastEmittedTrackableState = value }
    }
    var underlyingLastEmittedTrackableState: TrackableState!
    var lastConnectionStateChange: ConnectionStateChange {
        get { return underlyingLastConnectionStateChange }
        set(value) { underlyingLastConnectionStateChange = value }
    }
    var underlyingLastConnectionStateChange: ConnectionStateChange!
    var lastChannelConnectionStateChange: ConnectionStateChange {
        get { return underlyingLastChannelConnectionStateChange }
        set(value) { underlyingLastChannelConnectionStateChange = value }
    }
    var underlyingLastChannelConnectionStateChange: ConnectionStateChange!
    var pendingPublisherResolutions: PendingResolutions {
        get { return underlyingPendingPublisherResolutions }
        set(value) { underlyingPendingPublisherResolutions = value }
    }
    var underlyingPendingPublisherResolutions: PendingResolutions!
    var enhancedLocation: LocationUpdate?
    var rawLocation: LocationUpdate?
    var trackableState: TrackableState {
        get { return underlyingTrackableState }
        set(value) { underlyingTrackableState = value }
    }
    var underlyingTrackableState: TrackableState!
    var publisherPresence: Bool {
        get { return underlyingPublisherPresence }
        set(value) { underlyingPublisherPresence = value }
    }
    var underlyingPublisherPresence: Bool!
    var resolution: Resolution?
    var nextLocationUpdateInterval: Double?

    //MARK: - updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired

    var updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount = 0
    var updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCalled: Bool {
        return updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount > 0
    }
    var updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedArguments: (stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)?
    var updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedInvocations: [(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)] = []
    var updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerClosure: ((ConnectionStateChange, InternalLogHandler?) -> Void)?

    func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount += 1
        updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedArguments = (stateChange: stateChange, logHandler: logHandler)
        updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedInvocations.append((stateChange: stateChange, logHandler: logHandler))
        updateForConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerClosure?(stateChange, logHandler)
    }

    //MARK: - updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired

    var updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount = 0
    var updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCalled: Bool {
        return updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount > 0
    }
    var updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedArguments: (stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)?
    var updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedInvocations: [(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)] = []
    var updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerClosure: ((ConnectionStateChange, InternalLogHandler?) -> Void)?

    func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerCallsCount += 1
        updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedArguments = (stateChange: stateChange, logHandler: logHandler)
        updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerReceivedInvocations.append((stateChange: stateChange, logHandler: logHandler))
        updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequiredStateChangeLogHandlerClosure?(stateChange, logHandler)
    }

    //MARK: - updateForPresenceMessagesAndThenDelegateStateEventsIfRequired

    var updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerCallsCount = 0
    var updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerCalled: Bool {
        return updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerCallsCount > 0
    }
    var updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedArguments: (presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?)?
    var updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedInvocations: [(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?)] = []
    var updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerClosure: (([PresenceMessage], InternalLogHandler?) -> Void)?

    func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?) {
        updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerCallsCount += 1
        updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedArguments = (presenceMessages: presenceMessages, logHandler: logHandler)
        updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerReceivedInvocations.append((presenceMessages: presenceMessages, logHandler: logHandler))
        updateForPresenceMessagesAndThenDelegateStateEventsIfRequiredPresenceMessagesLogHandlerClosure?(presenceMessages, logHandler)
    }

    //MARK: - delegateStateEventsIfRequired

    var delegateStateEventsIfRequiredLogHandlerCallsCount = 0
    var delegateStateEventsIfRequiredLogHandlerCalled: Bool {
        return delegateStateEventsIfRequiredLogHandlerCallsCount > 0
    }
    var delegateStateEventsIfRequiredLogHandlerReceivedLogHandler: InternalLogHandler?
    var delegateStateEventsIfRequiredLogHandlerReceivedInvocations: [InternalLogHandler?] = []
    var delegateStateEventsIfRequiredLogHandlerClosure: ((InternalLogHandler?) -> Void)?

    func delegateStateEventsIfRequired(logHandler: InternalLogHandler?) {
        delegateStateEventsIfRequiredLogHandlerCallsCount += 1
        delegateStateEventsIfRequiredLogHandlerReceivedLogHandler = logHandler
        delegateStateEventsIfRequiredLogHandlerReceivedInvocations.append(logHandler)
        delegateStateEventsIfRequiredLogHandlerClosure?(logHandler)
    }

    //MARK: - notifyEnhancedLocationUpdated

    var notifyEnhancedLocationUpdatedLocationUpdateLogHandlerCallsCount = 0
    var notifyEnhancedLocationUpdatedLocationUpdateLogHandlerCalled: Bool {
        return notifyEnhancedLocationUpdatedLocationUpdateLogHandlerCallsCount > 0
    }
    var notifyEnhancedLocationUpdatedLocationUpdateLogHandlerReceivedArguments: (locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)?
    var notifyEnhancedLocationUpdatedLocationUpdateLogHandlerReceivedInvocations: [(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)] = []
    var notifyEnhancedLocationUpdatedLocationUpdateLogHandlerClosure: ((LocationUpdate, InternalLogHandler?) -> Void)?

    func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        notifyEnhancedLocationUpdatedLocationUpdateLogHandlerCallsCount += 1
        notifyEnhancedLocationUpdatedLocationUpdateLogHandlerReceivedArguments = (locationUpdate: locationUpdate, logHandler: logHandler)
        notifyEnhancedLocationUpdatedLocationUpdateLogHandlerReceivedInvocations.append((locationUpdate: locationUpdate, logHandler: logHandler))
        notifyEnhancedLocationUpdatedLocationUpdateLogHandlerClosure?(locationUpdate, logHandler)
    }

    //MARK: - notifyRawLocationUpdated

    var notifyRawLocationUpdatedLocationUpdateLogHandlerCallsCount = 0
    var notifyRawLocationUpdatedLocationUpdateLogHandlerCalled: Bool {
        return notifyRawLocationUpdatedLocationUpdateLogHandlerCallsCount > 0
    }
    var notifyRawLocationUpdatedLocationUpdateLogHandlerReceivedArguments: (locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)?
    var notifyRawLocationUpdatedLocationUpdateLogHandlerReceivedInvocations: [(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)] = []
    var notifyRawLocationUpdatedLocationUpdateLogHandlerClosure: ((LocationUpdate, InternalLogHandler?) -> Void)?

    func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        notifyRawLocationUpdatedLocationUpdateLogHandlerCallsCount += 1
        notifyRawLocationUpdatedLocationUpdateLogHandlerReceivedArguments = (locationUpdate: locationUpdate, logHandler: logHandler)
        notifyRawLocationUpdatedLocationUpdateLogHandlerReceivedInvocations.append((locationUpdate: locationUpdate, logHandler: logHandler))
        notifyRawLocationUpdatedLocationUpdateLogHandlerClosure?(locationUpdate, logHandler)
    }

    //MARK: - notifyPublisherPresenceUpdated

    var notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerCallsCount = 0
    var notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerCalled: Bool {
        return notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerCallsCount > 0
    }
    var notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerReceivedArguments: (isPublisherPresent: Bool, logHandler: InternalLogHandler?)?
    var notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerReceivedInvocations: [(isPublisherPresent: Bool, logHandler: InternalLogHandler?)] = []
    var notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerClosure: ((Bool, InternalLogHandler?) -> Void)?

    func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) {
        notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerCallsCount += 1
        notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerReceivedArguments = (isPublisherPresent: isPublisherPresent, logHandler: logHandler)
        notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerReceivedInvocations.append((isPublisherPresent: isPublisherPresent, logHandler: logHandler))
        notifyPublisherPresenceUpdatedIsPublisherPresentLogHandlerClosure?(isPublisherPresent, logHandler)
    }

    //MARK: - notifyTrackableStateUpdated

    var notifyTrackableStateUpdatedTrackableStateLogHandlerCallsCount = 0
    var notifyTrackableStateUpdatedTrackableStateLogHandlerCalled: Bool {
        return notifyTrackableStateUpdatedTrackableStateLogHandlerCallsCount > 0
    }
    var notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedArguments: (trackableState: TrackableState, logHandler: InternalLogHandler?)?
    var notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedInvocations: [(trackableState: TrackableState, logHandler: InternalLogHandler?)] = []
    var notifyTrackableStateUpdatedTrackableStateLogHandlerClosure: ((TrackableState, InternalLogHandler?) -> Void)?

    func notifyTrackableStateUpdated(trackableState: TrackableState, logHandler: InternalLogHandler?) {
        notifyTrackableStateUpdatedTrackableStateLogHandlerCallsCount += 1
        notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedArguments = (trackableState: trackableState, logHandler: logHandler)
        notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedInvocations.append((trackableState: trackableState, logHandler: logHandler))
        notifyTrackableStateUpdatedTrackableStateLogHandlerClosure?(trackableState, logHandler)
    }

    //MARK: - notifyDidFailWithError

    var notifyDidFailWithErrorErrorLogHandlerCallsCount = 0
    var notifyDidFailWithErrorErrorLogHandlerCalled: Bool {
        return notifyDidFailWithErrorErrorLogHandlerCallsCount > 0
    }
    var notifyDidFailWithErrorErrorLogHandlerReceivedArguments: (error: ErrorInformation, logHandler: InternalLogHandler?)?
    var notifyDidFailWithErrorErrorLogHandlerReceivedInvocations: [(error: ErrorInformation, logHandler: InternalLogHandler?)] = []
    var notifyDidFailWithErrorErrorLogHandlerClosure: ((ErrorInformation, InternalLogHandler?) -> Void)?

    func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) {
        notifyDidFailWithErrorErrorLogHandlerCallsCount += 1
        notifyDidFailWithErrorErrorLogHandlerReceivedArguments = (error: error, logHandler: logHandler)
        notifyDidFailWithErrorErrorLogHandlerReceivedInvocations.append((error: error, logHandler: logHandler))
        notifyDidFailWithErrorErrorLogHandlerClosure?(error, logHandler)
    }

    //MARK: - notifyResolutionsChanged

    var notifyResolutionsChangedResolutionsLogHandlerCallsCount = 0
    var notifyResolutionsChangedResolutionsLogHandlerCalled: Bool {
        return notifyResolutionsChangedResolutionsLogHandlerCallsCount > 0
    }
    var notifyResolutionsChangedResolutionsLogHandlerReceivedArguments: (resolutions: [Resolution], logHandler: InternalLogHandler?)?
    var notifyResolutionsChangedResolutionsLogHandlerReceivedInvocations: [(resolutions: [Resolution], logHandler: InternalLogHandler?)] = []
    var notifyResolutionsChangedResolutionsLogHandlerClosure: (([Resolution], InternalLogHandler?) -> Void)?

    func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) {
        notifyResolutionsChangedResolutionsLogHandlerCallsCount += 1
        notifyResolutionsChangedResolutionsLogHandlerReceivedArguments = (resolutions: resolutions, logHandler: logHandler)
        notifyResolutionsChangedResolutionsLogHandlerReceivedInvocations.append((resolutions: resolutions, logHandler: logHandler))
        notifyResolutionsChangedResolutionsLogHandlerClosure?(resolutions, logHandler)
    }

}
