// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import Ably
















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
