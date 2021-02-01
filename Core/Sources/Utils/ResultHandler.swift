/**
 Completion handler for success operations
 */
public typealias SuccessHandler = () -> Void

/**
 Completion handler for failed operations
 */
public typealias ErrorHandler = (_ error: Error) -> Void
