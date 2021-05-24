import Ably

private let trackingChannelNamespace = "tracking"

extension ARTRealtimeChannels {
    func getChannelFor(trackingId: String, options: ARTRealtimeChannelOptions? = nil) -> ARTRealtimeChannel {
        let segments = [trackingChannelNamespace, trackingId]
        let channelName = segments.joined(separator: ":")
        if let options = options {
            return self.get(channelName, options: options);
        }
        return self.get(channelName)
    }
}
