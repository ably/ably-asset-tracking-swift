import Foundation

/**
 Default error used in SDK error calls.
 */
enum AblyError: Error {
    
    /**
     Called when we cannot parse data received from Ably or data is invalid.
     */
    case inconsistentData(String)
    
    /**
    General purpose error for Publisher SDK
     */
    case publisherError(String)
}
