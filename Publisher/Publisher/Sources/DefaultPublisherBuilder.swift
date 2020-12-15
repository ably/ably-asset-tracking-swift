import UIKit
import Core

class DefaultPublisherBuilder: PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var transportationMode: TransportationMode?
    private weak var delegate: PublisherDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 transportationMode: TransportationMode?,
                 delegate: PublisherDelegate?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.transportationMode = transportationMode
        self.delegate = delegate
    }

    func start() throws -> Publisher {
        guard let connection = connection
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: ConnectionConfiguration. Did you forgot to call `connection` on builder object?"
            )
        }

        guard let logConfiguration = logConfiguration
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: LogConfiguration. Did you forgot to call `log` on builder object?"
            )
        }

        guard let transportationMode = transportationMode
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: TransportationMode. Did you forgot to call `transportationMode` on builder object?"
            )
        }

        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          logConfiguration: logConfiguration,
                                          transportationMode: transportationMode)
        publisher.delegate = delegate
        return publisher
    }

    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: configuration,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate)
    }

    func log(_ configuration: LogConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: configuration,
                                       transportationMode: transportationMode,
                                       delegate: delegate)
    }

    func transportationMode(_ transportationMode: TransportationMode) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate)
    }

    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate)
    }
}
