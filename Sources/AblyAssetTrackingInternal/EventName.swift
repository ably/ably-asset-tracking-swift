import Foundation

public enum EventName: String {
    case raw
    case enhanced
    /**
     * The trip event naming approach (e.g. `trip.start`) is similar to what we use in
     * lifecycle events on Ably metachannels (see
     * [Lifecycle Events](https://ably.com/documentation/realtime/metachannels#lifecycle-events)).
     *
     * This way we align the metachannel message format.
     */
    case tripStart = "trip.start"
    case tripEnd = "trip.end"
}
