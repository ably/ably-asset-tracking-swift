struct ProxyDTO: Decodable {
    var listenPort: Int
}

struct FaultSimulationDTO: Decodable {
    var id: String
    var name: String
    var type: FaultTypeDTO
    var proxy: ProxyDTO
}

/**
 * Describes the nature of a given fault simulation, and specifically the impact that it
 * should have on any Trackables or channel activity during and after resolution.
 */
enum FaultTypeDTO: Decodable {
    /**
     * AAT and/or ably-cocoa should handle this fault seamlessly. Trackable state should be
     * online and publisher should be present within `resolvedWithinMillis`. It's possible
     * the fault will cause a brief Offline blip, but tests should expect to see Trackables
     * Online again before `resolvedWithinMillis` expires regardless.
     */
    case nonfatal(resolvedWithinMillis: Int)

    // TODO update link to [FaultSimulation.resolve] once we've decided on this API in #538
    /**
     * This is a non-fatal error, but will persist until the [FaultSimulation.resolve]
     * method has been called. Trackable states should be offline during the fault within
     * `offlineWithinMillis` maximum. When the fault is resolved, Trackables should return
     * online within `onlineWithinMillis` maximum.
     */
    case nonfatalWhenResolved(offlineWithinMillis: Int, onlineWithinMillis: Int)

    /**
     * This is a fatal error and should permanently move Trackables to the Failed state.
     * The publisher should not be present in the corresponding channel any more and no
     * further location updates will be published. Tests should check that Trackables reach
     * the Failed state within `failedWithinMillis`.
     */
    case fatal(failedWithinMillis: Int)

    private enum CodingKeys: CodingKey {
        case type
        case resolvedWithinMillis
        case offlineWithinMillis
        case onlineWithinMillis
        case failedWithinMillis
    }

    private enum FaultTypeDiscriminatorDTO: String, Decodable {
        case nonfatal
        case nonfatalWhenResolved
        case fatal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(FaultTypeDiscriminatorDTO.self, forKey: .type)

        switch discriminator {
        case .nonfatal:
            let resolvedWithinMillis = try container.decode(Int.self, forKey: .resolvedWithinMillis)
            self = .nonfatal(resolvedWithinMillis: resolvedWithinMillis)
        case .nonfatalWhenResolved:
            let offlineWithinMillis = try container.decode(Int.self, forKey: .offlineWithinMillis)
            let onlineWithinMillis = try container.decode(Int.self, forKey: .onlineWithinMillis)
            self = .nonfatalWhenResolved(offlineWithinMillis: offlineWithinMillis, onlineWithinMillis: onlineWithinMillis)
        case .fatal:
            let failedWithinMillis = try container.decode(Int.self, forKey: .failedWithinMillis)
            self = .fatal(failedWithinMillis: failedWithinMillis)
        }
    }
}
