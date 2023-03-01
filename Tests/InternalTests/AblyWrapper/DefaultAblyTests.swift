import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingCore
import Ably
import AblyAssetTrackingCoreTesting
import AblyAssetTrackingInternalTesting

class DefaultAblyTests: XCTestCase {
    let logger = InternalLogHandlerMock.configured

    func test_connect_whenNotConfiguredToUseToken_whenPresenceEnterFails_withAnErrorRelatedToCapabilities_itFails() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let auth = AblySDKAuthMock()
        auth.authorizeClosure = { callback in
            callback(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""), nil)
        }
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        realtime.auth = auth
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration(apiKey: "abc123")
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly fails to connect")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success in ably.connect")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(presence.enterCallbackCallsCount, 1)
    }
    
    func test_connect_whenConfiguredToUseToken_whenPresenceEnterSucceeds_itSucceeds() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(nil)
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly successfully connects")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case let .failure(error):
                XCTFail("Unexpected failure in ably.connect: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(presence.enterCallbackCallsCount, 1)
    }
    
    func test_connect_whenConfiguredToUseToken_whenPresenceEnterFails_withAnErrorUnrelatedToCapabilities_itFails() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(ARTErrorInfo.createUnknownError())
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly fails to connect")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success in ably.connect")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(presence.enterCallbackCallsCount, 1)
    }
    
    func test_connect_whenConfiguredToUseToken_whenPresenceEnterFails_withAnErrorRelatedToCapabilities_itCallsAuthorize_andWhenAuthorizeSucceeds_itAttachesToTheChannel_andWhenAttachFails_itFails() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        channel.attachClosure = { callback in
            callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
        }
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let auth = AblySDKAuthMock()
        auth.authorizeClosure = { callback in
            callback(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""), nil)
        }
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        realtime.auth = auth
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly fails to connect")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success in ably.connect")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(channel.attachCallsCount, 1)
        XCTAssertEqual(presence.enterCallbackCallsCount, 1)
        XCTAssertEqual(auth.authorizeCallsCount, 1)
    }

    func test_connect_whenConfiguredToUseToken_whenPresenceEnterFails_withAnErrorRelatedToCapabilities_itCallsAuthorize_andWhenAuthorizeSucceeds_itAttachesToTheChannel_andWhenAttachSucceeds_itRetriesPresenceEnter_andWhenTheSecondCallToPresenceEnterSucceeds_itSucceeds() {
        let presence = AblySDKRealtimePresenceMock()
        var hasEnterFailed = false
        presence.enterCallbackClosure = { data, callback in
            if hasEnterFailed {
                callback?(nil)
            } else {
                hasEnterFailed = true
                callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
            }
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        channel.attachClosure = { callback in
            callback?(nil)
        }
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let auth = AblySDKAuthMock()
        auth.authorizeClosure = { callback in
            callback(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""), nil)
        }
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        realtime.auth = auth
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly successfully connects")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case let .failure(error):
                XCTFail("Unexpected failure in ably.connect: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(channel.attachCallsCount, 1)
        XCTAssertEqual(presence.enterCallbackCallsCount, 2)
        XCTAssertEqual(auth.authorizeCallsCount, 1)
    }
    
    func test_connect_whenConfiguredToUseToken_whenPresenceEnterFails_withAnErrorRelatedToCapabilities_itCallsAuthorize_andWhenAuthorizeSucceeds_itAttachesToTheChannel_andWhenAttachSucceeds_itRetriesPresenceEnter_andWhenTheSecondCallToPresenceEnterFails_itFails() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        channel.attachClosure = { callback in
            callback?(nil)
        }
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let auth = AblySDKAuthMock()
        auth.authorizeClosure = { callback in
            callback(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""), nil)
        }
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        realtime.auth = auth
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly fails to connect")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success in ably.connect")
            case .failure:
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(channel.attachCallsCount, 1)
        XCTAssertEqual(presence.enterCallbackCallsCount, 2)
        XCTAssertEqual(auth.authorizeCallsCount, 1)
    }
    
    func test_connect_whenConfiguredToUseToken_whenPresenceEnterFails_withAnErrorRelatedToCapabilities_itCallsAuthorize_andWhenAuthorizeFails_itFails() {
        let presence = AblySDKRealtimePresenceMock()
        presence.enterCallbackClosure = { data, callback in
            callback?(ARTErrorInfo.create(withCode: 40160, message: ""))
        }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let auth = AblySDKAuthMock()
        auth.authorizeClosure = { callback in
            callback(nil, NSError(domain: "", code: 0))
        }
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        realtime.auth = auth
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let expectation = expectation(description: "DefaultAbly fails to connect")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success in ably.connect")
            case .failure:
                expectation.fulfill()
            }
        }
                
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(presence.enterCallbackCallsCount, 1)
        XCTAssertEqual(auth.authorizeCallsCount, 1)
    }
    
    func test_connect_whenChannelIsInDetachedState_itAttachesToTheChannelBeforeCallingPresenceEnter() {
        test_connect_whenChannelIsInThisState_itAttachesToTheChannelBeforeCallingPresenceEnter(.detached)
    }
    
    func test_connect_whenChannelIsInFailedState_itAttachesToTheChannelBeforeCallingPresenceEnter() {
        test_connect_whenChannelIsInThisState_itAttachesToTheChannelBeforeCallingPresenceEnter(.failed)
    }
    
    func test_connect_whenChannelIsInThisState_itAttachesToTheChannelBeforeCallingPresenceEnter(_ state: ARTRealtimeChannelState) {
        let channel = AblySDKRealtimeChannelMock()
        channel.state = state
        var attachCompleted = false
        channel.attachClosure = { callback in
            attachCompleted = true
            callback?(nil)
        }
        
        let presence = AblySDKRealtimePresenceMock()
        let presenceEnterExpectation = expectation(description: "Presence enter called")
        presence.enterCallbackClosure = { data, callback in
            XCTAssertTrue(attachCompleted, "Expected channel.attach to have completed before presence enter called")
            presenceEnterExpectation.fulfill()
            callback?(nil)
        }
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration(apiKey: "")
        
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        
        let connectSuccessExpectation = expectation(description: "DefaultAbly connects successfully")
        ably.connect(trackableID: "abc", presenceData: PresenceData(type: .subscriber), useRewind: false) { result in
            switch result {
            case .success:
                connectSuccessExpectation.fulfill()
            case let .failure(error):
                XCTFail("Unexpected failure in ably.connect: \(error)")
            }
        }
                
        waitForExpectations(timeout: 10)
    }
    
    func test_subscribeForRawEvents_whenItReceivesMalformedLocationMessageData_itCallsDidFailOnSubscriberDelegate_withInvalidMessageError() {
        let data = "{\"something\": \"somethingElse\"}"
        test_subscribeForRawEvents_whenItReceivesThisLocationMessageData_itCallsDidFailOnSubscriberDelegate_withInvalidMessageError(data: data)
    }
    
    func test_subscribeForRawEvents_whenItReceivesNonStringLocationMessageData_itCallsDidFailOnSubscriberDelegate_withInvalidMessageError() {
        let data = ["something":"somethingElse"]
        test_subscribeForRawEvents_whenItReceivesThisLocationMessageData_itCallsDidFailOnSubscriberDelegate_withInvalidMessageError(data: data)
    }
    
    func test_subscribeForRawEvents_whenItReceivesThisLocationMessageData_itCallsDidFailOnSubscriberDelegate_withInvalidMessageError(data: Any) {
        let presence = AblySDKRealtimePresenceMock()

        presence.enterCallbackClosure = { _, callback in callback?(nil) }
        
        let channel = AblySDKRealtimeChannelMock()
        channel.state = .initialized
        
        channel.subscribeCallbackClosure = { _, callback in
            let message = ARTMessage(name: nil, data: data)
            callback(message)
            
            return AblySDKEventListenerMock()
        }
        
        channel.presence = presence
        
        let channels = AblySDKRealtimeChannelsMock()
        channels.getChannelForTrackingIdOptionsReturnValue = channel
        
        let realtime = AblySDKRealtimeMock()
        realtime.channels = channels
        
        let factory = AblySDKRealtimeFactoryMock()
        factory.createWithConfigurationLogHandlerReturnValue = realtime
        
        let connectionConfiguration = ConnectionConfiguration { _, callback in
            callback(.success(.tokenDetails(.init(token: "", expires: Date(), issued: Date(), capability: "", clientId: ""))))
        }
        
        let trackableID = "abc"
        let ably = DefaultAbly(factory: factory, configuration: connectionConfiguration, mode: [], logHandler: logger)
        ably.connect(trackableID: trackableID, presenceData: .init(type: .subscriber), useRewind: false) { _ in }
        
        let subscriberDelegate = AblySubscriberDelegateMock()
        ably.subscriberDelegate = subscriberDelegate
        
        let expectation = expectation(description: "Wait for subscriber delegate to receive error callback")
        subscriberDelegate.ablySubscriberDidFailWithErrorClosure = { _, error in
            XCTAssertEqual(error.code, ErrorCode.invalidMessage.rawValue)
            expectation.fulfill()
        }
        
        ably.subscribeForRawEvents(trackableID: trackableID)
        
        waitForExpectations(timeout: 10)
    }
}
