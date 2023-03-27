// swiftlint:disable missing_docs
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
public struct PresenceMessage {
    public let action: PresenceAction
    public let type: PresenceType
}
