// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import Ably















class AblySDKAuthMock: AblySDKAuth {

    //MARK: - authorize

    var authorizeCallsCount = 0
    var authorizeCalled: Bool {
        return authorizeCallsCount > 0
    }
    var authorizeReceivedCallback: ARTTokenDetailsCallback?
    var authorizeReceivedInvocations: [ARTTokenDetailsCallback] = []
    var authorizeClosure: ((@escaping ARTTokenDetailsCallback) -> Void)?

    func authorize(_ callback: @escaping ARTTokenDetailsCallback) {
        authorizeCallsCount += 1
        authorizeReceivedCallback = callback
        authorizeReceivedInvocations.append(callback)
        authorizeClosure?(callback)
    }

}
class AblySDKConnectionMock: AblySDKConnection {

    //MARK: - on

    var onCallsCount = 0
    var onCalled: Bool {
        return onCallsCount > 0
    }
    var onReceivedCallback: ((ARTConnectionStateChange) -> Void)?
    var onReceivedInvocations: [((ARTConnectionStateChange) -> Void)] = []
    var onReturnValue: AblySDKEventListener!
    var onClosure: ((@escaping (ARTConnectionStateChange) -> Void) -> AblySDKEventListener)?

    @discardableResult
    func on(_ callback: @escaping (ARTConnectionStateChange) -> Void) -> AblySDKEventListener {
        onCallsCount += 1
        onReceivedCallback = callback
        onReceivedInvocations.append(callback)
        if let onClosure = onClosure {
            return onClosure(callback)
        } else {
            return onReturnValue
        }
    }

}
class AblySDKEventListenerMock: AblySDKEventListener {

}
class AblySDKRealtimeMock: AblySDKRealtime {
    var channels: AblySDKRealtimeChannels {
        get { return underlyingChannels }
        set(value) { underlyingChannels = value }
    }
    var underlyingChannels: AblySDKRealtimeChannels!
    var connection: AblySDKConnection {
        get { return underlyingConnection }
        set(value) { underlyingConnection = value }
    }
    var underlyingConnection: AblySDKConnection!
    var auth: AblySDKAuth {
        get { return underlyingAuth }
        set(value) { underlyingAuth = value }
    }
    var underlyingAuth: AblySDKAuth!

    //MARK: - close

    var closeCallsCount = 0
    var closeCalled: Bool {
        return closeCallsCount > 0
    }
    var closeClosure: (() -> Void)?

    func close() {
        closeCallsCount += 1
        closeClosure?()
    }

}
class AblySDKRealtimeChannelMock: AblySDKRealtimeChannel {
    var presence: AblySDKRealtimePresence {
        get { return underlyingPresence }
        set(value) { underlyingPresence = value }
    }
    var underlyingPresence: AblySDKRealtimePresence!

    //MARK: - subscribe

    var subscribeCallbackCallsCount = 0
    var subscribeCallbackCalled: Bool {
        return subscribeCallbackCallsCount > 0
    }
    var subscribeCallbackReceivedArguments: (name: String, callback: ARTMessageCallback)?
    var subscribeCallbackReceivedInvocations: [(name: String, callback: ARTMessageCallback)] = []
    var subscribeCallbackReturnValue: AblySDKEventListener?
    var subscribeCallbackClosure: ((String, @escaping ARTMessageCallback) -> AblySDKEventListener?)?

    @discardableResult
    func subscribe(_ name: String, callback: @escaping ARTMessageCallback) -> AblySDKEventListener? {
        subscribeCallbackCallsCount += 1
        subscribeCallbackReceivedArguments = (name: name, callback: callback)
        subscribeCallbackReceivedInvocations.append((name: name, callback: callback))
        if let subscribeCallbackClosure = subscribeCallbackClosure {
            return subscribeCallbackClosure(name, callback)
        } else {
            return subscribeCallbackReturnValue
        }
    }

    //MARK: - unsubscribe

