import AblyAssetTrackingCore

public enum Subsystem {
    case named(String)
    case typed(Any.Type)
    
    var name: String {
        switch self {
        case .named(let name):
            return name
        case .typed(let type):
            return String(describing: type)
        }
    }
}

public protocol HierarchicalLogHandler: LogHandler {
    func addingSubsystem(_ subsystem: Subsystem) -> HierarchicalLogHandler
}

extension HierarchicalLogHandler {
    public func addingSubsystem(_ type: Any.Type) -> HierarchicalLogHandler {
        return addingSubsystem(.typed(type))
    }
}
