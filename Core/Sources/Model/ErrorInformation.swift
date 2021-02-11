import Foundation
// swiftlint:disable trailing_whitespace

/**
 Default error types used in SDK error calls.
 */
public enum ErrorInformationType {
    /**
     General purpose error.
     */
    case commonError(errorMessage: String)
    
    /**
     General purpose error for Publisher SDK
     */
    case publisherError(inObject: Any, errorMessage: String)
    
    /**
     General purpose error for Subscriber SDK
     */
    case subscriberError(inObject: Any, errorMessage: String)
    
    /**
     Thrown in case of failed JSON Encoding/Decoding using `Codable+EncodedString` or `Decodable+FromJSONString`
     */
    case JSONCodingError(for: String)
    
    /**
     Thrown in case of missing properties in builder
     */
    case incompleteConfiguration(missingProperty: String, forBuilderOption: String)
    
    var message: String {
        switch self {
        case .commonError(let errorMessage): return "Error: \(errorMessage)"
        case .publisherError(let object, let errorMessage): return "PublisherError in: \(object.self) || ErrorMessage: \(errorMessage)"
        case .subscriberError(let object, let errorMessage): return "SubscriberError in: \(object.self) || ErrorMessage: \(errorMessage)"
        case .JSONCodingError(let object): return "Error while parsing: \(object)"
        case .incompleteConfiguration(let missingProperty, let builderOption): return "Missing mandatory property: \(missingProperty). Did you forgot to call `\(builderOption)` on builder object?"
        }
    }
}

/**
 Information about an error reported by the Ably service.
 */
public class ErrorInformation: NSObject, Error {
    /**
     Ably specific error code. Defined [here](https://github.com/ably/ably-common/blob/main/protocol/errors.json).
     */
    @objc public let code: Int
    
    /**
     Analogous to HTTP status code.
     */
    @objc public let statusCode: Int
    
    /**
     An explanation of what went wrong, in a format readable by humans.
     Can be written to logs or presented to users, but is not intended to be machine parsed.
     */
    @objc public let message: String
    
    /**
     An error underlying this error which caused this failure.
     */
    @objc public let cause: Error?
    
    /**
     Creates an ErrorInformation instance representing an error generated internally from within the Ably Asset Tracking SDK.
     */
    public init(code: Int, statusCode: Int, message: String, cause: Error?) {
        self.code = code
        self.statusCode = statusCode
        self.message = message
        self.cause = cause
    }
    
    public init(error: Error) {
        self.code = 100000
        self.statusCode = 0
        self.message = error.localizedDescription
        self.cause = error
    }
    
    public init(type: ErrorInformationType) {
        self.code = 100000
        self.statusCode = 0
        self.message = type.message
        self.cause = nil
    }
}
