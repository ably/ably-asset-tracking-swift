import Foundation
import Ably

class RestHelper {
    class func clientOptions(_ debug: Bool = false, key: String? = nil) -> ARTClientOptions {
        let options = ARTClientOptions()
        options.logExceptionReportingUrl = nil
        
        if debug {
            options.logLevel = .debug
        }
        
        if let key = key {
            options.key = key
        }
        
        options.dispatchQueue = DispatchQueue.main
        
        return options
    }
}
