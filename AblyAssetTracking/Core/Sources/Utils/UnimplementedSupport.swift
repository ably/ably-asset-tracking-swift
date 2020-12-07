import Foundation

/**
 Wrapper function for assertionFailure which fails only in debug builds.
 */
func failWithNotYetImplemented(file: String = #file, line: Int = #line, function: String = #function) {
    assertionFailure("Not implemented yet: \(file):\(line) - \(function)")
}
