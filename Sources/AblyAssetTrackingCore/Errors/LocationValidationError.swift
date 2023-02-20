import Foundation

/**
 This error should be thrown when there's an error validating a ``Location`` object
 generated by a location engine.
 */
public struct LocationValidationError: Error {
    public let errors: [Error]
    public let message: String
    
    public init(errors: [Error]) {
        self.errors = errors
        self.message = "Failed to validate a location object, errors: \(errors)"
    }
}
