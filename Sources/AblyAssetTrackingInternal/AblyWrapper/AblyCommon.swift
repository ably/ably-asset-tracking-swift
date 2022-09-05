import AblyAssetTrackingCore
import Logging

public protocol AblyCommon {
    /**
     Observe for the `ARTRealtime` state updates.
     */
    func subscribeForAblyStateChange()
    
    /**
     Observe  for the channel state updates.
     
     Subscription should be able  only when there's an existing channel for the `trackable.id`
     
     - Parameter trackable: The `Trackable` object
     */
    func subscribeForChannelStateChange(trackable: Trackable)
    
    /**
     Observe  for the presence messages that are received from the channel's presence.
     
     Subscription should be able  only when there's an existing channel for the `trackable.id`
     
     - Parameter trackable:  The `Trackable` object
     */
    func subscribeForPresenceMessages(trackable: Trackable)
    
    /**
     Updates presence data in the `trackableId` channel's presence.
     
     Should be called only when there's an existing channel for the `trackableId`.
     If a channel for the `trackableId` doesn't exist then nothing happens.
     
     - Parameter trackableId:    The ID of the trackable channel.
     - Parameter presenceData:   The data that will be send via the presence channel.
     - Parameter callback:       The closure that will be called when updating presence data completes. If something goes wrong it will be called with an `error`object.
     */
    func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: ResultHandler<Void>?)
    
    /**
     Joins the presence of the channel for the given `trackableId` and add it to the connected channels.
     
     If successfully joined the presence then the channel is added to the connected channels.
     If a channel for the given `trackableId` exists then it just calls `completion` with success.
     
     - Parameter trackableId:   The ID of the trackable channel.
     - Parameter presenceData:  The data that will be send via the presence channel.
     - Parameter useRewind:     If set to true then after connecting the channel will replay the last event that was sent in it.
     - Parameter completion:    The closure that will be called when connecting completes. If something goes wrong it will be called with `error` object.
     */
    func connect(trackableId: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>)
    
    /**
     Removes the `trackableId` channel from the connected channels and leaves the presence of that channel.
     
     If a channel for the given `trackableId` doesn't exist then it just calls `completion` with success.
     
     - Parameter trackableId:   The ID of the trackable channel.
     - Parameter presenceData:  The data that will be send via the presence channel.
     - Parameter completion:    The closure that will be called when disconnecting completes. If something goes wrong it will be called with `error` object.
     */
    func disconnect(trackableId: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>)
    
    /**
     Cleanups and closes all the connected channels and their presence. In the end closes Ably connection.
     
     - Parameter presenceData:  The data that will be send via the presence channel.
     - Parameter completion:    The closure that will be called when `Ably` connection state will change to `closed` or `failed`.
     */
    func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>)
}

/**
 The `AblyMode` is an `OptionSet` which defines how `AblyWrapper` should works: as a `publisher`, as a `subscriber` or both.
 */
public struct AblyMode: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let publish = AblyMode(rawValue: 1 << 0)
    public static let subscribe = AblyMode(rawValue: 1 << 1)
}
