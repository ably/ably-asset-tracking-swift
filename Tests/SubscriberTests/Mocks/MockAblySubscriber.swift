import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import Logging
@testable import AblyAssetTrackingSubscriber

class MockAblySubscriber: AblySubscriber {
    var wasDelegateSet: Bool = false
    var subscriberDelegate: AblySubscriberDelegate? {
        didSet { wasDelegateSet = true }
    }
    
    var initConnectionConfiguration: ConnectionConfiguration?
    var initMode: AblyMode?
    required init(configuration: ConnectionConfiguration, mode: AblyMode, logger: Logger) {
        self.initConnectionConfiguration = configuration
        self.initMode = mode
    }
    
    var subscribeForEnhancedEventsCalled = false
    var subscribeForEnhancedEventsTrackableId: String?
    func subscribeForEnhancedEvents(trackableId: String) {
        subscribeForEnhancedEventsCalled = true
        subscribeForEnhancedEventsTrackableId = trackableId
    }
    
    var subscribeForRawEventsWasCalled = false
    var subscribeForRawEventsTrackableId: String?
    func subscribeForRawEvents(trackableId: String) {
        subscribeForRawEventsWasCalled = true
        subscribeForRawEventsTrackableId = trackableId
    }
    
    var subscribeForResolutionWasCalled = false
    var subscribeForResolutionTrackableId: String?
    func subscribeForResolutionEvents(trackableId: String) {
        subscribeForResolutionWasCalled = true
        subscribeForResolutionTrackableId = trackableId
    }
    
    var updatePresenceDataWasCalled = false
    var updatePresenceDataTrackableId: String?
    var updatePresenceDataPresenceData: PresenceData?
    var updatePresenceDataCompletion: ResultHandler<Void>?
    var updatePresenceDataCompletionHandler: ((ResultHandler<Void>?) -> ())?
    func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: ResultHandler<Void>?) {
        updatePresenceDataWasCalled = true
        updatePresenceDataTrackableId = trackableId
        updatePresenceDataPresenceData = presenceData
        updatePresenceDataCompletion = completion
        updatePresenceDataCompletionHandler?(completion)
    }
    
    var subscribeForAblyStateChangeCalled = false
    func subscribeForAblyStateChange() {
        subscribeForAblyStateChangeCalled = true
    }
    
    var subscribeForChannelStateChangeCalled = false
    var subscribeForChannelStateChangeTrackable: Trackable?
    func subscribeForChannelStateChange(trackable: Trackable) {
        subscribeForChannelStateChangeCalled = true
        subscribeForChannelStateChangeTrackable = trackable
    }
    
    var subscribeForPresenceMessagesCalled = false
    var subscribeForPresenceMessagesTrackable: Trackable?
    func subscribeForPresenceMessages(trackable: Trackable) {
        subscribeForPresenceMessagesCalled = true
        subscribeForPresenceMessagesTrackable = trackable
    }
    
    var connectCalled = false
    var connectTrackableId: String?
    var connectPresenceData: PresenceData?
    var connectUseRewind: Bool?
    var connectCompletion: ResultHandler<Void>?
    var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func connect(trackableId: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connectTrackableId = trackableId
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletion = completion
        connectCompletionHandler?(completion)
    }
    
    var disconnectCalled: Bool = false
    var disconnectParamTrackableId: String?
    var disconnectParamPresenceData: PresenceData?
    var disconnectParamResultHandler: ResultHandler<Bool>?
    var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    func disconnect(trackableId: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamTrackableId = trackableId
        disconnectParamPresenceData = presenceData
        disconnectParamResultHandler = completion
        disconnectResultCompletionHandler?(completion)
    }
    
    var closeCalled: Bool = false
    var closePresenceData: PresenceData?
    var closeCompletion: ResultHandler<Void>?
    var closeResultCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>) {
        closeCalled = true
        closePresenceData = presenceData
        closeCompletion = completion
        closeResultCompletionHandler?(completion)
    }
}
