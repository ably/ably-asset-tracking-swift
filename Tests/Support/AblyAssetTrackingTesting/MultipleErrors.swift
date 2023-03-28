/// Maintains a list of errors and provides a way to throw any contained errors.
///
/// Useful in the situation where you want to perform a sequence of operations, continuing even if one fails, and subsequently report on the result of these operations once they’ve all been attempted.
public struct MultipleErrors {
    private var errors: [Error] = []

    /// Creates a new `MultipleErrors` instance.
    public init() {}

    public enum MultipleErrorsError: Error {
        case multipleErrors([Error])
    }

    /// Adds an error to the list.
    public mutating func add(_ error: Error) {
        errors.append(error)
    }

    /// Throws any errors in the list.
    ///
    /// - If the list of errors is empty, this does nothing.
    /// - If the list of errors contains a single error, this throws that error.
    /// - If the list of errors contains multiple errors, this throws a ``MultipleErrorsError.multipleErrors`` describing those errors.
    public func check() throws {
        if errors.isEmpty {
            return
        }

        if errors.count == 1 {
            throw errors[0]
        }

        throw MultipleErrorsError.multipleErrors(errors)
    }
}
