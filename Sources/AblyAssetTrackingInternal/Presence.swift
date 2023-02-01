public enum PresenceAction {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}

public enum PresenceType {
    case publisher
    case subscriber
}

/**
 Wrapper for ``ARTPresenceMessage`` to hide ``Ably`` interface
 */
public struct Presence {
    public let action: PresenceAction
    public let type: PresenceType
    
    public init(action: PresenceAction, type: PresenceType) {
        self.action = action
        self.type = type
    }
}
