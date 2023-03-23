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




















class SubscriberWorkerQueuePropertiesProtocolMock: SubscriberWorkerQueuePropertiesProtocol {


    var presenceData: PresenceData {
        get { return underlyingPresenceData }
        set(value) { underlyingPresenceData = value }
    }
    var underlyingPresenceData: PresenceData!
    var subscriber: Subscriber?
    var enhancedLocation: LocationUpdate?
    var rawLocation: LocationUpdate?
    var trackableState: ConnectionState {
        get { return underlyingTrackableState }
        set(value) { underlyingTrackableState = value }
    }
    var underlyingTrackableState: ConnectionState!
    var publisherPresence: Bool {
        get { return underlyingPublisherPresence }
        set(value) { underlyingPublisherPresence = value }
    }
    var underlyingPublisherPresence: Bool!
    var resolution: Resolution?
    var nextLocationUpdateInterval: Double?
    var delegate: SubscriberDelegate?

    //MARK: - addUpdatingResolution

    var addUpdatingResolutionTrackableIdResolutionCallsCount = 0
    var addUpdatingResolutionTrackableIdResolutionCalled: Bool {
        return addUpdatingResolutionTrackableIdResolutionCallsCount > 0
    }
    var addUpdatingResolutionTrackableIdResolutionReceivedArguments: (trackableId: String, resolution: Resolution?)?
    var addUpdatingResolutionTrackableIdResolutionReceivedInvocations: [(trackableId: String, resolution: Resolution?)] = []
    var addUpdatingResolutionTrackableIdResolutionClosure: ((String, Resolution?) -> Void)?

    func addUpdatingResolution(trackableId: String, resolution: Resolution?) {
        addUpdatingResolutionTrackableIdResolutionCallsCount += 1
        addUpdatingResolutionTrackableIdResolutionReceivedArguments = (trackableId: trackableId, resolution: resolution)
        addUpdatingResolutionTrackableIdResolutionReceivedInvocations.append((trackableId: trackableId, resolution: resolution))
        addUpdatingResolutionTrackableIdResolutionClosure?(trackableId, resolution)
    }

    //MARK: - containsUpdatingResolution

    var containsUpdatingResolutionTrackableIdResolutionCallsCount = 0
    var containsUpdatingResolutionTrackableIdResolutionCalled: Bool {
        return containsUpdatingResolutionTrackableIdResolutionCallsCount > 0
    }
    var containsUpdatingResolutionTrackableIdResolutionReceivedArguments: (trackableId: String, resolution: Resolution?)?
    var containsUpdatingResolutionTrackableIdResolutionReceivedInvocations: [(trackableId: String, resolution: Resolution?)] = []
    var containsUpdatingResolutionTrackableIdResolutionReturnValue: Bool!
    var containsUpdatingResolutionTrackableIdResolutionClosure: ((String, Resolution?) -> Bool)?

    func containsUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        containsUpdatingResolutionTrackableIdResolutionCallsCount += 1
        containsUpdatingResolutionTrackableIdResolutionReceivedArguments = (trackableId: trackableId, resolution: resolution)
        containsUpdatingResolutionTrackableIdResolutionReceivedInvocations.append((trackableId: trackableId, resolution: resolution))
        if let containsUpdatingResolutionTrackableIdResolutionClosure = containsUpdatingResolutionTrackableIdResolutionClosure {
            return containsUpdatingResolutionTrackableIdResolutionClosure(trackableId, resolution)
        } else {
            return containsUpdatingResolutionTrackableIdResolutionReturnValue
        }
    }

    //MARK: - isLastUpdatingResolution

    var isLastUpdatingResolutionTrackableIdResolutionCallsCount = 0
    var isLastUpdatingResolutionTrackableIdResolutionCalled: Bool {
        return isLastUpdatingResolutionTrackableIdResolutionCallsCount > 0
    }
    var isLastUpdatingResolutionTrackableIdResolutionReceivedArguments: (trackableId: String, resolution: Resolution?)?
    var isLastUpdatingResolutionTrackableIdResolutionReceivedInvocations: [(trackableId: String, resolution: Resolution?)] = []
    var isLastUpdatingResolutionTrackableIdResolutionReturnValue: Bool!
    var isLastUpdatingResolutionTrackableIdResolutionClosure: ((String, Resolution?) -> Bool)?

    func isLastUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        isLastUpdatingResolutionTrackableIdResolutionCallsCount += 1
        isLastUpdatingResolutionTrackableIdResolutionReceivedArguments = (trackableId: trackableId, resolution: resolution)
        isLastUpdatingResolutionTrackableIdResolutionReceivedInvocations.append((trackableId: trackableId, resolution: resolution))
        if let isLastUpdatingResolutionTrackableIdResolutionClosure = isLastUpdatingResolutionTrackableIdResolutionClosure {
            return isLastUpdatingResolutionTrackableIdResolutionClosure(trackableId, resolution)
        } else {
            return isLastUpdatingResolutionTrackableIdResolutionReturnValue
        }
    }

    //MARK: - removeUpdatingResolution

    var removeUpdatingResolutionTrackableIdResolutionCallsCount = 0
    var removeUpdatingResolutionTrackableIdResolutionCalled: Bool {
        return removeUpdatingResolutionTrackableIdResolutionCallsCount > 0
    }
    var removeUpdatingResolutionTrackableIdResolutionReceivedArguments: (trackableId: String, resolution: Resolution?)?
    var removeUpdatingResolutionTrackableIdResolutionReceivedInvocations: [(trackableId: String, resolution: Resolution?)] = []
    var removeUpdatingResolutionTrackableIdResolutionClosure: ((String, Resolution?) -> Void)?

    func removeUpdatingResolution(trackableId: String, resolution: Resolution?) {
        removeUpdatingResolutionTrackableIdResolutionCallsCount += 1
        removeUpdatingResolutionTrackableIdResolutionReceivedArguments = (trackableId: trackableId, resolution: resolution)
        removeUpdatingResolutionTrackableIdResolutionReceivedInvocations.append((trackableId: trackableId, resolution: resolution))
        removeUpdatingResolutionTrackableIdResolutionClosure?(trackableId, resolution)
    }

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

    var notifyEnhancedLocationUpdatedLocationUpdateCallsCount = 0
    var notifyEnhancedLocationUpdatedLocationUpdateCalled: Bool {
        return notifyEnhancedLocationUpdatedLocationUpdateCallsCount > 0
    }
    var notifyEnhancedLocationUpdatedLocationUpdateReceivedLocationUpdate: LocationUpdate?
    var notifyEnhancedLocationUpdatedLocationUpdateReceivedInvocations: [LocationUpdate] = []
    var notifyEnhancedLocationUpdatedLocationUpdateClosure: ((LocationUpdate) -> Void)?

    func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate) {
        notifyEnhancedLocationUpdatedLocationUpdateCallsCount += 1
        notifyEnhancedLocationUpdatedLocationUpdateReceivedLocationUpdate = locationUpdate
        notifyEnhancedLocationUpdatedLocationUpdateReceivedInvocations.append(locationUpdate)
        notifyEnhancedLocationUpdatedLocationUpdateClosure?(locationUpdate)
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
    var notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedArguments: (trackableState: ConnectionState, logHandler: InternalLogHandler?)?
    var notifyTrackableStateUpdatedTrackableStateLogHandlerReceivedInvocations: [(trackableState: ConnectionState, logHandler: InternalLogHandler?)] = []
    var notifyTrackableStateUpdatedTrackableStateLogHandlerClosure: ((ConnectionState, InternalLogHandler?) -> Void)?

    func notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?) {
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
