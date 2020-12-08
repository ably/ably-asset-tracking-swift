import Foundation

/**
 Wrapper function for preconditionFailure which fails in debug and production builds.
 */
func failWithNotYetImplemented(file: String = #file, line: Int = #line, function: String = #function) {
    preconditionFailure("Not implemented yet: \(file):\(line) - \(function)")
}
