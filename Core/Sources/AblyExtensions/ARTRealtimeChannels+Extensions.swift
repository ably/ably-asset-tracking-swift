import Ably

private let channelNamePrefix = "tracking"

extension ARTRealtimeChannels {
    public func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions? = nil) -> ARTRealtimeChannel {
        let segments = [channelNamePrefix, trackingId]
        let channelName = segments.joined(separator: ":")
        if let options = options {
            return self.get(channelName, options: options);
        }
        return self.get(channelName)
    }
}
