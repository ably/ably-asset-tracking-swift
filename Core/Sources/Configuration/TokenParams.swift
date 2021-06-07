import Foundation
import Ably

public class TokenParams: NSObject, Codable {
    public let ttl: Int?
    public let capability: String?
    public let clientId: String?
    public let timestamp: Date?
    public let nonce: String?

    init(ttl: Int?,
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

extension TokenParams {
    internal func toARTTokenParams() -> ARTTokenParams {
        let artTokenParams = ARTTokenParams(clientId: clientId, nonce: nonce)
        artTokenParams.ttl = (ttl != nil) ? NSNumber(value: ttl!) : nil;
        artTokenParams.timestamp = timestamp
        artTokenParams.capability = try? capability?.toJSONString()
        return artTokenParams
    }
}

extension ARTTokenParams {
    internal func toTokenParams() -> TokenParams {
        let _ttl = ttl != nil ? Int(exactly: ttl!) : nil;
        return TokenParams(ttl: _ttl,
                capability: capability,
                clientId: clientId,
                timestamp: timestamp,
                nonce: nonce
        )
    }
}
