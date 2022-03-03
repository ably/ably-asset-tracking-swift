import Ably

public extension RawLocationUpdateMessage {
    func toARTMessage() throws -> ARTMessage {
        let data = try toJSONString()
        
        return ARTMessage(name: EventName.raw.rawValue, data: data)
    }
}
