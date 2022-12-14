import Foundation

/// Represents the contents of a log message emitted by AblyAssetTrackingInternal’s ``DefaultInternalLogHandler``.
public struct SDKLogMessage: Equatable {
    /// The subsystems described by the log message, starting with the subsystem of lowest granularity.
    public var subsystems: [String]
    
    /// Represents the source code location described by a log message.
    public struct CodeLocation: Equatable {
        public var file: String
        public var line: Int
        
        public init(file: String, line: Int) {
            self.file = file
            self.line = line
        }
    }
    
    /// The source code location described by the log message, if any.
    public var codeLocation: CodeLocation?
    
    /// The free-text message contained in the log message.
    public var message: String
    
    public enum ParsingError: Error {
        case doesNotMatchExpectedPattern
        case firstSubsystemIsNotAssetTracking
    }
    
    private static let regex = {
        let pattern = "^\\[([^\\]]*)\\](?:@(?:\\(([^:]+):(\\d+)\\)))? (.*)$"
        return try! NSRegularExpression(pattern: pattern)
    }()
    
    /// Creates an instance from a message emitted by ``DefaultInternalLogHandler``.
    /// - Parameter emittedMessage: A message emitted by ``DefaultInternalLogHandler``. For example, `"[assetTracking.someComponent]@(MyFile.swift:130) Here is a message"`.
    public init(emittedMessage: String) throws {
        let emittedMessageNSString = emittedMessage as NSString
        
        let result = Self.regex.firstMatch(in: emittedMessage, range: NSRange(0..<emittedMessageNSString.length))
        
        guard let result else {
            throw ParsingError.doesNotMatchExpectedPattern
        }
        
        // The "e.g." below are with reference to the emittedMessage "[assetTracking.someComponent]@(MyFile.swift:130) Here is a message"
        
        // e.g. "assetTracking.someComponent"
        let joinedSubsystems = emittedMessageNSString.substring(with: result.range(at: 1))
        let subsystems = joinedSubsystems.components(separatedBy: ".")
        
        guard subsystems.first == "assetTracking" else {
            throw ParsingError.firstSubsystemIsNotAssetTracking
        }
        
        self.subsystems = subsystems
        
        if result.range(at: 2).location != NSNotFound {
            // e.g. "MyFile.swift"
            let file = emittedMessageNSString.substring(with: result.range(at: 2))
            
            // e.g. "130"
            let lineString = emittedMessageNSString.substring(with: result.range(at: 3))
            let line = Int(lineString)!
            
            self.codeLocation = .init(file: file, line: line)
        } else {
            self.codeLocation = nil
        }
        
        // e.g. "Here is a message"
        self.message = emittedMessageNSString.substring(with: result.range(at: 4))
    }
    
    public init(subsystems: [String], codeLocation: CodeLocation?, message: String) {
        self.subsystems = subsystems
        self.codeLocation = codeLocation
        self.message = message
    }
}