    var unsubscribeCallsCount = 0
    var unsubscribeCalled: Bool {
        return unsubscribeCallsCount > 0
    }
    var unsubscribeClosure: (() -> Void)?

    func unsubscribe() {
        unsubscribeCallsCount += 1
        unsubscribeClosure?()
    }

    //MARK: - detach

    var detachCallsCount = 0
    var detachCalled: Bool {
        return detachCallsCount > 0
    }
    var detachReceivedCallback: ARTCallback?
    var detachReceivedInvocations: [ARTCallback?] = []
    var detachClosure: ((ARTCallback?) -> Void)?

    func detach(_ callback: ARTCallback?) {
        detachCallsCount += 1
        detachReceivedCallback = callback
        detachReceivedInvocations.append(callback)
        detachClosure?(callback)
    }

    //MARK: - on

    var onCallsCount = 0
    var onCalled: Bool {
        return onCallsCount > 0
    }
    var onReceivedCallback: ((ARTChannelStateChange) -> ())?
    var onReceivedInvocations: [((ARTChannelStateChange) -> ())] = []
    var onReturnValue: AblySDKEventListener!
    var onClosure: ((@escaping (ARTChannelStateChange) -> ()) -> AblySDKEventListener)?

    @discardableResult
    func on(_ callback: @escaping (ARTChannelStateChange) -> ()) -> AblySDKEventListener {
        onCallsCount += 1
        onReceivedCallback = callback
        onReceivedInvocations.append(callback)
        if let onClosure = onClosure {
            return onClosure(callback)
        } else {
            return onReturnValue
        }
    }

    //MARK: - publish

    var publishCallbackCallsCount = 0
    var publishCallbackCalled: Bool {
        return publishCallbackCallsCount > 0
    }
    var publishCallbackReceivedArguments: (messages: [ARTMessage], callback: ARTCallback?)?
    var publishCallbackReceivedInvocations: [(messages: [ARTMessage], callback: ARTCallback?)] = []
    var publishCallbackClosure: (([ARTMessage], ARTCallback?) -> Void)?

    func publish(_ messages: [ARTMessage], callback: ARTCallback?) {
        publishCallbackCallsCount += 1
        publishCallbackReceivedArguments = (messages: messages, callback: callback)
        publishCallbackReceivedInvocations.append((messages: messages, callback: callback))
        publishCallbackClosure?(messages, callback)
    }

    //MARK: - attach

    var attachCallsCount = 0
    var attachCalled: Bool {
        return attachCallsCount > 0
    }
    var attachReceivedCallback: ARTCallback?
    var attachReceivedInvocations: [ARTCallback?] = []
    var attachClosure: ((ARTCallback?) -> Void)?

    func attach(_ callback: ARTCallback?) {
        attachCallsCount += 1
        attachReceivedCallback = callback
        attachReceivedInvocations.append(callback)
        attachClosure?(callback)
    }

}
class AblySDKRealtimeChannelsMock: AblySDKRealtimeChannels {

    //MARK: - getChannelFor

    var getChannelForTrackingIdOptionsCallsCount = 0
    var getChannelForTrackingIdOptionsCalled: Bool {
        return getChannelForTrackingIdOptionsCallsCount > 0
    }
    var getChannelForTrackingIdOptionsReceivedArguments: (trackingId: String, options: ARTRealtimeChannelOptions?)?
    var getChannelForTrackingIdOptionsReceivedInvocations: [(trackingId: String, options: ARTRealtimeChannelOptions?)] = []
    var getChannelForTrackingIdOptionsReturnValue: AblySDKRealtimeChannel!
    var getChannelForTrackingIdOptionsClosure: ((String, ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel)?

    func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel {
        getChannelForTrackingIdOptionsCallsCount += 1
        getChannelForTrackingIdOptionsReceivedArguments = (trackingId: trackingId, options: options)
        getChannelForTrackingIdOptionsReceivedInvocations.append((trackingId: trackingId, options: options))
        if let getChannelForTrackingIdOptionsClosure = getChannelForTrackingIdOptionsClosure {
            return getChannelForTrackingIdOptionsClosure(trackingId, options)
        } else {
            return getChannelForTrackingIdOptionsReturnValue
        }
    }

}
class AblySDKRealtimeFactoryMock: AblySDKRealtimeFactory {

