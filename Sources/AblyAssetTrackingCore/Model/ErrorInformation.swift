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
     Thrown in case when Trackable with provided identifier already exist.
     */
    case trackableAlreadyExist(trackableId: String)
    
    /**
     Thrown in case when Publisher has already stopped.
     */
    case publisherStoppedException
    
    /**
     Thrown in case when Subscriber has already stopped.
     */
    case subscriberStoppedException
    
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
        case .trackableAlreadyExist(let trackableId): return "Trackable with id: \(trackableId) already exist."
        case .publisherStoppedException: return "Cannot perform this action when publisher is stopped."
        case .subscriberStoppedException: return "Cannot perform this action when subscriber is stopped."
        }
    }
}

/**
 Information about an error reported by the Ably service.
 */
public class ErrorInformation: NSObject, Error, CustomNSError {
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
    
    /**
     A URL for customers to find more help on the error code.
     */
    public let href: String?
    
    public override var description: String {
        return message.isEmpty
        ? localizedDescription
        : message
    }
    
    /**
     Creates an ErrorInformation instance representing an error generated internally from within the Ably Asset Tracking SDK.
     */
    public init(code: Int, statusCode: Int, message: String, cause: Error?, href: String?) {
        self.code = code
        self.statusCode = statusCode
        self.message = message
        self.cause = cause
        self.href = href
    }
    
    public init(error: Error) {
        self.code = 100000
        self.statusCode = 0
        self.message = (error as? ErrorInformation)?.message ?? error.localizedDescription
        self.cause = error
        self.href = nil
    }
    
    public init(type: ErrorInformationType) {
        self.code = 100000
        self.statusCode = 0
        self.message = type.message
        self.cause = nil
        self.href = nil
    }
}
