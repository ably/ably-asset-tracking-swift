/**
 Completion handler for operations
 */
public typealias ResultHandler<T: Any> = (Result<T, ErrorInformation>) -> Void

extension Result where Success == Void {
    static var success: Result {
        return .success(Void())
    }
}
