import AblyAssetTrackingInternal
import Ably

protocol SubscriberPropertiesDelegate: AnyObject {
    func subscriberProperties(_ sender: SubscriberProperties, didUpdatePublisherPresence isPresent: Bool)

}

class SubscriberProperties: Properties {
    var isStopped: Bool
    var presenceData: PresenceData
    
    var lastEmittedIsPublisherOnline: Bool?
    var isPublisherOnline: Bool = false
    var currentTrackableConnectionState: ConnectionState = .offline
    
    weak var delegate: SubscriberPropertiesDelegate?
    
    init(isStopped: Bool, presenceData: PresenceData) {
        self.isStopped = isStopped
        self.presenceData = presenceData
    }
    
    func updateForPresenceMessagesAndThenEmitStateEventsIfRequired(presenceMessages: [ARTPresenceMessage]) {
        for message in presenceMessages {
            handleARTPresenceMessage(message, for: <#T##Trackable#>)
        }
    }
    
    private func handleARTPresenceMessage(_ message: ARTPresenceMessage, for trackable: Trackable) {
        guard
            let jsonData = message.data,
            let data: PresenceData = try? PresenceData.fromAny(jsonData),
            let clientId = message.clientId
        else { return }
        
        let presence = Presence(
            action: message.action.toPresenceAction(),
            type: data.type.toPresenceType()
        )
        
        guard presence.type == .publisher else {
            return
        }
        
        if presence.action.isPresentOrEnter {
            isPublisherOnline = true
        } else if presence.action.isLeaveOrAbsent {
            isPublisherOnline = false
        }
        
        if isPublisherOnline != lastEmittedIsPublisherOnline {
            lastEmittedIsPublisherOnline = isPublisherOnline
            delegate?.subscriberProperties(self, didUpdatePublisherPresence: isPublisherOnline)
//            callback(event: .delegateUpdatedPublisherPresence(.init(isPresent: isPublisherOnline)))
        }
        
        
        //////////////////////
        
        // AblySubscriber delegate
        self.subscriberDelegate?.ablySubscriber(self, didReceivePresenceUpdate: presence)
        self.subscriberDelegate?.ablySubscriber(self, didChangeChannelConnectionState: presence.action.toConnectionState())
        
        // Deleagate `Publisher` resolution if present in PresenceData
        if let resolution = data.resolution, data.type == .publisher {
            self.subscriberDelegate?.ablySubscriber(self, didReceiveResolution: resolution)
        }
        
        // AblyPublisher delegate
        self.publisherDelegate?.ablyPublisher(
            self,
            didReceivePresenceUpdate: presence,
            forTrackable: trackable,
            presenceData: data,
            clientId: clientId
        )
    }
}


///subscriberDelegate?.didReceivePresenceUpdate invokes:
///
//private func performPresenceUpdated(_ event: Event.PresenceUpdateEvent) {
//    guard event.presence.type == .publisher else {
//        return
//    }
//    
//    if event.presence.action.isPresentOrEnter {
//        isPublisherOnline = true
//    } else if event.presence.action.isLeaveOrAbsent {
//        isPublisherOnline = false
//    }
//    
//    if isPublisherOnline != lastEmittedIsPublisherOnline {
//        lastEmittedIsPublisherOnline = isPublisherOnline
//        callback(event: .delegateUpdatedPublisherPresence(.init(isPresent: isPublisherOnline)))
//    }
//}
