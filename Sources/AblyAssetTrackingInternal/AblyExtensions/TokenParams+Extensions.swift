import Ably
import AblyAssetTrackingCore
import Foundation

extension TokenParams {
    internal func toARTTokenParams() -> ARTTokenParams {
        let artTokenParams = ARTTokenParams(clientId: clientId, nonce: nonce)
        artTokenParams.ttl = (ttl != nil) ? NSNumber(value: ttl!) : nil
        artTokenParams.timestamp = timestamp
        artTokenParams.capability = capability?.toJSONString()
        return artTokenParams
    }
}

extension ARTTokenParams {
    internal func toTokenParams() -> TokenParams {
        TokenParams(
            ttl: ttl != nil ? Int(exactly: ttl!) : nil,
            capability: capability,
            clientId: clientId,
            timestamp: timestamp,
            nonce: nonce
        )
    }
}
