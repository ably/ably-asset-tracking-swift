import Foundation
import os.log

enum AblyLoggerSubsystem: String {
    case publisher = "io.ably.asset-tracking.Publisher"
    case subscriber = "io.ably.asset-tracking.Subscriber"
}

class AblyLogger {
    private let logger: OSLog
    
    init(subsystem: AblyLoggerSubsystem, category: String) {
        self.logger = OSLog(subsystem: subsystem.rawValue, category: category)
    }
    
    func `default`(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .default, args: args)
    }
    
    func info(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .info, args: args)
    }
    
    func debug(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .debug, args: args)
    }
    
    func error(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .error, args: args)
    }
    
    func fault(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .fault, args: args)
    }
    
    private func log(_ message: StaticString, type: OSLogType, args: [CVarArg]) {
        switch args.count {
        case 0:
            os_log(message, log: logger, type: type)
        case 1:
            os_log(message, log: logger, type: type, args[0])
        case 2:
            os_log(message, log: logger, type: type, args[0], args[1])
        case 3:
            os_log(message, log: logger, type: type, args[0], args[1], args[2])
        default:
            assertionFailure("Unsupported number of logs.")
            break
        }
    }
}
