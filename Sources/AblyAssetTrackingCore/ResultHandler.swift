/**
 Completion handler for operations
 */
public typealias ResultHandler<T: Any> = (Result<T, ErrorInformation>) -> Void

public extension Result where Success == Void {
    // swiftlint:disable:next missing_docs
    static var success: Result {
        .success(Void())
    }
}
