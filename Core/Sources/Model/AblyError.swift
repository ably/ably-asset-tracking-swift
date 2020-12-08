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
    Called while attempting to track another channel
     */
    case alreadyConnectedToChannel
    
    /**
    General purpose error for Publisher SDK
     */
    case publisherError(String)
}
