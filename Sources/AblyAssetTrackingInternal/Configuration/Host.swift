/// Internal-only type for configuring some properties of `ARTClientOptions` which we do not wish to expose through the public `ConnectionConfiguration` interface. Intended for use in testing.
public struct Host {
    public var realtimeHost: String
    public var port: Int
    public var tls: Bool

    public init(realtimeHost: String, port: Int, tls: Bool) {
        self.realtimeHost = realtimeHost
        self.port = port
        self.tls = tls
    }
}
