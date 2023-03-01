import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import AblyAssetTrackingCoreTesting

public class MockAblySubscriber: AblySubscriber {
    public var wasDelegateSet: Bool = false
    public var subscriberDelegate: AblySubscriberDelegate? {
        didSet { wasDelegateSet = true }
    }
    
    public var initConnectionConfiguration: ConnectionConfiguration?
    public var initMode: AblyMode?
    public required init(configuration: ConnectionConfiguration, mode: AblyMode) {
        self.initConnectionConfiguration = configuration
        self.initMode = mode
    }
    
    public var subscribeForEnhancedEventsCalled = false
    public var subscribeForEnhancedEventstrackableID: String?
    public func subscribeForEnhancedEvents(trackableID: String) {
        subscribeForEnhancedEventsCalled = true
        subscribeForEnhancedEventstrackableID = trackableID
    }
    
    public var subscribeForRawEventsWasCalled = false
    public var subscribeForRawEventstrackableID: String?
    public func subscribeForRawEvents(trackableID: String) {
        subscribeForRawEventsWasCalled = true
        subscribeForRawEventstrackableID = trackableID
    }
    
    public var subscribeForResolutionWasCalled = false
    public var subscribeForResolutiontrackableID: String?
    public func subscribeForResolutionEvents(trackableID: String) {
        subscribeForResolutionWasCalled = true
        subscribeForResolutiontrackableID = trackableID
    }
    
    public var updatePresenceDataWasCalled = false
    public var updatePresenceDatatrackableID: String?
    public var updatePresenceDataPresenceData: PresenceData?
    public var updatePresenceDataCompletion: ResultHandler<Void>?
    public var updatePresenceDataCompletionHandler: ((ResultHandler<Void>?) -> ())?
    public func updatePresenceData(trackableID: String, presenceData: PresenceData, completion: ResultHandler<Void>?) {
        updatePresenceDataWasCalled = true
        updatePresenceDatatrackableID = trackableID
        updatePresenceDataPresenceData = presenceData
        updatePresenceDataCompletion = completion
        updatePresenceDataCompletionHandler?(completion)
    }
    
    public var subscribeForAblyStateChangeCalled = false
    public func subscribeForAblyStateChange() {
        subscribeForAblyStateChangeCalled = true
    }
    
    public var subscribeForChannelStateChangeCalled = false
    public var subscribeForChannelStateChangeTrackable: Trackable?
    public func subscribeForChannelStateChange(trackable: Trackable) {
        subscribeForChannelStateChangeCalled = true
        subscribeForChannelStateChangeTrackable = trackable
    }
    
    public var subscribeForPresenceMessagesCalled = false
    public var subscribeForPresenceMessagesTrackable: Trackable?
    public func subscribeForPresenceMessages(trackable: Trackable) {
        subscribeForPresenceMessagesCalled = true
        subscribeForPresenceMessagesTrackable = trackable
    }
    
    public var connectCalled = false
    public var connecttrackableID: String?
    public var connectPresenceData: PresenceData?
    public var connectUseRewind: Bool?
    public var connectCompletion: ResultHandler<Void>?
    public var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func connect(trackableID: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connecttrackableID = trackableID
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletion = completion
        connectCompletionHandler?(completion)
    }
    
    public var disconnectCalled: Bool = false
    public var disconnectParamtrackableID: String?
    public var disconnectParamPresenceData: PresenceData?
    public var disconnectParamResultHandler: ResultHandler<Bool>?
    public var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    public func disconnect(trackableID: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamtrackableID = trackableID
        disconnectParamPresenceData = presenceData
        disconnectParamResultHandler = completion
        disconnectResultCompletionHandler?(completion)
    }
    
    public var closeCalled: Bool = false
    public var closePresenceData: PresenceData?
    public var closeCompletion: ResultHandler<Void>?
    public var closeResultCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>) {
        closeCalled = true
        closePresenceData = presenceData
        closeCompletion = completion
        closeResultCompletionHandler?(completion)
    }
}
