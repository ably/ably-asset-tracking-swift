import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingPublisher
import AblyAssetTrackingInternal
import CoreLocation
import Ably

class PublisherAuthenticationSystemTests: XCTestCase {
    private let clientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()

    func testPublisherConnectsWithApiKey() throws {
        // When a user connects using basic authentication/ API key
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: clientId)

        try testPublisherTrack(configuration: connectionConfiguration)
    }

    func testPublisherConnectsWithTokenRequest() throws {
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

        try testPublisherTrack(configuration: connectionConfiguration)
    }

    func testPublisherConnectsWithTokenDetails() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])

        let fetchedTokenDetails = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: ARTTokenParams(clientId: keyName)
        )

        let connectionConfiguration = ConnectionConfiguration(authCallback: { _, resultHandler in
            guard let tokenDetails = fetchedTokenDetails else {
                XCTFail("TokenDetails doesn't exist")
                return
            }

            resultHandler(.success(.tokenDetails(tokenDetails)))
        })

        try testPublisherTrack(configuration: connectionConfiguration)
    }

    func testPublisherConnectsWithTokenString() throws {
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

        try testPublisherTrack(configuration: connectionConfiguration)
    }

    func testPublisherConnectsWithJWT() throws {
        guard let jwtToken = JWTHelper().getToken() else {
            XCTFail("Create JWT failed")
            return
        }

        let connectionConfiguration = ConnectionConfiguration { _, resultHandler in
            resultHandler(.success(.jwt(jwtToken)))
        }

        try testPublisherTrack(configuration: connectionConfiguration)
    }

    private func createAndStartPublisher(connectionConfiguration: ConnectionConfiguration) throws -> Publisher {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        let publisher = try PublisherFactory.publishers()
            .connection(connectionConfiguration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken))
            .locationSource(.init(locations: [CLLocation(latitude: 0.0, longitude: 0.0), CLLocation(latitude: 1.0, longitude: 1.0)]))
            .routingProfile(.driving)
            .vehicleProfile(.bicycle)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start() // Doesn't start publishing, its just a `build()` publisher call.

        return publisher
    }

    private func testPublisherTrack(configuration: ConnectionConfiguration) throws {
        let publisher = try createAndStartPublisher(connectionConfiguration: configuration)

        // TODO check that connection is made/ Await successfully connection callback with an expectation
        // Here, I am creating a trackable instead of just checking the connection, because there doesn't
        // seem to be a way to check that the client is connected to Ably.
        let expectation = self.expectation(description: "Publisher.track completes successfully")
        let trackable = Trackable(id: "Trackable ID")
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Publisher failed to track trackable, error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)

        let stopExpectation = self.expectation(description: "Publisher stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Publisher failed to stop, error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    private func requestToken(withPublisherCapabilitiesForTrackableIds trackableIds: [String], clientId: String) throws -> TokenDetails? {
        let capabilities = trackableIds.reduce([:]) { capabilities, trackableId -> [String: [String]] in
            var newCapabilities = capabilities
            newCapabilities["tracking:\(trackableId)"] = ["publish", "subscribe", "presence"]
            return newCapabilities
        }

        let tokenParams = ARTTokenParams(clientId: clientId)
        tokenParams.capability = try capabilities.toJSONString()

        return AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: tokenParams
        )
    }

    func testPublisher_usingTokenAuth_addTrackable_whenEnterPresenceGivesCapabilityError_reauthorizesAblyAndEntersPresenceWithNewToken() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])

        let trackableId = UUID().uuidString
        let otherTrackableId = UUID().uuidString

        // These are being done outside of the authCallback because it seems like calling requestToken inside there causes some sort of a hang. Tried to sort it out but didn’t get anywhere quickly.
        let initialToken = try XCTUnwrap(requestToken(withPublisherCapabilitiesForTrackableIds: [otherTrackableId], clientId: keyName))
        let updatedToken = try XCTUnwrap(requestToken(withPublisherCapabilitiesForTrackableIds: [otherTrackableId, trackableId], clientId: keyName))

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

        let publisher = try createAndStartPublisher(connectionConfiguration: connectionConfiguration)

        let trackable = Trackable(id: trackableId)
        let addTrackableExpectation = expectation(description: "Publisher successfully adds trackable")
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                addTrackableExpectation.fulfill()
            case let .failure(errorInformation):
                XCTFail("Failed to add trackable with error \(errorInformation)")
            }
        }

        waitForExpectations(timeout: 10)

        XCTAssertTrue(hasRequestedInitialToken)
        XCTAssertTrue(hasRequestedUpdatedToken)
    }
}
