import Foundation

public class TokenDetails: NSObject, Codable {
    public let token: String
    public let expires: Date
    public let issued: Date
    public let capability: String
    public let clientId: String
}
