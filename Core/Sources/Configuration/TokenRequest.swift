import Foundation
import Ably

public class TokenRequest: NSObject, Codable {
    let keyName: String
    let clientId: String
    let capability: String
    let timestamp: Int
    let nonce: String
    let mac: String
}

extension TokenRequest {
    /**
     Convert into ART (Ably Runtime representation)
     */
    func toARTTokenRequest() -> ARTTokenRequest {
        let artTokenParams = ARTTokenParams(clientId: clientId, nonce: nonce)
        artTokenParams.timestamp = Date(timeIntervalSince1970: Double(timestamp) / 1000)
        artTokenParams.capability = capability
        return ARTTokenRequest(tokenParams: artTokenParams, keyName: keyName, nonce: nonce, mac: mac)
    }
}
