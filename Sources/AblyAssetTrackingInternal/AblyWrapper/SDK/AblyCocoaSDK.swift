import Ably
import AblyAssetTrackingCore

struct AblyCocoaSDKRealtime: AblySDKRealtime {
    fileprivate let realtime: ARTRealtime

    var channels: AblySDKRealtimeChannels {
        AblyCocoaSDKRealtimeChannels(channels: realtime.channels)
    }

    var connection: AblySDKConnection {
        AblyCocoaSDKConnection(connection: realtime.connection)
    }

    var auth: AblySDKAuth {
        AblyCocoaSDKAuth(auth: realtime.auth)
    }

    func connect() {
        realtime.connect()
    }

    func close() {
        realtime.close()
    }
}

struct AblyCocoaSDKRealtimeChannels: AblySDKRealtimeChannels {
    fileprivate let channels: ARTRealtimeChannels

    func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions?) -> AblySDKRealtimeChannel {
        let channel = channels.getChannelFor(trackingId: trackingId, options: options)
        return AblyCocoaSDKRealtimeChannel(channel: channel)
    }
}

struct AblyCocoaSDKRealtimeChannel: AblySDKRealtimeChannel {
    fileprivate let channel: ARTRealtimeChannel

    var presence: AblySDKRealtimePresence {
        AblyCocoaSDKRealtimePresence(presence: channel.presence)
    }
    
    func subscribe(_ name: String, callback: @escaping (ARTMessage) -> Void) -> ARTEventListener? {
        if let eventListener = channel.subscribe(name, callback: callback) {
            return eventListener
        } else {
            return nil
        }
    }

    func unsubscribe() {
        channel.unsubscribe()
    }

    func detach(_ callback: ARTCallback?) {
        channel.detach(callback)
    }
    
    func on(_ callback: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener {
        return channel.on(callback)
    }

    func publish(_ messages: [ARTMessage], callback: ARTCallback?) {
        channel.publish(messages, callback: callback)
    }

    func attach(_ callback: ARTCallback?) {
        channel.attach(callback)
    }

    var state: ARTRealtimeChannelState {
        channel.state
    }
}

struct AblyCocoaSDKRealtimePresence: AblySDKRealtimePresence {
    fileprivate let presence: ARTRealtimePresence

    func get(_ callback: @escaping ([ARTPresenceMessage]?, ARTErrorInfo?) -> Void) {
        presence.get(callback)
    }

    func enter(_ data: Any?, callback: ARTCallback?) {
        presence.enter(data, callback: callback)
    }

    func update(_ data: Any?, callback: ARTCallback?) {
        presence.update(data, callback: callback)
    }

    func leave(_ data: Any?, callback: ARTCallback?) {
        presence.leave(data, callback: callback)
    }

    func subscribe(_ callback: @escaping (ARTPresenceMessage) -> Void) -> ARTEventListener? {
        if let eventListener = presence.subscribe(callback) {
            return eventListener
        } else {
            return nil
        }
    }

    func unsubscribe() {
        presence.unsubscribe()
    }
}

struct AblyCocoaSDKConnection: AblySDKConnection {
    fileprivate let connection: ARTConnection
    var state: ARTRealtimeConnectionState {
        get {
            return self.connection.state
        }
    }

    var errorReason: ARTErrorInfo? {
        get {
            return self.connection.errorReason
        }
    }
    
    func on(_ callback: @escaping (ARTConnectionStateChange) -> Void) -> ARTEventListener {
        return connection.on(callback)
    }

    func off(_ listener: ARTEventListener) {
        connection.off(listener)
    }
}

struct AblyCocoaSDKAuth: AblySDKAuth {
    fileprivate let auth: ARTAuth

    func authorize(_ callback: @escaping (ARTTokenDetails?, Error?) -> Void) {
        auth.authorize(callback)
    }
}

public class AblyCocoaSDKRealtimeFactory: AblySDKRealtimeFactory {
    public init() {}

    public func create(withConfiguration configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler, host: Host?) -> AblySDKRealtime {
        let clientOptions = configuration.getClientOptions(
            logHandler: logHandler,
            remainPresentForMilliseconds: configuration.remainPresentForMilliseconds,
            host: host
        )

        let realtime = ARTRealtime(options: clientOptions)
        return AblyCocoaSDKRealtime(realtime: realtime)
    }
}
