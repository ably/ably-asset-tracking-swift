import Foundation
import XCTest

class JWTHelper {
    func getToken(
        invalid: Bool = false,
        expiresIn: Int = 3600,
        clientId: String = "testClientIDiOS",
        capability: String = "{\"*\":[\"*\"]}",
        jwtType: String = "",
        encrypted: Int = 0
    ) -> String? {

        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])
        var keySecret = String(keyTokens[1])
        if invalid {
            keySecret = "invalid"
        }

        var urlComponents = URLComponents(string: "https://echo.ably.io/createJWT")
        urlComponents?.queryItems = [
            URLQueryItem(name: "keyName", value: keyName),
            URLQueryItem(name: "keySecret", value: keySecret),
            URLQueryItem(name: "expiresIn", value: String(expiresIn)),
            URLQueryItem(name: "clientId", value: clientId),
            URLQueryItem(name: "capability", value: capability),
            URLQueryItem(name: "jwtType", value: jwtType),
            URLQueryItem(name: "encrypted", value: String(encrypted)),
            URLQueryItem(name: "environment", value: "sandbox")
        ]

        let request = NSMutableURLRequest(url: urlComponents!.url!)
        let (responseData, responseError, _) = URLSessionServerTrustSync().get(request)
        if let error = responseError {
            XCTFail(error.localizedDescription)
            return nil
        }
        return String(data: responseData!, encoding: String.Encoding.utf8)
    }
}
