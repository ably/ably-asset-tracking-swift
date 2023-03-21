import Foundation

/**
 A set of fields used by Ably client to manage authentication with Ably servers, such as identifying the current user, and deciding to generate a new ``TokenDetails`` when one expires. 
 */
public struct TokenDetails: Codable {
    public let token: String
    public let expires: Date
    public let issued: Date
    public let capability: String
    public let clientId: String

    public init(token: String, expires: Date, issued: Date, capability: String, clientId: String) {
        self.token = token
        self.expires = expires
        self.issued = issued
        self.capability = capability
        self.clientId = clientId
    }
}
