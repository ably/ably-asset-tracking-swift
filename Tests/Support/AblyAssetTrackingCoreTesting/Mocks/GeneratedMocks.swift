// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import AblyAssetTrackingCore





















public class LogHandlerMock: LogHandler {

    public init() {}


    //MARK: - logMessage

    public var logMessageLevelMessageErrorCallsCount = 0
    public var logMessageLevelMessageErrorCalled: Bool {
        return logMessageLevelMessageErrorCallsCount > 0
    }
    public var logMessageLevelMessageErrorReceivedArguments: (level: LogLevel, message: String, error: Error?)?
    public var logMessageLevelMessageErrorReceivedInvocations: [(level: LogLevel, message: String, error: Error?)] = []
    public var logMessageLevelMessageErrorClosure: ((LogLevel, String, Error?) -> Void)?

    public func logMessage(level: LogLevel, message: String, error: Error?) {
        logMessageLevelMessageErrorCallsCount += 1
        logMessageLevelMessageErrorReceivedArguments = (level: level, message: message, error: error)
        logMessageLevelMessageErrorReceivedInvocations.append((level: level, message: message, error: error))
        logMessageLevelMessageErrorClosure?(level, message, error)
    }

}
