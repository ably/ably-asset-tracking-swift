// swiftlint:disable missing_docs
public enum PresenceAction: Equatable {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}

public enum PresenceType: Equatable {
    case publisher
    case subscriber
}

/**
 Wrapper for ``ARTPresenceMessage`` to hide ``Ably`` interface
 */
public struct PresenceMessage: Equatable {
    public let action: PresenceAction
    public let data: PresenceData
    
    /**
     Combination of Ably `clientId` and `connectionId`.
     See: https://sdk.ably.com/builds/ably/specification/main/features/#TP3h
     */
    public let memberKey: String
}
