import Foundation
import Ably
import AblyAssetTrackingCore

extension TokenDetails {
    public func toARTTokenDetails() -> ARTTokenDetails {
        return ARTTokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}

extension ARTTokenDetails {
    public func asTokenDetails() -> TokenDetails? {
        guard let expires = expires, let issued = issued, let clientId = clientId, let capability = capability else {
            return nil
        }
        
        return TokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}
