import Foundation

/**
 A set of fields usable by Ably client to request a token. This can be generated server-side and provided to your client.
 */
public class TokenRequest: NSObject, Codable {
    public let keyName: String
    public let clientId: String?
    public let capability: String?
    public let timestamp: Int
    public let nonce: String
    public let mac: String
    
    public init(keyName: String, clientId: String?, capability: String?, timestamp: Int, nonce: String, mac: String) {
        self.keyName = keyName
        self.clientId = clientId
        self.capability = capability
        self.timestamp = timestamp
        self.nonce = nonce
        self.mac = mac
    }
}
