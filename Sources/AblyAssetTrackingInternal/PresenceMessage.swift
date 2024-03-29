// swiftlint:disable missing_docs

public enum PresenceAction {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}

extension PresenceAction: Equatable {}

public enum PresenceType {
    case publisher
    case subscriber
}

extension PresenceType: Equatable {}

/**
 Wrapper for ``ARTPresenceMessage`` to hide ``Ably`` interface
 */
public struct PresenceMessage {
    public let action: PresenceAction
    public let data: PresenceData

    /**
     Combination of Ably `clientId` and `connectionId`.
     See: https://sdk.ably.com/builds/ably/specification/main/features/#TP3h
     */
    public let memberKey: String

    public init(action: PresenceAction, data: PresenceData, memberKey: String) {
        self.action = action
        self.data = data
        self.memberKey = memberKey
    }
}

extension PresenceMessage: Equatable {}
