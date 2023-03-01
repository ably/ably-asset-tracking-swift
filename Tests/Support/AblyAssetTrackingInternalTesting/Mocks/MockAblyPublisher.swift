import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

public class MockAblyPublisher: AblyPublisher {
    
    public var initConnectionConfiguration: ConnectionConfiguration?
    public var initMode: AblyMode?
    public required init(configuration: ConnectionConfiguration, mode: AblyMode) {
        self.initConnectionConfiguration = configuration
        self.initMode = mode
    }
    
    public var subscribeForAblyStateChangeCalled = false
    public func subscribeForAblyStateChange() {
        subscribeForAblyStateChangeCalled = true
    }
    
    public var subscribeForChannelStateChangeCalled = false
    public var subscribeForChannelStateChangeTrackableID: String?
    public func subscribeForChannelStateChange(trackableID: String) {
        subscribeForChannelStateChangeCalled = true
        subscribeForChannelStateChangeTrackableID = trackableID
    }
    
    public var subscribeForPresenceMessagesCalled = false
    public var subscribeForPresenceMessagesTrackableID: String?
    public func subscribeForPresenceMessages(trackableID: String) {
        subscribeForPresenceMessagesCalled = true
        subscribeForPresenceMessagesTrackableID = trackableID
    }
    
    public var connectCalled = false
    public var connecttrackableID: String?
    public var connectPresenceData: PresenceData?
    public var connectUseRewind: Bool?
    public var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func connect(trackableID: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connecttrackableID = trackableID
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletionHandler?(completion)
    }
    
    public var disconnectCalled: Bool = false
    public var disconnectParamtrackableID: String?
    public var disconnectParamResultHandler: ResultHandler<Bool>?
    public var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    public func disconnect(trackableID: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamtrackableID = trackableID
        disconnectParamResultHandler = completion
        disconnectResultCompletionHandler?(completion)
    }

    public var wasDelegateSet: Bool = false
    public var publisherDelegate: AblyPublisherDelegate? {
        didSet { wasDelegateSet = true }
    }

    public var sendEnhancedAssetLocationUpdateCounter: Int = .zero
    public var sendEnhancedAssetLocationUpdateCalled: Bool = false
    public var sendEnhancedAssetLocationUpdateParamLocationUpdate: EnhancedLocationUpdate?
    public var sendEnhancedAssetLocationUpdateParamTrackableID: String?
    public var sendEnhancedAssetLocationUpdateParamCompletion: ResultHandler<Void>?
    public var sendEnhancedAssetLocationUpdateParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendEnhancedLocation(locationUpdate: EnhancedLocationUpdate, trackableID: String, completion: ResultHandler<Void>?) {
        sendEnhancedAssetLocationUpdateCounter += 1
        sendEnhancedAssetLocationUpdateCalled = true
        sendEnhancedAssetLocationUpdateParamLocationUpdate = locationUpdate
        sendEnhancedAssetLocationUpdateParamTrackableID = trackableID
        sendEnhancedAssetLocationUpdateParamCompletion = completion
        sendEnhancedAssetLocationUpdateParamCompletionHandler?(completion)
    }
    
    public var sendRawLocationWasCalled = false
    public var sendRawLocationParamLocation: RawLocationUpdate?
    public var sendRawLocationParamTrackableID: String?
    public var sendRawLocationParamCompletion: ResultHandler<Void>?
    public var sendRawLocationParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendRawLocation(location: RawLocationUpdate, trackableID: String, completion: ResultHandler<Void>?) {
        sendRawLocationWasCalled = true
        sendRawLocationParamLocation = location
        sendRawLocationParamTrackableID = trackableID
        sendRawLocationParamCompletion = completion
        sendRawLocationParamCompletionHandler?(completion)
    }
    
    public var sendResolutionWasCalled = false
    public var sendResolutionParamResolution: Resolution?
    public var sendResolutionParamTrackableID: String?
    public var sendResolutionParamCompletion: ResultHandler<Void>?
    public var sendResolutionParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendResolution(trackableID: String, resolution: Resolution, completion: ResultHandler<Void>?) {
        sendResolutionWasCalled = true
        sendResolutionParamResolution = resolution
        sendResolutionParamTrackableID = trackableID
        sendResolutionParamCompletion = completion
        sendResolutionParamCompletionHandler?(completion)
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
}
