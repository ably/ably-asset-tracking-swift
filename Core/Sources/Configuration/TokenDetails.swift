import Foundation
import Ably

public class TokenDetails: NSObject, Codable {
    let token: String
    let expires: Date
    let issued: Date
    let capability: String
    let clientId: String
}

extension TokenDetails {
    public func toARTTokenDetails() -> ARTTokenDetails {
        return ARTTokenDetails(token: token, expires: expires, issued: issued, capability: capability, clientId: clientId)
    }
}