    //MARK: - create

    var createWithConfigurationCallsCount = 0
    var createWithConfigurationCalled: Bool {
        return createWithConfigurationCallsCount > 0
    }
    var createWithConfigurationReceivedConfiguration: ConnectionConfiguration?
    var createWithConfigurationReceivedInvocations: [ConnectionConfiguration] = []
    var createWithConfigurationReturnValue: AblySDKRealtime!
    var createWithConfigurationClosure: ((ConnectionConfiguration) -> AblySDKRealtime)?

    func create(withConfiguration configuration: ConnectionConfiguration) -> AblySDKRealtime {
        createWithConfigurationCallsCount += 1
        createWithConfigurationReceivedConfiguration = configuration
        createWithConfigurationReceivedInvocations.append(configuration)
        if let createWithConfigurationClosure = createWithConfigurationClosure {
            return createWithConfigurationClosure(configuration)
        } else {
            return createWithConfigurationReturnValue
        }
    }

}
class AblySDKRealtimePresenceMock: AblySDKRealtimePresence {

    //MARK: - get

    var getCallsCount = 0
    var getCalled: Bool {
        return getCallsCount > 0
    }
    var getReceivedCallback: ARTPresenceMessagesCallback?
    var getReceivedInvocations: [ARTPresenceMessagesCallback] = []
    var getClosure: ((@escaping ARTPresenceMessagesCallback) -> Void)?

    func get(_ callback: @escaping ARTPresenceMessagesCallback) {
        getCallsCount += 1
        getReceivedCallback = callback
        getReceivedInvocations.append(callback)
        getClosure?(callback)
    }

    //MARK: - enter

    var enterCallbackCallsCount = 0
    var enterCallbackCalled: Bool {
        return enterCallbackCallsCount > 0
    }
    var enterCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    var enterCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    var enterCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    func enter(_ data: Any?, callback: ARTCallback?) {
        enterCallbackCallsCount += 1
        enterCallbackReceivedArguments = (data: data, callback: callback)
        enterCallbackReceivedInvocations.append((data: data, callback: callback))
        enterCallbackClosure?(data, callback)
    }

    //MARK: - update

    var updateCallbackCallsCount = 0
    var updateCallbackCalled: Bool {
        return updateCallbackCallsCount > 0
    }
    var updateCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    var updateCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    var updateCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    func update(_ data: Any?, callback: ARTCallback?) {
        updateCallbackCallsCount += 1
        updateCallbackReceivedArguments = (data: data, callback: callback)
        updateCallbackReceivedInvocations.append((data: data, callback: callback))
        updateCallbackClosure?(data, callback)
    }

    //MARK: - leave

    var leaveCallbackCallsCount = 0
    var leaveCallbackCalled: Bool {
        return leaveCallbackCallsCount > 0
    }
    var leaveCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    var leaveCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    var leaveCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    func leave(_ data: Any?, callback: ARTCallback?) {
        leaveCallbackCallsCount += 1
        leaveCallbackReceivedArguments = (data: data, callback: callback)
        leaveCallbackReceivedInvocations.append((data: data, callback: callback))
        leaveCallbackClosure?(data, callback)
    }

    //MARK: - subscribe

    var subscribeCallsCount = 0
    var subscribeCalled: Bool {
        return subscribeCallsCount > 0
    }
    var subscribeReceivedCallback: ARTPresenceMessageCallback?
    var subscribeReceivedInvocations: [ARTPresenceMessageCallback] = []
    var subscribeReturnValue: AblySDKEventListener?
    var subscribeClosure: ((@escaping ARTPresenceMessageCallback) -> AblySDKEventListener?)?

