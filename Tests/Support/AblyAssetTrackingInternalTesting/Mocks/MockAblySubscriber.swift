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
    public var subscribeForEnhancedEventsTrackableId: String?
    public func subscribeForEnhancedEvents(trackableId: String) {
        subscribeForEnhancedEventsCalled = true
        subscribeForEnhancedEventsTrackableId = trackableId
    }
    
    public var subscribeForRawEventsWasCalled = false
    public var subscribeForRawEventsTrackableId: String?
    public func subscribeForRawEvents(trackableId: String) {
        subscribeForRawEventsWasCalled = true
        subscribeForRawEventsTrackableId = trackableId
    }
    
    public var subscribeForResolutionWasCalled = false
    public var subscribeForResolutionTrackableId: String?
    public func subscribeForResolutionEvents(trackableId: String) {
        subscribeForResolutionWasCalled = true
        subscribeForResolutionTrackableId = trackableId
    }
    
    public var updatePresenceDataWasCalled = false
    public var updatePresenceDataTrackableId: String?
    public var updatePresenceDataPresenceData: PresenceData?
    public var updatePresenceDataCompletion: ResultHandler<Void>?
    public var updatePresenceDataCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: ResultHandler<Void>?) {
        updatePresenceDataWasCalled = true
        updatePresenceDataTrackableId = trackableId
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

    public var startConnectionCalled = false
    public var startConnectionCompletion: ResultHandler<Void>?
    public var startConnectionCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func startConnection(completion: @escaping ResultHandler<Void>) {
        startConnectionCalled = true
        startConnectionCompletion = completion
        startConnectionCompletionHandler?(completion)
    }

    public var stopConnectionCalled = false
    public var stopConnectionCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func stopConnection(completion: @escaping ResultHandler<Void>) {
        stopConnectionCalled = true
        stopConnectionCompletionHandler?(completion)
    }
    
    public var connectCalled = false
    public var connectTrackableId: String?
    public var connectPresenceData: PresenceData?
    public var connectUseRewind: Bool?
    public var connectCompletion: ResultHandler<Void>?
    public var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func connect(trackableId: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connectTrackableId = trackableId
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletion = completion
        connectCompletionHandler?(completion)
    }
    
    public var disconnectCalled: Bool = false
    public var disconnectParamTrackableId: String?
    public var disconnectParamPresenceData: PresenceData?
    public var disconnectParamResultHandler: ResultHandler<Bool>?
    public var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    public func disconnect(trackableId: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamTrackableId = trackableId
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
