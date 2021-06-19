import Foundation

public class TokenParams: NSObject, Codable {
    public let ttl: Int?
    public let capability: String?
    public let clientId: String?
    public let timestamp: Date?
    public let nonce: String?

    public init(ttl: Int?,
         capability: String?,
         clientId: String?,
         timestamp: Date?,
         nonce: String?) {
        self.ttl = ttl
        self.capability = capability
        self.clientId = clientId
        self.timestamp = timestamp
        self.nonce = nonce
    }
}
