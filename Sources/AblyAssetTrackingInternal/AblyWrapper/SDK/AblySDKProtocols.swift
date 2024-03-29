import Ably
import AblyAssetTrackingCore

// swiftlint:disable missing_docs

// sourcery: AutoMockable
public protocol AblySDKRealtimeFactory {
    func create(withConfiguration configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler, host: Host?) -> AblySDKRealtime
}

// sourcery: AutoMockable
public protocol AblySDKRealtime {
    var channels: AblySDKRealtimeChannels { get }
    var connection: AblySDKConnection { get }
    var auth: AblySDKAuth { get }
    func connect()
    func close()
}

// sourcery: AutoMockable
public protocol AblySDKRealtimeChannels {
    func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel
}

// sourcery: AutoMockable
public protocol AblySDKRealtimeChannel {
    var presence: AblySDKRealtimePresence { get }

    @discardableResult
    func subscribe(_ name: String, callback: @escaping ARTMessageCallback) -> ARTEventListener?

    func unsubscribe()

    func detach(_ callback: ARTCallback?)

    @discardableResult
    func on(_ callback: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener

    func publish(_ messages: [ARTMessage], callback: ARTCallback?)

    func attach(_ callback: ARTCallback?)

    var state: ARTRealtimeChannelState { get }
}

// sourcery: AutoMockable
public protocol AblySDKRealtimePresence {
    func get(_ callback: @escaping ARTPresenceMessagesCallback)

    func enter(_ data: Any?, callback: ARTCallback?)

    func update(_ data: Any?, callback: ARTCallback?)

    func leave(_ data: Any?, callback: ARTCallback?)

    @discardableResult
    func subscribe(_ callback: @escaping ARTPresenceMessageCallback) -> ARTEventListener?

    func unsubscribe()
}

// sourcery: AutoMockable
public protocol AblySDKConnection {
    var state: ARTRealtimeConnectionState {get}
    var errorReason: ARTErrorInfo? {get}

    @discardableResult
    func on(_ callback: @escaping (ARTConnectionStateChange) -> Void) -> ARTEventListener

    func off(_ listener: ARTEventListener)
}

// sourcery: AutoMockable
public protocol AblySDKAuth {
    func authorize(_ callback: @escaping ARTTokenDetailsCallback)
}
