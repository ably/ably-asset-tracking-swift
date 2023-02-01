import Foundation
import AblyAssetTrackingInternal

protocol SubscriberInteractor: AnyObject {
    func subscribeForRawEvents(presenceData: PresenceData)
    func subscribeForEnhancedEvents(presenceData: PresenceData)
    func subscribeForChannelState()
    func notifyAssetIsOffline()
}
