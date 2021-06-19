import Foundation
import Ably
import AblyAssetTrackingCore

extension TokenDetails {
    public func toARTTokenDetails() -> ARTTokenDetails {
        return ARTTokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}
