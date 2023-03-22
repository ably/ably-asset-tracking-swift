/// Internal-only type for configuring some properties of `ARTClientOptions` which we do not wish to expose through the public `ConnectionConfiguration` interface. Intended for use in testing.
public struct Host {
    // swiftlint:disable:next missing_docs
    public var realtimeHost: String
    // swiftlint:disable:next missing_docs
    public var port: Int
    // swiftlint:disable:next missing_docs
    public var tls: Bool

    // swiftlint:disable:next missing_docs
    public init(realtimeHost: String, port: Int, tls: Bool) {
        self.realtimeHost = realtimeHost
        self.port = port
        self.tls = tls
    }
}
