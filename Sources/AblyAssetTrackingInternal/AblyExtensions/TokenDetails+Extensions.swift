import Ably
import AblyAssetTrackingCore
import Foundation

extension TokenDetails {
    // swiftlint:disable:next missing_docs
    public func toARTTokenDetails() -> ARTTokenDetails {
        ARTTokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}

extension ARTTokenDetails {
    // swiftlint:disable:next missing_docs
    public func asTokenDetails() -> TokenDetails? {
        guard let expires, let issued, let clientId, let capability else {
            return nil
        }

        return TokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}
