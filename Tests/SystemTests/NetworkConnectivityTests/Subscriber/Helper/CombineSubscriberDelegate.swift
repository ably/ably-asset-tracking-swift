import AblyAssetTrackingInternal
import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import class Combine.CurrentValueSubject
import struct Combine.AnyPublisher

extension SubscriberNetworkConnectivityTests {
    /// A helper implementation of `SubscriberDelegate` which exposes Combine publishers which emit the events sent by a `Subscriber` to its delegate.
    ///
    /// The idea of this class is to allow us to keep the implementation of the subscriber `NetworkConnectivityTests` as similar to those of Android as possible. The Android `Subscriber` does not use a delegate pattern; rather, it uses [Kotlin flows](https://kotlinlang.org/docs/flow.html) to emit values over time.
    ///
    /// Furthermore, the Android version of the subscriber `NetworkConnectivityTests` relies on some specific behaviours of the flow types provided by Kotlin. This class reproduces those behaviours as much as is necessary to satisfy the tests.
    class CombineSubscriberDelegate: SubscriberDelegate {
        private let logHandler: InternalLogHandler

        /// Publishes the connection status values received by ``SubscriberDelegate.subscriber(sender:,didChangeTrackableState:)``.
        ///
        /// This is meant to mimic Android’s `_trackableStates = MutableStateFlow(TrackableState.Offline())`.
        ///
        /// This publisher sends the latest received value to each new subscriber, to mimic the behaviour of a Kotlin `StateFlow`. Unlike a `StateFlow`, however, this publisher does not publish an initial value.
        let trackableStates: AnyPublisher<TrackableState, Never>
        private let trackableStatesSubject = CurrentValueSubject<TrackableState?, Never>(nil)

        /// Publishes the resolution values received by ``SubscriberDelegate.subscriber(sender:,didUpdateResolution:)``.
        ///
        /// This is meant to mimic Android’s `_resolutions = MutableSharedFlow(replay = 1)`.
        ///
        /// This publisher sends the latest received value to each new subscriber, to mimic the behaviour of a Kotlin `SharedFlow` with `replay = 1`.
        let resolutions: AnyPublisher<Resolution, Never>
        private let resolutionsSubject = CurrentValueSubject<Resolution?, Never>(nil)

        /// Publishes the resolution values received by ``SubscriberDelegate.subscriber(sender:,didUpdatePublisherPresence:)``.
        ///
        /// This is meant to mimic Android’s `_publisherPresence = MutableStateFlow(false)`.
        ///
        /// This publisher sends the latest received value to each new subscriber, to mimic the behaviour of a Kotlin `StateFlow`. Unlike a `StateFlow`, however, this publisher does not publish an initial value.
        let publisherPresence: AnyPublisher<Bool, Never>
        private let publisherPresenceSubject = CurrentValueSubject<Bool?, Never>(nil)

        /// Publishes the location values received by ``SubscriberDelegate.subscriber(sender:,didUpdateEnhancedLocation:)``.
        ///
        /// This is meant to mimic Android’s `_enhancedLocations = MutableSharedFlow(replay = 1)`.
        ///
        /// This publisher sends the latest received value to each new subscriber, to mimic the behaviour of a Kotlin `SharedFlow` with `replay = 1`.
        let locations: AnyPublisher<LocationUpdate, Never>
        private let locationsSubject = CurrentValueSubject<LocationUpdate?, Never>(nil)

        init(logHandler: InternalLogHandler) {
            self.trackableStates = trackableStatesSubject.compactMap { $0 }.eraseToAnyPublisher()
            self.resolutions = resolutionsSubject.compactMap { $0 }.eraseToAnyPublisher()
            self.publisherPresence = publisherPresenceSubject.compactMap { $0 }.eraseToAnyPublisher()
            self.locations = locationsSubject.compactMap { $0 }.eraseToAnyPublisher()

            self.logHandler = logHandler.addingSubsystem(Self.self)
        }

        // MARK: SubscriberDelegate

        func subscriber(sender: Subscriber, didChangeTrackableState state: TrackableState) {
            logHandler.debug(message: "Delegate received subscriber(sender:,didChangeTrackableState:) - status \(state)", error: nil)
            trackableStatesSubject.value = state
            logHandler.debug(message: "Sent state \(state) to _trackableStates", error: nil)
        }

        func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution) {
            logHandler.debug(message: "Delegate received subscriber(sender:,didUpdateResolution:) - resolution \(resolution)", error: nil)
            resolutionsSubject.value = resolution
            logHandler.debug(message: "Sent resolution \(resolution) to _resolutions", error: nil)
        }

        func subscriber(sender: Subscriber, didUpdatePublisherPresence isPresent: Bool) {
            logHandler.debug(message: "Delegate received subscriber(sender:,didUpdatePublisherPresence:) - isPresent \(isPresent)", error: nil)
            publisherPresenceSubject.value = isPresent
            logHandler.debug(message: "Sent isPresent \(isPresent) to _publisherPresence", error: nil)
        }

        func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
            logHandler.debug(message: "Delegate received subscriber(sender:,didUpdateEnhancedLocation:) - locationUpdate \(locationUpdate)", error: nil)
            locationsSubject.value = locationUpdate
            logHandler.debug(message: "Sent locationUpdate to _locations", error: nil)
        }

        func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
            logHandler.error(message: "Delegate received subscriber(sender:,didFailWithError:", error: error)
        }
    }
}
