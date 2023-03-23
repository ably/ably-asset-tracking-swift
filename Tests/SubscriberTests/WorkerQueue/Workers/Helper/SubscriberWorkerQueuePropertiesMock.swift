@testable import AblyAssetTrackingSubscriber

/// Provides a mocked instance of `SubscriberWorkerQueueProperties`, with access to the underlying mock.
struct SubscriberWorkerQueuePropertiesMock {
    /// A `SubscriberWorkerQueueProperties` instance, whose `specific` property is `self.specificMock`.
    let properties: SubscriberWorkerQueueProperties

    /// A mock implementation of `SubscriberSpecificWorkerQueuePropertiesProtocol`. There is no configuration applied to this mock; that is the responsibility of test writers.
    let specificMock = SubscriberSpecificWorkerQueuePropertiesProtocolMock()

    /// Creates a mocked instance of `SubscriberWorkerQueueProperties`.
    ///
    /// Parameters:
    /// - isStopped: The value to be returned by the properties object’s `isStopped` property.
    init(isStopped: Bool) {
        self.properties = .init(isStopped: isStopped, specific: specificMock)
    }
}
