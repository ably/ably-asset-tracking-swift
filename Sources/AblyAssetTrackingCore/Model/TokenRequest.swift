import Foundation

public class TokenRequest: NSObject, Codable {
    public let keyName: String
    public let clientId: String
    public let capability: String
    public let timestamp: Int
    public let nonce: String
    public let mac: String
}
