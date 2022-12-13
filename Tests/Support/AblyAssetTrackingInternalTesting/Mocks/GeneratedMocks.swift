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

import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import Ably





















public class AblySDKAuthMock: AblySDKAuth {

    public init() {}


    //MARK: - authorize

    public var authorizeCallsCount = 0
    public var authorizeCalled: Bool {
        return authorizeCallsCount > 0
    }
    public var authorizeReceivedCallback: ARTTokenDetailsCallback?
    public var authorizeReceivedInvocations: [ARTTokenDetailsCallback] = []
    public var authorizeClosure: ((@escaping ARTTokenDetailsCallback) -> Void)?

    public func authorize(_ callback: @escaping ARTTokenDetailsCallback) {
        authorizeCallsCount += 1
        authorizeReceivedCallback = callback
        authorizeReceivedInvocations.append(callback)
        authorizeClosure?(callback)
    }

}
public class AblySDKConnectionMock: AblySDKConnection {

    public init() {}


    //MARK: - on

    public var onCallsCount = 0
    public var onCalled: Bool {
        return onCallsCount > 0
    }
    public var onReceivedCallback: ((ARTConnectionStateChange) -> Void)?
    public var onReceivedInvocations: [((ARTConnectionStateChange) -> Void)] = []
    public var onReturnValue: AblySDKEventListener!
    public var onClosure: ((@escaping (ARTConnectionStateChange) -> Void) -> AblySDKEventListener)?

