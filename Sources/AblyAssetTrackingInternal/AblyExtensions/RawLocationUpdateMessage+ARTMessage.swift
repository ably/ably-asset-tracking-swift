import Ably

public extension RawLocationUpdateMessage {
    // swiftlint:disable:next missing_docs
    func toARTMessage() throws -> ARTMessage {
        let data = try toJSONString()

        return ARTMessage(name: EventName.raw.rawValue, data: data)
    }
}
