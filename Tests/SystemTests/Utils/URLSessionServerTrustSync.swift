import Foundation
import XCTest

/**
 Helper class for synchronous URL requests.
 */
class URLSessionServerTrustSync: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    /**
     This method makes synchronous requests to the URL
     */
    func get(_ request: NSMutableURLRequest) -> (Data?, NSError?, HTTPURLResponse?) {
        var responseError: NSError?
        var responseData: Data?
        var httpResponse: HTTPURLResponse?
        var requestCompleted = false

        let configuration = URLSessionConfiguration.default
        let queue = OperationQueue()
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: queue)

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                responseData = data
                responseError = error as NSError?
                httpResponse = response
            } else if let error {
                responseError = error as NSError?
            }
            requestCompleted = true
        })
        task.resume()

        /**
         This loop is checking if `dataTask`(async)  is finished, it uses `CFRunLoopRunInMode` with `CFTimeInterval(0.1)` to slowing down loop
         on thread. This part of code makes this task synchronous.
         */
        while !requestCompleted {
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, CFTimeInterval(0.1), false)
        }

        return (responseData, responseError, httpResponse)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Try to extract the server certificate for trust validation
        if let serverTrust = challenge.protectionSpace.serverTrust {
            // Server trust authentication
            // Reference: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/AuthenticationChallenges.html
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            challenge.sender?.performDefaultHandling?(for: challenge)
            XCTFail("Current authentication: \(challenge.protectionSpace.authenticationMethod)")
        }
    }
}
