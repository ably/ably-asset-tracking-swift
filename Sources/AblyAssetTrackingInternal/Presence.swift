/**
 Wrapper for ``ARTPresenceAction`` to hide ``Ably`` interface
 */
public enum Presence {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}
