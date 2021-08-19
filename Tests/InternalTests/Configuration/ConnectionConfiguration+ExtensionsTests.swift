import XCTest
import Ably
import AblyAssetTrackingCore
@testable import AblyAssetTrackingInternal

class ConnectionConfigurationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicAuthenticationConstructor() throws {
        let configuration = ConnectionConfiguration(apiKey: "An API key", clientId: "A client ID")
        let clientOptions = configuration.getClientOptions()
        XCTAssertEqual(clientOptions.clientId, "A client ID")
        XCTAssertNil(clientOptions.authCallback)
    }
    
    func testTokenAuthenticationReturningTokenRequestPassedItToAblySDK() throws {
        var authCallbackCalled = false
        
        let clientId = "My client id"
        let keyname = "ABCD"
        let timestamp = Date()
        let nonce = "12331"
        
        let configuration = ConnectionConfiguration(clientId: clientId, authCallback: { tokenParams, resultHandler in
            authCallbackCalled = true
            let timestampEpochInMilliseconds = Int(tokenParams.timestamp!.timeIntervalSince1970 * 1000)
            let tokenRequest = TokenRequest(keyName: keyname, clientId: tokenParams.clientId!, capability: tokenParams.capability!, timestamp: timestampEpochInMilliseconds, nonce: tokenParams.nonce!, mac: "Some random mac")
            resultHandler(.success(.tokenRequest(tokenRequest)))
        })
        
        // Checking the clientOptions provided is structured correctly for Ably-cocoa
        let clientOptions = configuration.getClientOptions()
        XCTAssertEqual(clientOptions.clientId, clientId)
        let tokenParams = TokenParams(ttl: 0, capability: "", clientId: clientId, timestamp: timestamp, nonce: nonce).toARTTokenParams()
        XCTAssertNotNil(clientOptions.authCallback)
        (clientOptions.authCallback!)(tokenParams) { result, error in
            guard let tokenRequest = result as? ARTTokenRequest else {
                XCTFail("TokenRequest was not returned")
                return
            }
            XCTAssertEqual(tokenRequest.keyName, keyname)
            XCTAssertEqual(tokenRequest.clientId, clientId)
            XCTAssertEqual(tokenRequest.timestamp.timeIntervalSinceReferenceDate, timestamp.timeIntervalSinceReferenceDate, accuracy: 0.001)
            XCTAssertEqual(tokenRequest.nonce, nonce)
        }
        XCTAssertTrue(authCallbackCalled)
    }

        func testTokenAuthenticationReturningTokenDetailsPassesItToAblySDK() throws {
            var authCallbackCalled = false
            
            let clientId = "My client id"
            let timestamp = Date()
            let nonce = "12331"
            
            let configuration = ConnectionConfiguration(clientId: clientId, authCallback: { tokenParams, resultHandler in
                authCallbackCalled = true
                let tokenDetails = TokenDetails(token: "Some token", expires: Date(), issued: Date(), capability: "", clientId: clientId)
                resultHandler(.success(.tokenDetails(tokenDetails)))
            })
            
            // Checking the clientOptions provided is structured correctly for Ably-cocoa
            let clientOptions = configuration.getClientOptions()
            XCTAssertEqual(clientOptions.clientId, clientId)
            let tokenParams = TokenParams(ttl: 0, capability: "", clientId: clientId, timestamp: timestamp, nonce: nonce).toARTTokenParams()
            XCTAssertNotNil(clientOptions.authCallback)
            (clientOptions.authCallback!)(tokenParams) { result, error in
                guard let tokenDetails = result as? ARTTokenDetails else {
                    XCTFail("TokenDetails was not returned")
                    return
                }
                XCTAssertEqual(tokenDetails.clientId, clientId)
                // Note, the capability doesn't have to be the same, since the server might not grant the capabilities requested by client.
            }
            XCTAssertTrue(authCallbackCalled)
        }
    
    func testTokenAuthenticationPassesTokenStringToAblySdk() throws {
        var authCallbackCalled = false
        
        let clientId = "My client id"
        let timestamp = Date()
        let tokenString = "Token string or JWT"
        let nonce = "12331"
        
        let configuration = ConnectionConfiguration(clientId: clientId, authCallback: { tokenParams, resultHandler in
            authCallbackCalled = true
            resultHandler(.success(.jwt(tokenString)))
        })
        
        // Checking the clientOptions provided is structured correctly for Ably-cocoa
        let clientOptions = configuration.getClientOptions()
        XCTAssertEqual(clientOptions.clientId, clientId)
        let tokenParams = TokenParams(ttl: 0, capability: "", clientId: clientId, timestamp: timestamp, nonce: nonce).toARTTokenParams()
        XCTAssertNotNil(clientOptions.authCallback)
        (clientOptions.authCallback!)(tokenParams) { result, error in
            guard let actualTokenString = result as? String else {
                XCTFail("String (JWT or Token) was not returned")
                return
            }
            XCTAssertEqual(actualTokenString, tokenString)
            // Note, the capability doesn't have to be the same, since the server might not grant the capabilities requested by client.
        }
        XCTAssertTrue(authCallbackCalled)
    }
}