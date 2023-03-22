import Ably
import AblyAssetTrackingCore
import Foundation

extension TokenRequest {
    /**
     Convert into Ably Runtime (ART) type
     */
    func toARTTokenRequest() -> ARTTokenRequest {
        let artTokenParams = ARTTokenParams(clientId: clientId, nonce: nonce)
        artTokenParams.timestamp = Date(timeIntervalSince1970: Double(timestamp) / 1000)
        artTokenParams.capability = capability
        return ARTTokenRequest(tokenParams: artTokenParams, keyName: keyName, nonce: nonce, mac: mac)
    }
}
