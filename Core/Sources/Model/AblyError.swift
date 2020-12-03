import Foundation

/**
 Default error used in SDK error calls.
 */
enum AblyError: Error {
    
    /**
     Called when there an incorrect data appears.
     */
    case inconsistentData(String)
}
