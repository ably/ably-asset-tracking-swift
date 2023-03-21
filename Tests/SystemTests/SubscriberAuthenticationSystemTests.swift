import Foundation
import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import CoreLocation
import Ably

class SubscriberAuthenticationSystemTests: XCTestCase {
    private let clientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()

    func testSubscriberConnectsWithApiKey() throws {
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: clientId)

        testSubscriberConnection(configuration: connectionConfiguration)
    }

    func testSubscriberConnectsWithTokenRequest() throws {
        let clientId = self.clientId
        let authCallbackCalledExpectation = self.expectation(description: "Auth Callback complete")
        // When a user configures an AuthCallback
        let connectionConfiguration = ConnectionConfiguration(authCallback: { tokenParams, authResultHandler in
            XCTAssertNil(tokenParams.clientId)

            // Here, users should make a network request to their auth servers, where their servers create the tokenRequest.
            // To emulate this, we use the api key to create a tokenRequest on the client side.
            let keyTokens = Secrets.ablyApiKey.split(separator: ":")
            let keyName = String(keyTokens[0])
            let keySecret = String(keyTokens[1])
            let currentTimestamp = tokenParams.timestamp ?? Date()
            let timestampEpochInMilliseconds = Int(currentTimestamp.timeIntervalSince1970 * 1000)
            var hmacComponents = [
                keyName,
                tokenParams.ttl != nil ? String(tokenParams.ttl!) : "",
                tokenParams.capability ?? "",
                clientId,
                String(timestampEpochInMilliseconds),
                "Random nonce"
            ].joined(separator: "\n")
            hmacComponents.append("\n")

            let hmac = hmacComponents.hmac(key: keySecret)

            let tokenRequest = TokenRequest(
                keyName: keyName,
                clientId: clientId,
                capability: tokenParams.capability,
                timestamp: timestampEpochInMilliseconds,
                nonce: "Random nonce",
                mac: hmac
            )
            authCallbackCalledExpectation.fulfill()
            authResultHandler(.success(.tokenRequest(tokenRequest)))
        })

        testSubscriberConnection(configuration: connectionConfiguration)
    }

    func testSubscriberConnectsWithTokenDetails() throws {
        let fetchedTokenDetails = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: ARTTokenParams(clientId: clientId)
        )

        let connectionConfiguration = ConnectionConfiguration(authCallback: { _, resultHandler in
            guard let tokenDetails = fetchedTokenDetails else {
                XCTFail("TokenDetails doesn't exist")
                return
            }

            resultHandler(.success(.tokenDetails(tokenDetails)))
        })

        testSubscriberConnection(configuration: connectionConfiguration)
    }

    func testSubscriberConnectsWithTokenString() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])

        let fetchedTokenString = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: ARTTokenParams(clientId: keyName)
        )?.token

        let connectionConfiguration = ConnectionConfiguration(authCallback: { _, resultHandler in
            guard let tokenString = fetchedTokenString else {
                XCTFail("TokenDetails doesn't exist")
                return
            }

            resultHandler(.success(.jwt(tokenString)))
        })

        testSubscriberConnection(configuration: connectionConfiguration)
    }

    func testSubscriberConnectsWithJWT() throws {
        guard let jwtToken = JWTHelper().getToken(clientId: clientId) else {
            XCTFail("Create JWT failed")
            return
        }

        let connectionConfiguration = ConnectionConfiguration { _, resultHandler in
            resultHandler(.success(.jwt(jwtToken)))
        }

        testSubscriberConnection(configuration: connectionConfiguration)
    }

    private func createSubscriberBuilder(connectionConfiguration: ConnectionConfiguration, trackingId: String) -> SubscriberBuilder {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        return SubscriberFactory.subscribers()
            .connection(connectionConfiguration)
            .resolution(resolution)
            .trackingId(trackingId)
    }

    private func testSubscriberConnection(configuration: ConnectionConfiguration) {
        let subscriberStartExpectation = self.expectation(description: "Subscriber start expectation")
        let subscriber = createSubscriberBuilder(connectionConfiguration: configuration, trackingId: "Trackable ID")
            .start { result in
                switch result {
                case .success: ()
                case .failure(let error):
                    XCTFail("Subscriber start failed with error: \(error)")
                }
                subscriberStartExpectation.fulfill()
            }
        waitForExpectations(timeout: 10.0)

        let resolutionCompletionExpectation = self.expectation(description: "Resolution completion expectation")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 100)
        subscriber?.resolutionPreference(resolution: resolution, completion: { result in
            switch result {
            case .success: ()
            case .failure(let error):
                XCTFail("Resolution completion failed with error: \(error)")
            }
            resolutionCompletionExpectation.fulfill()
        })

        waitForExpectations(timeout: 10.0)

        let subscriberStopExpectation = self.expectation(description: "Subscriber stop expectation")
        subscriber?.stop(completion: { _ in
            subscriberStopExpectation.fulfill()
        })
        waitForExpectations(timeout: 10.0)
    }

    private func requestToken(withSubscriberCapabilitiesForTrackableIds trackableIds: [String], clientId: String) throws -> TokenDetails? {
        let capabilities = trackableIds.reduce([:]) { capabilities, trackableId -> [String: [String]] in
            var newCapabilities = capabilities
            newCapabilities["tracking:\(trackableId)"] = ["publish", "subscribe", "presence", "history"]
            return newCapabilities
        }

        let tokenParams = ARTTokenParams(clientId: clientId)
        tokenParams.capability = try capabilities.toJSONString()

        return AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: tokenParams
        )
    }

    func testSubscriber_usingTokenAuth_start_whenEnterPresenceGivesCapabilityError_reauthorizesAblyAndEntersPresenceWithNewToken() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])

        let trackableId = UUID().uuidString
        let otherTrackableId = UUID().uuidString

        // These are being done outside of the authCallback because it seems like calling requestToken inside there causes some sort of a hang. Tried to sort it out but didn’t get anywhere quickly.
        let initialToken = try XCTUnwrap(requestToken(withSubscriberCapabilitiesForTrackableIds: [otherTrackableId], clientId: keyName))
        let updatedToken = try XCTUnwrap(requestToken(withSubscriberCapabilitiesForTrackableIds: [otherTrackableId, trackableId], clientId: keyName))

        var hasRequestedInitialToken = false
        var hasRequestedUpdatedToken = false

        let connectionConfiguration = ConnectionConfiguration(authCallback: { _, resultHandler in
            if !hasRequestedInitialToken {
                hasRequestedInitialToken = true
                resultHandler(.success(.tokenDetails(initialToken)))
            } else {
                hasRequestedUpdatedToken = true
                resultHandler(.success(.tokenDetails(updatedToken)))
            }
        })

        let subscriberStartExpectation = expectation(description: "Wait for subscriber to start")
        let subscriber = createSubscriberBuilder(connectionConfiguration: connectionConfiguration, trackingId: trackableId)
            .start { result in
                switch result {
                case .success:
                    subscriberStartExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Subscriber start failed with error: \(error)")
                }
            }
        waitForExpectations(timeout: 10.0)

        XCTAssertTrue(hasRequestedInitialToken)
        XCTAssertTrue(hasRequestedUpdatedToken)

        let subscriberStopExpectation = expectation(description: "Wait for subscriber to stop")
        subscriber?.stop(completion: { result in
            switch result {
            case .success:
                subscriberStopExpectation.fulfill()
            case let .failure(errorInfo):
                XCTFail("Failed to stop subscriber, with error \(errorInfo)")
            }
        })
        waitForExpectations(timeout: 10)
    }
}