    @discardableResult
    public func on(_ callback: @escaping (ARTConnectionStateChange) -> Void) -> AblySDKEventListener {
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
public class AblySDKEventListenerMock: AblySDKEventListener {

    public init() {}


}
public class AblySDKRealtimeMock: AblySDKRealtime {

    public init() {}

    public var channels: AblySDKRealtimeChannels {
        get { return underlyingChannels }
        set(value) { underlyingChannels = value }
    }
    public var underlyingChannels: AblySDKRealtimeChannels!
    public var connection: AblySDKConnection {
        get { return underlyingConnection }
        set(value) { underlyingConnection = value }
    }
    public var underlyingConnection: AblySDKConnection!
    public var auth: AblySDKAuth {
        get { return underlyingAuth }
        set(value) { underlyingAuth = value }
    }
    public var underlyingAuth: AblySDKAuth!

    //MARK: - close

    public var closeCallsCount = 0
    public var closeCalled: Bool {
        return closeCallsCount > 0
    }
    public var closeClosure: (() -> Void)?

    public func close() {
        closeCallsCount += 1
        closeClosure?()
    }

}
public class AblySDKRealtimeChannelMock: AblySDKRealtimeChannel {

    public init() {}

    public var presence: AblySDKRealtimePresence {
        get { return underlyingPresence }
        set(value) { underlyingPresence = value }
    }
    public var underlyingPresence: AblySDKRealtimePresence!
    public var state: ARTRealtimeChannelState {
        get { return underlyingState }
        set(value) { underlyingState = value }
    }
    public var underlyingState: ARTRealtimeChannelState!

    //MARK: - subscribe

    public var subscribeCallbackCallsCount = 0
    public var subscribeCallbackCalled: Bool {
        return subscribeCallbackCallsCount > 0
    }
    public var subscribeCallbackReceivedArguments: (name: String, callback: ARTMessageCallback)?
    public var subscribeCallbackReceivedInvocations: [(name: String, callback: ARTMessageCallback)] = []
    public var subscribeCallbackReturnValue: AblySDKEventListener?
    public var subscribeCallbackClosure: ((String, @escaping ARTMessageCallback) -> AblySDKEventListener?)?

    @discardableResult
    public func subscribe(_ name: String, callback: @escaping ARTMessageCallback) -> AblySDKEventListener? {
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

    public var unsubscribeCallsCount = 0
    public var unsubscribeCalled: Bool {
        return unsubscribeCallsCount > 0
    }
    public var unsubscribeClosure: (() -> Void)?

    public func unsubscribe() {
        unsubscribeCallsCount += 1
        unsubscribeClosure?()
    }

    //MARK: - detach

    public var detachCallsCount = 0
    public var detachCalled: Bool {
        return detachCallsCount > 0
    }
    public var detachReceivedCallback: ARTCallback?
    public var detachReceivedInvocations: [ARTCallback?] = []
    public var detachClosure: ((ARTCallback?) -> Void)?

    public func detach(_ callback: ARTCallback?) {
        detachCallsCount += 1
        detachReceivedCallback = callback
        detachReceivedInvocations.append(callback)
        detachClosure?(callback)
    }

    //MARK: - on

    public var onCallsCount = 0
    public var onCalled: Bool {
        return onCallsCount > 0
    }
    public var onReceivedCallback: ((ARTChannelStateChange) -> ())?
    public var onReceivedInvocations: [((ARTChannelStateChange) -> ())] = []
    public var onReturnValue: AblySDKEventListener!
    public var onClosure: ((@escaping (ARTChannelStateChange) -> ()) -> AblySDKEventListener)?

    @discardableResult
    public func on(_ callback: @escaping (ARTChannelStateChange) -> ()) -> AblySDKEventListener {
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

    public var publishCallbackCallsCount = 0
    public var publishCallbackCalled: Bool {
        return publishCallbackCallsCount > 0
    }
    public var publishCallbackReceivedArguments: (messages: [ARTMessage], callback: ARTCallback?)?
    public var publishCallbackReceivedInvocations: [(messages: [ARTMessage], callback: ARTCallback?)] = []
    public var publishCallbackClosure: (([ARTMessage], ARTCallback?) -> Void)?

    public func publish(_ messages: [ARTMessage], callback: ARTCallback?) {
        publishCallbackCallsCount += 1
        publishCallbackReceivedArguments = (messages: messages, callback: callback)
        publishCallbackReceivedInvocations.append((messages: messages, callback: callback))
        publishCallbackClosure?(messages, callback)
    }

    //MARK: - attach

    public var attachCallsCount = 0
    public var attachCalled: Bool {
        return attachCallsCount > 0
    }
    public var attachReceivedCallback: ARTCallback?
    public var attachReceivedInvocations: [ARTCallback?] = []
    public var attachClosure: ((ARTCallback?) -> Void)?

    public func attach(_ callback: ARTCallback?) {
        attachCallsCount += 1
        attachReceivedCallback = callback
        attachReceivedInvocations.append(callback)
        attachClosure?(callback)
    }

}
public class AblySDKRealtimeChannelsMock: AblySDKRealtimeChannels {

    public init() {}


    //MARK: - getChannelFor

    public var getChannelForTrackingIdOptionsCallsCount = 0
    public var getChannelForTrackingIdOptionsCalled: Bool {
        return getChannelForTrackingIdOptionsCallsCount > 0
    }
    public var getChannelForTrackingIdOptionsReceivedArguments: (trackingId: String, options: ARTRealtimeChannelOptions?)?
    public var getChannelForTrackingIdOptionsReceivedInvocations: [(trackingId: String, options: ARTRealtimeChannelOptions?)] = []
    public var getChannelForTrackingIdOptionsReturnValue: AblySDKRealtimeChannel!
    public var getChannelForTrackingIdOptionsClosure: ((String, ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel)?

    public func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel {
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
public class AblySDKRealtimeFactoryMock: AblySDKRealtimeFactory {

    public init() {}


    //MARK: - create

    public var createWithConfigurationLogHandlerCallsCount = 0
    public var createWithConfigurationLogHandlerCalled: Bool {
        return createWithConfigurationLogHandlerCallsCount > 0
    }
    public var createWithConfigurationLogHandlerReceivedArguments: (configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler)?
    public var createWithConfigurationLogHandlerReceivedInvocations: [(configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler)] = []
    public var createWithConfigurationLogHandlerReturnValue: AblySDKRealtime!
    public var createWithConfigurationLogHandlerClosure: ((ConnectionConfiguration, InternalARTLogHandler) -> AblySDKRealtime)?

    public func create(withConfiguration configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler) -> AblySDKRealtime {
        createWithConfigurationLogHandlerCallsCount += 1
        createWithConfigurationLogHandlerReceivedArguments = (configuration: configuration, logHandler: logHandler)
        createWithConfigurationLogHandlerReceivedInvocations.append((configuration: configuration, logHandler: logHandler))
        if let createWithConfigurationLogHandlerClosure = createWithConfigurationLogHandlerClosure {
            return createWithConfigurationLogHandlerClosure(configuration, logHandler)
        } else {
            return createWithConfigurationLogHandlerReturnValue
        }
    }

}
public class AblySDKRealtimePresenceMock: AblySDKRealtimePresence {

    public init() {}


    //MARK: - get

    public var getCallsCount = 0
    public var getCalled: Bool {
        return getCallsCount > 0
    }
    public var getReceivedCallback: ARTPresenceMessagesCallback?
    public var getReceivedInvocations: [ARTPresenceMessagesCallback] = []
    public var getClosure: ((@escaping ARTPresenceMessagesCallback) -> Void)?

    public func get(_ callback: @escaping ARTPresenceMessagesCallback) {
        getCallsCount += 1
        getReceivedCallback = callback
        getReceivedInvocations.append(callback)
        getClosure?(callback)
    }

    //MARK: - enter

    public var enterCallbackCallsCount = 0
    public var enterCallbackCalled: Bool {
        return enterCallbackCallsCount > 0
    }
    public var enterCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    public var enterCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    public var enterCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    public func enter(_ data: Any?, callback: ARTCallback?) {
        enterCallbackCallsCount += 1
        enterCallbackReceivedArguments = (data: data, callback: callback)
        enterCallbackReceivedInvocations.append((data: data, callback: callback))
        enterCallbackClosure?(data, callback)
    }

    //MARK: - update

    public var updateCallbackCallsCount = 0
    public var updateCallbackCalled: Bool {
        return updateCallbackCallsCount > 0
    }
    public var updateCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    public var updateCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    public var updateCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    public func update(_ data: Any?, callback: ARTCallback?) {
        updateCallbackCallsCount += 1
        updateCallbackReceivedArguments = (data: data, callback: callback)
        updateCallbackReceivedInvocations.append((data: data, callback: callback))
        updateCallbackClosure?(data, callback)
    }

    //MARK: - leave

    public var leaveCallbackCallsCount = 0
    public var leaveCallbackCalled: Bool {
        return leaveCallbackCallsCount > 0
    }
    public var leaveCallbackReceivedArguments: (data: Any?, callback: ARTCallback?)?
    public var leaveCallbackReceivedInvocations: [(data: Any?, callback: ARTCallback?)] = []
    public var leaveCallbackClosure: ((Any?, ARTCallback?) -> Void)?

    public func leave(_ data: Any?, callback: ARTCallback?) {
        leaveCallbackCallsCount += 1
        leaveCallbackReceivedArguments = (data: data, callback: callback)
        leaveCallbackReceivedInvocations.append((data: data, callback: callback))
        leaveCallbackClosure?(data, callback)
    }

    //MARK: - subscribe

    public var subscribeCallsCount = 0
    public var subscribeCalled: Bool {
        return subscribeCallsCount > 0
    }
    public var subscribeReceivedCallback: ARTPresenceMessageCallback?
    public var subscribeReceivedInvocations: [ARTPresenceMessageCallback] = []
    public var subscribeReturnValue: AblySDKEventListener?
    public var subscribeClosure: ((@escaping ARTPresenceMessageCallback) -> AblySDKEventListener?)?

    @discardableResult
    public func subscribe(_ callback: @escaping ARTPresenceMessageCallback) -> AblySDKEventListener? {
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

    public var unsubscribeCallsCount = 0
    public var unsubscribeCalled: Bool {
        return unsubscribeCallsCount > 0
    }
    public var unsubscribeClosure: (() -> Void)?

    public func unsubscribe() {
        unsubscribeCallsCount += 1
        unsubscribeClosure?()
    }

}
public class AblySubscriberDelegateMock: AblySubscriberDelegate {

    public init() {}


    //MARK: - ablySubscriber

    public var ablySubscriberDidChangeClientConnectionStateCallsCount = 0
    public var ablySubscriberDidChangeClientConnectionStateCalled: Bool {
        return ablySubscriberDidChangeClientConnectionStateCallsCount > 0
    }
    public var ablySubscriberDidChangeClientConnectionStateReceivedArguments: (sender: AblySubscriber, state: ConnectionState)?
    public var ablySubscriberDidChangeClientConnectionStateReceivedInvocations: [(sender: AblySubscriber, state: ConnectionState)] = []
    public var ablySubscriberDidChangeClientConnectionStateClosure: ((AblySubscriber, ConnectionState) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState) {
        ablySubscriberDidChangeClientConnectionStateCallsCount += 1
        ablySubscriberDidChangeClientConnectionStateReceivedArguments = (sender: sender, state: state)
        ablySubscriberDidChangeClientConnectionStateReceivedInvocations.append((sender: sender, state: state))
        ablySubscriberDidChangeClientConnectionStateClosure?(sender, state)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidChangeChannelConnectionStateCallsCount = 0
    public var ablySubscriberDidChangeChannelConnectionStateCalled: Bool {
        return ablySubscriberDidChangeChannelConnectionStateCallsCount > 0
    }
    public var ablySubscriberDidChangeChannelConnectionStateReceivedArguments: (sender: AblySubscriber, state: ConnectionState)?
    public var ablySubscriberDidChangeChannelConnectionStateReceivedInvocations: [(sender: AblySubscriber, state: ConnectionState)] = []
    public var ablySubscriberDidChangeChannelConnectionStateClosure: ((AblySubscriber, ConnectionState) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState) {
        ablySubscriberDidChangeChannelConnectionStateCallsCount += 1
        ablySubscriberDidChangeChannelConnectionStateReceivedArguments = (sender: sender, state: state)
        ablySubscriberDidChangeChannelConnectionStateReceivedInvocations.append((sender: sender, state: state))
        ablySubscriberDidChangeChannelConnectionStateClosure?(sender, state)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidReceivePresenceUpdateCallsCount = 0
    public var ablySubscriberDidReceivePresenceUpdateCalled: Bool {
        return ablySubscriberDidReceivePresenceUpdateCallsCount > 0
    }
    public var ablySubscriberDidReceivePresenceUpdateReceivedArguments: (sender: AblySubscriber, presence: Presence)?
    public var ablySubscriberDidReceivePresenceUpdateReceivedInvocations: [(sender: AblySubscriber, presence: Presence)] = []
    public var ablySubscriberDidReceivePresenceUpdateClosure: ((AblySubscriber, Presence) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didReceivePresenceUpdate presence: Presence) {
        ablySubscriberDidReceivePresenceUpdateCallsCount += 1
        ablySubscriberDidReceivePresenceUpdateReceivedArguments = (sender: sender, presence: presence)
        ablySubscriberDidReceivePresenceUpdateReceivedInvocations.append((sender: sender, presence: presence))
        ablySubscriberDidReceivePresenceUpdateClosure?(sender, presence)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidFailWithErrorCallsCount = 0
    public var ablySubscriberDidFailWithErrorCalled: Bool {
        return ablySubscriberDidFailWithErrorCallsCount > 0
    }
    public var ablySubscriberDidFailWithErrorReceivedArguments: (sender: AblySubscriber, error: ErrorInformation)?
    public var ablySubscriberDidFailWithErrorReceivedInvocations: [(sender: AblySubscriber, error: ErrorInformation)] = []
    public var ablySubscriberDidFailWithErrorClosure: ((AblySubscriber, ErrorInformation) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didFailWithError error: ErrorInformation) {
        ablySubscriberDidFailWithErrorCallsCount += 1
        ablySubscriberDidFailWithErrorReceivedArguments = (sender: sender, error: error)
        ablySubscriberDidFailWithErrorReceivedInvocations.append((sender: sender, error: error))
        ablySubscriberDidFailWithErrorClosure?(sender, error)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidReceiveEnhancedLocationCallsCount = 0
    public var ablySubscriberDidReceiveEnhancedLocationCalled: Bool {
        return ablySubscriberDidReceiveEnhancedLocationCallsCount > 0
    }
    public var ablySubscriberDidReceiveEnhancedLocationReceivedArguments: (sender: AblySubscriber, locationUpdate: LocationUpdate)?
    public var ablySubscriberDidReceiveEnhancedLocationReceivedInvocations: [(sender: AblySubscriber, locationUpdate: LocationUpdate)] = []
    public var ablySubscriberDidReceiveEnhancedLocationClosure: ((AblySubscriber, LocationUpdate) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didReceiveEnhancedLocation locationUpdate: LocationUpdate) {
        ablySubscriberDidReceiveEnhancedLocationCallsCount += 1
        ablySubscriberDidReceiveEnhancedLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        ablySubscriberDidReceiveEnhancedLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        ablySubscriberDidReceiveEnhancedLocationClosure?(sender, locationUpdate)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidReceiveRawLocationCallsCount = 0
    public var ablySubscriberDidReceiveRawLocationCalled: Bool {
        return ablySubscriberDidReceiveRawLocationCallsCount > 0
    }
    public var ablySubscriberDidReceiveRawLocationReceivedArguments: (sender: AblySubscriber, locationUpdate: LocationUpdate)?
    public var ablySubscriberDidReceiveRawLocationReceivedInvocations: [(sender: AblySubscriber, locationUpdate: LocationUpdate)] = []
    public var ablySubscriberDidReceiveRawLocationClosure: ((AblySubscriber, LocationUpdate) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didReceiveRawLocation locationUpdate: LocationUpdate) {
        ablySubscriberDidReceiveRawLocationCallsCount += 1
        ablySubscriberDidReceiveRawLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        ablySubscriberDidReceiveRawLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        ablySubscriberDidReceiveRawLocationClosure?(sender, locationUpdate)
    }

    //MARK: - ablySubscriber

    public var ablySubscriberDidReceiveResolutionCallsCount = 0
    public var ablySubscriberDidReceiveResolutionCalled: Bool {
        return ablySubscriberDidReceiveResolutionCallsCount > 0
    }
    public var ablySubscriberDidReceiveResolutionReceivedArguments: (sender: AblySubscriber, resolution: Resolution)?
    public var ablySubscriberDidReceiveResolutionReceivedInvocations: [(sender: AblySubscriber, resolution: Resolution)] = []
    public var ablySubscriberDidReceiveResolutionClosure: ((AblySubscriber, Resolution) -> Void)?

    public func ablySubscriber(_ sender: AblySubscriber, didReceiveResolution resolution: Resolution) {
        ablySubscriberDidReceiveResolutionCallsCount += 1
        ablySubscriberDidReceiveResolutionReceivedArguments = (sender: sender, resolution: resolution)
        ablySubscriberDidReceiveResolutionReceivedInvocations.append((sender: sender, resolution: resolution))
        ablySubscriberDidReceiveResolutionClosure?(sender, resolution)
    }

}