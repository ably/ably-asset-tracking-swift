import Foundation
import Ably

public class TokenRequest: NSObject, Codable {
    public init(tokenParams: TokenParams, keyName: String, nonce: String, mac: String) {
        self.tokenParams = tokenParams
        self.keyName = keyName
        self.nonce = nonce
        self.mac = mac
    }

    private let tokenParams: TokenParams
    private let keyName: String
    private let nonce: String
    private let mac: String
}

extension TokenRequest {
    func toARTTokenRequest() -> ARTTokenRequest {
        ARTTokenRequest(tokenParams: tokenParams.toARTTokenParams(), keyName: keyName, nonce: nonce, mac: mac)
    }
}
