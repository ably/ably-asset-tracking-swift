import Foundation

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
    case publisherError(errorMessage: String)
    
    /**
     General purpose error for Subscriber SDK
     */
    case subscriberError(errorMessage: String)
    
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
        case .publisherError(let errorMessage): return "PublisherError || ErrorMessage: \(errorMessage)"
        case .subscriberError(let errorMessage): return "SubscriberError || ErrorMessage: \(errorMessage)"
        case .JSONCodingError(let object): return "Error while parsing: \(object)"
        case .incompleteConfiguration(let missingProperty, let builderOption): return "Missing mandatory property: \(missingProperty). Did you forgot to call `\(builderOption)` on builder object?"
        }
    }
}

/**
 Information about an error reported by the Ably service.
 */
public class ErrorInformation: Error, CustomNSError, CustomStringConvertible {
    /**
     Ably specific error code. Defined [here](https://github.com/ably/ably-common/blob/main/protocol/errors.json).
     */
    public let code: Int
    
    /**
     Analogous to HTTP status code.
     */
    public let statusCode: Int
    
    /**
     An explanation of what went wrong, in a format readable by humans.
     Can be written to logs or presented to users, but is not intended to be machine parsed.
     */
    public let message: String
    
    /**
     An error underlying this error which caused this failure.
     */
    public let cause: Error?
    
    
    public var description: String {
        return message.isEmpty
            ? localizedDescription
            : message
    }
    
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

extension ErrorInformation: Equatable {
    public static func == (lhs: ErrorInformation, rhs: ErrorInformation) -> Bool {
        return lhs.code == rhs.code &&
               lhs.statusCode == rhs.statusCode &&
               lhs.message == rhs.message &&
               lhs.cause?.localizedDescription == rhs.cause?.localizedDescription
    }
}
