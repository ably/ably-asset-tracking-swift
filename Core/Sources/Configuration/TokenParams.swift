import Foundation
import Ably

@objc
public class TokenParams: NSObject, ARTTokenDetailsCompatible, Codable {
    public func toTokenDetails(_ auth: ARTAuth, callback: @escaping (ARTTokenDetails?, Error?) -> Void) {
        // TODO implement this
    }

    private let ttl: Int?
    private let capability: String?
    private let clientId: String?
    private let timestamp: Date?
    private let nonce: String?

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