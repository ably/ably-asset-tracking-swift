/**
 Wrapper enum for `ARTPresenceAction` to avoid using `Ably SDK` classes in Publisher code
 */
public enum AblyPresence {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}

