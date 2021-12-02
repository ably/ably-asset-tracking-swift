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
    enum Unwrapped<T> {
        case success(T)
        case failure(ErrorInformation)
    }
    
    var enumUnwrap: Unwrapped<Void> {
        if let failure = failure {
            return .failure(failure)
        }
        
        return .success(Void())
    }
    
    func enumUnwrap<T>(_:T.Type) -> Unwrapped<T> {
        if let failure = failure {
            return .failure(failure)
        } else if let success = success {
            if let casted = success as? T {
                return .success(casted)
            } else {
                fatalError("Unable to cast \(type(of: success)) to `\(T.self)`")
            }
        }
        
        return .success(Void() as! T)
    }
}
