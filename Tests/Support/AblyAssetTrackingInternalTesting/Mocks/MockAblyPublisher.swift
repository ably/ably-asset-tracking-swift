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
    public var connectTrackableId: String?
    public var connectPresenceData: PresenceData?
    public var connectUseRewind: Bool?
    public var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func connect(trackableId: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connectTrackableId = trackableId
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletionHandler?(completion)
    }

    public var disconnectCalled: Bool = false
    public var disconnectParamTrackableId: String?
    public var disconnectParamResultHandler: ResultHandler<Bool>?
    public var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    public func disconnect(trackableId: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamTrackableId = trackableId
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
    public var sendEnhancedAssetLocationUpdateParamTrackable: Trackable?
    public var sendEnhancedAssetLocationUpdateParamCompletion: ResultHandler<Void>?
    public var sendEnhancedAssetLocationUpdateParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendEnhancedLocation(locationUpdate: EnhancedLocationUpdate, trackable: Trackable, completion: ResultHandler<Void>?) {
        sendEnhancedAssetLocationUpdateCounter += 1
        sendEnhancedAssetLocationUpdateCalled = true
        sendEnhancedAssetLocationUpdateParamLocationUpdate = locationUpdate
        sendEnhancedAssetLocationUpdateParamTrackable = trackable
        sendEnhancedAssetLocationUpdateParamCompletion = completion
        sendEnhancedAssetLocationUpdateParamCompletionHandler?(completion)
    }

    public var sendRawLocationWasCalled = false
    public var sendRawLocationParamLocation: RawLocationUpdate?
    public var sendRawLocationParamTrackable: Trackable?
    public var sendRawLocationParamCompletion: ResultHandler<Void>?
    public var sendRawLocationParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendRawLocation(location: RawLocationUpdate, trackable: Trackable, completion: ResultHandler<Void>?) {
        sendRawLocationWasCalled = true
        sendRawLocationParamLocation = location
        sendRawLocationParamTrackable = trackable
        sendRawLocationParamCompletion = completion
        sendRawLocationParamCompletionHandler?(completion)
    }

    public var sendResolutionWasCalled = false
    public var sendResolutionParamResolution: Resolution?
    public var sendResolutionParamTrackable: Trackable?
    public var sendResolutionParamCompletion: ResultHandler<Void>?
    public var sendResolutionParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    public func sendResolution(trackable: Trackable, resolution: Resolution, completion: ResultHandler<Void>?) {
        sendResolutionWasCalled = true
        sendResolutionParamResolution = resolution
        sendResolutionParamTrackable = trackable
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
}
