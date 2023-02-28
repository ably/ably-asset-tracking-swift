import Ably
import AblyAssetTrackingCore

struct AblyCocoaSDKRealtime: AblySDKRealtime {
    fileprivate let realtime: ARTRealtime
    
    var channels: AblySDKRealtimeChannels {
        return AblyCocoaSDKRealtimeChannels(channels: realtime.channels)
    }
    
    var connection: AblySDKConnection {
        return AblyCocoaSDKConnection(connection: realtime.connection)
    }
    
    var auth: AblySDKAuth {
        return AblyCocoaSDKAuth(auth: realtime.auth)
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
        return AblyCocoaSDKRealtimePresence(presence: channel.presence)
    }
    
    func subscribe(_ name: String, callback: @escaping (ARTMessage) -> Void) -> AblySDKEventListener? {
        if let eventListener = channel.subscribe(name, callback: callback) {
            return AblyCocoaSDKEventListener(eventListener: eventListener)
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
    
    func on(_ callback: @escaping (ARTChannelStateChange) -> ()) -> AblySDKEventListener {
        return AblyCocoaSDKEventListener(eventListener: channel.on(callback))
    }
    
    func publish(_ messages: [ARTMessage], callback: ARTCallback?) {
        channel.publish(messages, callback: callback)
    }
    
    func attach(_ callback: ARTCallback?) {
        channel.attach(callback)
    }
    
    var state: ARTRealtimeChannelState {
        return channel.state
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
    
    func subscribe(_ callback: @escaping (ARTPresenceMessage) -> Void) -> AblySDKEventListener? {
        if let eventListener = presence.subscribe(callback) {
            return AblyCocoaSDKEventListener(eventListener: eventListener)
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
    
    func on(_ callback: @escaping (ARTConnectionStateChange) -> Void) -> AblySDKEventListener {
        return AblyCocoaSDKEventListener(eventListener: connection.on(callback))
    }

    func off(_ listener: AblySDKEventListener) {
        connection.off(listener.underlyingListener())
    }
}

struct AblyCocoaSDKAuth: AblySDKAuth {
    fileprivate let auth: ARTAuth
    
    func authorize(_ callback: @escaping (ARTTokenDetails?, Error?) -> Void) {
        auth.authorize(callback)
    }
}

struct AblyCocoaSDKEventListener: AblySDKEventListener {
    fileprivate let eventListener: ARTEventListener

    func underlyingListener() -> ARTEventListener {
        return eventListener
    }
}

public class AblyCocoaSDKRealtimeFactory: AblySDKRealtimeFactory {
    public init() {}
    
    public func create(withConfiguration configuration: ConnectionConfiguration, logHandler: InternalARTLogHandler) -> AblySDKRealtime {
        let realtime = ARTRealtime(options: configuration.getClientOptions(logHandler: logHandler, remainPresentForMilliseconds: configuration.remainPresentForMilliseconds))
        return AblyCocoaSDKRealtime(realtime: realtime)
    }
}