    @discardableResult
    func subscribe(_ callback: @escaping ARTPresenceMessageCallback) -> AblySDKEventListener? {
        subscribeCallsCount += 1
        subscribeReceivedCallback = callback
        subscribeReceivedInvocations.append(callback)
        if let subscribeClosure = subscribeClosure {
            return subscribeClosure(callback)
        } else {
            return subscribeReturnValue
        }
    }

    //MARK: - unsubscribe

    var unsubscribeCallsCount = 0
    var unsubscribeCalled: Bool {
        return unsubscribeCallsCount > 0
    }
    var unsubscribeClosure: (() -> Void)?

    func unsubscribe() {
        unsubscribeCallsCount += 1
        unsubscribeClosure?()
    }

}
class AblySubscriberDelegateMock: AblySubscriberDelegate {

    //MARK: - ablySubscriber

    var ablySubscriberDidChangeClientConnectionStateCallsCount = 0
    var ablySubscriberDidChangeClientConnectionStateCalled: Bool {
        return ablySubscriberDidChangeClientConnectionStateCallsCount > 0
    }
    var ablySubscriberDidChangeClientConnectionStateReceivedArguments: (sender: AblySubscriber, state: ConnectionState)?
    var ablySubscriberDidChangeClientConnectionStateReceivedInvocations: [(sender: AblySubscriber, state: ConnectionState)] = []
    var ablySubscriberDidChangeClientConnectionStateClosure: ((AblySubscriber, ConnectionState) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState) {
        ablySubscriberDidChangeClientConnectionStateCallsCount += 1
        ablySubscriberDidChangeClientConnectionStateReceivedArguments = (sender: sender, state: state)
        ablySubscriberDidChangeClientConnectionStateReceivedInvocations.append((sender: sender, state: state))
        ablySubscriberDidChangeClientConnectionStateClosure?(sender, state)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidChangeChannelConnectionStateCallsCount = 0
    var ablySubscriberDidChangeChannelConnectionStateCalled: Bool {
        return ablySubscriberDidChangeChannelConnectionStateCallsCount > 0
    }
    var ablySubscriberDidChangeChannelConnectionStateReceivedArguments: (sender: AblySubscriber, state: ConnectionState)?
    var ablySubscriberDidChangeChannelConnectionStateReceivedInvocations: [(sender: AblySubscriber, state: ConnectionState)] = []
    var ablySubscriberDidChangeChannelConnectionStateClosure: ((AblySubscriber, ConnectionState) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState) {
        ablySubscriberDidChangeChannelConnectionStateCallsCount += 1
        ablySubscriberDidChangeChannelConnectionStateReceivedArguments = (sender: sender, state: state)
        ablySubscriberDidChangeChannelConnectionStateReceivedInvocations.append((sender: sender, state: state))
        ablySubscriberDidChangeChannelConnectionStateClosure?(sender, state)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidReceivePresenceUpdateCallsCount = 0
    var ablySubscriberDidReceivePresenceUpdateCalled: Bool {
        return ablySubscriberDidReceivePresenceUpdateCallsCount > 0
    }
    var ablySubscriberDidReceivePresenceUpdateReceivedArguments: (sender: AblySubscriber, presence: Presence)?
    var ablySubscriberDidReceivePresenceUpdateReceivedInvocations: [(sender: AblySubscriber, presence: Presence)] = []
    var ablySubscriberDidReceivePresenceUpdateClosure: ((AblySubscriber, Presence) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didReceivePresenceUpdate presence: Presence) {
        ablySubscriberDidReceivePresenceUpdateCallsCount += 1
        ablySubscriberDidReceivePresenceUpdateReceivedArguments = (sender: sender, presence: presence)
        ablySubscriberDidReceivePresenceUpdateReceivedInvocations.append((sender: sender, presence: presence))
        ablySubscriberDidReceivePresenceUpdateClosure?(sender, presence)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidFailWithErrorCallsCount = 0
    var ablySubscriberDidFailWithErrorCalled: Bool {
        return ablySubscriberDidFailWithErrorCallsCount > 0
    }
    var ablySubscriberDidFailWithErrorReceivedArguments: (sender: AblySubscriber, error: ErrorInformation)?
    var ablySubscriberDidFailWithErrorReceivedInvocations: [(sender: AblySubscriber, error: ErrorInformation)] = []
    var ablySubscriberDidFailWithErrorClosure: ((AblySubscriber, ErrorInformation) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didFailWithError error: ErrorInformation) {
        ablySubscriberDidFailWithErrorCallsCount += 1
        ablySubscriberDidFailWithErrorReceivedArguments = (sender: sender, error: error)
        ablySubscriberDidFailWithErrorReceivedInvocations.append((sender: sender, error: error))
        ablySubscriberDidFailWithErrorClosure?(sender, error)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidReceiveEnhancedLocationCallsCount = 0
    var ablySubscriberDidReceiveEnhancedLocationCalled: Bool {
        return ablySubscriberDidReceiveEnhancedLocationCallsCount > 0
    }
    var ablySubscriberDidReceiveEnhancedLocationReceivedArguments: (sender: AblySubscriber, locationUpdate: LocationUpdate)?
    var ablySubscriberDidReceiveEnhancedLocationReceivedInvocations: [(sender: AblySubscriber, locationUpdate: LocationUpdate)] = []
    var ablySubscriberDidReceiveEnhancedLocationClosure: ((AblySubscriber, LocationUpdate) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didReceiveEnhancedLocation locationUpdate: LocationUpdate) {
        ablySubscriberDidReceiveEnhancedLocationCallsCount += 1
        ablySubscriberDidReceiveEnhancedLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        ablySubscriberDidReceiveEnhancedLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        ablySubscriberDidReceiveEnhancedLocationClosure?(sender, locationUpdate)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidReceiveRawLocationCallsCount = 0
    var ablySubscriberDidReceiveRawLocationCalled: Bool {
        return ablySubscriberDidReceiveRawLocationCallsCount > 0
    }
    var ablySubscriberDidReceiveRawLocationReceivedArguments: (sender: AblySubscriber, locationUpdate: LocationUpdate)?
    var ablySubscriberDidReceiveRawLocationReceivedInvocations: [(sender: AblySubscriber, locationUpdate: LocationUpdate)] = []
    var ablySubscriberDidReceiveRawLocationClosure: ((AblySubscriber, LocationUpdate) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didReceiveRawLocation locationUpdate: LocationUpdate) {
        ablySubscriberDidReceiveRawLocationCallsCount += 1
        ablySubscriberDidReceiveRawLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        ablySubscriberDidReceiveRawLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        ablySubscriberDidReceiveRawLocationClosure?(sender, locationUpdate)
    }

    //MARK: - ablySubscriber

    var ablySubscriberDidReceiveResolutionCallsCount = 0
    var ablySubscriberDidReceiveResolutionCalled: Bool {
        return ablySubscriberDidReceiveResolutionCallsCount > 0
    }
    var ablySubscriberDidReceiveResolutionReceivedArguments: (sender: AblySubscriber, resolution: Resolution)?
    var ablySubscriberDidReceiveResolutionReceivedInvocations: [(sender: AblySubscriber, resolution: Resolution)] = []
    var ablySubscriberDidReceiveResolutionClosure: ((AblySubscriber, Resolution) -> Void)?

    func ablySubscriber(_ sender: AblySubscriber, didReceiveResolution resolution: Resolution) {
        ablySubscriberDidReceiveResolutionCallsCount += 1
        ablySubscriberDidReceiveResolutionReceivedArguments = (sender: sender, resolution: resolution)
        ablySubscriberDidReceiveResolutionReceivedInvocations.append((sender: sender, resolution: resolution))
        ablySubscriberDidReceiveResolutionClosure?(sender, resolution)
    }

}
