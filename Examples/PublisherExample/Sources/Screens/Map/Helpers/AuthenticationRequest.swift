import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingPublisher

func getTokenRequestJSONFromYourServer(tokenParams: TokenParams,
                                       resultHandler: @escaping (Result<TokenRequest, Error>) -> Void) {
    let url = URL(string: "https://europe-west2-ably-testing.cloudfunctions.net/app/createTokenRequest")!
    // Or use a local server (for debugging):
//        let url = URL(string: "http://localhost:8000/ably-testing/europe-west2/app/createTokenRequest")!

//        // Using POST Request and specifying the clientId (or TokenParams) via the HTTP body
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try! JSONEncoder().encode(tokenParams)
    // Or Alternatively, just send the clientId to your server:
//        request.httpBody = try? JSONSerialization.data(withJSONObject: ["clientId": tokenParams.clientId])
    
    // You can also use a GET Request, specifying the clientId via a query param, if your server supports this.
//        request.httpMethod = "GET"
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
//        components.queryItems = [URLQueryItem(name: "clientId", value: tokenParams.clientId)]

    URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { data, _, requestError in
        guard let data = data else {
            if let requestError = requestError {
                resultHandler(.failure(requestError))
                return
            } else {
                resultHandler(.failure(NSError(domain: "No data received", code: 400, userInfo: [:])))
                return
            }
        }
        do {
            let decoder = JSONDecoder()
            let tokenRequest = try decoder.decode(TokenRequest.self, from: data)
            resultHandler(.success(tokenRequest))
        } catch {
            resultHandler(.failure(error))
        }
    }.resume()
}
