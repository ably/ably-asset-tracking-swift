import CoreLocation
import Foundation
import Logging
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

@testable import AblyAssetTrackingPublisher

class MockAblyPublisherService: AblyPublisher {
    
    var initConnectionConfiguration: ConnectionConfiguration?
    var initMode: AblyMode?
    required init(configuration: ConnectionConfiguration, mode: AblyMode, logger: Logger) {
        self.initConnectionConfiguration = configuration
        self.initMode = mode
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
    var connectCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func connect(trackableId: String, presenceData: PresenceData, useRewind: Bool, completion: @escaping ResultHandler<Void>) {
        connectCalled = true
        connectTrackableId = trackableId
        connectPresenceData = presenceData
        connectUseRewind = useRewind
        connectCompletionHandler?(completion)
    }
    
    var disconnectCalled: Bool = false
    var disconnectParamTrackableId: String?
    var disconnectParamResultHandler: ResultHandler<Bool>?
    var disconnectResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    func disconnect(trackableId: String, presenceData: PresenceData, completion: @escaping ResultHandler<Bool>) {
        disconnectCalled = true
        disconnectParamTrackableId = trackableId
        disconnectParamResultHandler = completion
        disconnectResultCompletionHandler?(completion)
    }

    var wasDelegateSet: Bool = false
    var publisherDelegate: AblyPublisherServiceDelegate? {
        didSet { wasDelegateSet = true }
    }

    var sendEnhancedAssetLocationUpdateCounter: Int = .zero
    var sendEnhancedAssetLocationUpdateCalled: Bool = false
    var sendEnhancedAssetLocationUpdateParamLocationUpdate: EnhancedLocationUpdate?
    var sendEnhancedAssetLocationUpdateParamTrackable: Trackable?
    var sendEnhancedAssetLocationUpdateParamCompletion: ResultHandler<Void>?
    var sendEnhancedAssetLocationUpdateParamCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func sendEnhancedLocation(locationUpdate: EnhancedLocationUpdate, trackable: Trackable, completion: ResultHandler<Void>?) {
        sendEnhancedAssetLocationUpdateCounter += 1
        sendEnhancedAssetLocationUpdateCalled = true
        sendEnhancedAssetLocationUpdateParamLocationUpdate = locationUpdate
        sendEnhancedAssetLocationUpdateParamTrackable = trackable
        sendEnhancedAssetLocationUpdateParamCompletion = completion
        sendEnhancedAssetLocationUpdateParamCompletionHandler?(completion)
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
