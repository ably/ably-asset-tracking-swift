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
        guard let expires, let issued, let clientId, let capability else {
            return nil
        }
        
        return TokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}
