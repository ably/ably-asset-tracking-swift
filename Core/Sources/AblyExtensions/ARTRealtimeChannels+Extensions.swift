import Ably

let CHANNEL_NAME_PREFIX = "tracking"

extension ARTRealtimeChannels {
    public func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions? = nil) -> ARTRealtimeChannel {
        let segments = [CHANNEL_NAME_PREFIX, trackingId]
        let channelName = segments.joined(separator: ":")
        if let options = options {
            return self.get(channelName, options: options);
        }
        return self.get(channelName)
    }
}
