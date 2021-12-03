import Foundation

public typealias ResultHandler = (AATResult) -> Void

@objc
public protocol Resultable {
    var success: Any? { get }
    var failure: ErrorInformation? { get }
}

@objcMembers
public class AATResult: NSObject, Resultable {
    public let success: Any?
    public let failure: ErrorInformation?
    
    public static var success: AATResult {
        return .init(success: Void(), failure: nil)
    }
    
    public static func success(_ value: Any?) -> AATResult {
        return .init(success: value, failure: nil)
    }
    
    public static func failure(_ value: ErrorInformation?) -> AATResult {
        return .init(success: nil, failure: value)
    }
    
    public init(success: Any? = nil, failure: ErrorInformation? = nil) {
        self.success = success
        self.failure = failure
    }
    
    public override init() {
        self.success = nil
        self.failure = nil
        
        super.init()
    }
}

public extension AATResult {
    var unwrap: Result<Void, ErrorInformation> {
        if let value = failure {
            return .failure(value)
        }
        
        return .success(Void())
    }
    
    func unwrap<T>(_ :T.Type) -> Result<T, ErrorInformation> {
        if let value = failure {
            return .failure(value)
        } else if let value = success {
            if let casted = value as? T {
                return .success(casted)
            } else {
                fatalError("Unable to cast \(type(of: success)) to `\(T.self)`")
            }
        }
        
        return .success(Void() as! T)
    }
}
