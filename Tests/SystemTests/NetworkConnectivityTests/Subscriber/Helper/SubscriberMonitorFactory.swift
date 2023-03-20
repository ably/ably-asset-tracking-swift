import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import Foundation
import struct Combine.AnyPublisher

extension SubscriberNetworkConnectivityTests {
    class SubscriberMonitorFactory {
        private let sharedState: SubscriberMonitor.SharedState
        private let subscriber: Subscriber
        private let logHandler: InternalLogHandler
        private let trackableID: String
        private let faultType: FaultTypeDTO
        private let subscriberClientID: String
        private let subscriberResolutionPreferences: AnyPublisher<Resolution, Never>

        init(subscriber: Subscriber, combineSubscriberDelegate: CombineSubscriberDelegate, logHandler: InternalLogHandler, trackableID: String, faultType: FaultTypeDTO, subscriberClientID: String, subscriberResolutionPreferences: AnyPublisher<Resolution, Never>) {
            self.sharedState = .init(combineSubscriberDelegate: combineSubscriberDelegate)
            self.subscriber = subscriber
            self.logHandler = logHandler
            self.trackableID = trackableID
            self.faultType = faultType
            self.subscriberClientID = subscriberClientID
            self.subscriberResolutionPreferences = subscriberResolutionPreferences
        }

        /**
         * Construct `SubscriberMonitor` configured to expect appropriate state transitions
         * for the given fault type while it is active. `label` will be used for logging captured transitions.
         */
        func forActiveFault(
            label: String,
            locationUpdate: Location? = nil,
            publisherResolution: Resolution? = nil,
            publisherDisconnected: Bool = false,
            subscriberResolution: Resolution? = nil
        ) -> SubscriberMonitor {
            let expectedState: TrackableState
            switch faultType {
            case .fatal:
                expectedState = .failed
            case .nonfatal where publisherDisconnected:
                expectedState = .offline
            case .nonfatal:
                expectedState = .online
            case .nonfatalWhenResolved:
                expectedState = .offline
            }

            let failureStates: Set<TrackableState>
            switch faultType {
            case .fatal:
                failureStates = [.offline]
            case .nonfatal, .nonfatalWhenResolved:
                failureStates = [.failed]
            }

            let expectedSubscriberPresence: Bool?
            switch faultType {
            case .nonfatal:
                expectedSubscriberPresence = true
            case .nonfatalWhenResolved:
                expectedSubscriberPresence = nil
            case .fatal:
                expectedSubscriberPresence = false
            }

            let expectedPublisherPresence: Bool
            switch faultType {
            case .nonfatal:
                expectedPublisherPresence = !publisherDisconnected
            case .nonfatalWhenResolved, .fatal:
                expectedPublisherPresence = false
            }

            let timeout: TimeInterval
            switch faultType {
            case let .fatal(failedWithinMillis: failedWithinMillis):
                timeout = Double(failedWithinMillis) / 1000
            case let .nonfatal(resolvedWithinMillis: resolvedWithinMillis):
                timeout = Double(resolvedWithinMillis) / 1000
            case let .nonfatalWhenResolved(offlineWithinMillis: offlineWithinMillis, _):
                timeout = Double(offlineWithinMillis) / 1000
            }

            return SubscriberMonitor(
                sharedState: sharedState,
                logHandler: logHandler,
                subscriber: subscriber,
                subscriberClientID: subscriberClientID,
                label: label,
                trackableID: trackableID,
                expectedState: expectedState,
                failureStates: failureStates,
                expectedSubscriberPresence: expectedSubscriberPresence,
                expectedPublisherPresence: expectedPublisherPresence,
                expectedLocation: locationUpdate,
                expectedPublisherResolution: publisherResolution,
                expectedSubscriberResolution: subscriberResolution,
                timeout: timeout,
                subscriberResolutionPreferences: subscriberResolutionPreferences
            )
        }

        /**
         * Construct `SubscriberMonitor` configured to expect appropriate state transitions
         * for the given fault type while it is active but the subscriber is shutting down.
         *
         * `label` will be used for logging captured transitions.
         */
        func forActiveFaultWhenShuttingDownSubscriber(
            label: String,
            locationUpdate: Location? = nil,
            publisherResolution: Resolution? = nil,
            publisherDisconnected: Bool = false,
            subscriberResolution: Resolution? = nil
        ) -> SubscriberMonitor {
            let expectedState: TrackableState
            switch faultType {
            case .fatal:
                expectedState = .failed
            case .nonfatal, .nonfatalWhenResolved:
                expectedState = .offline
            }

            let failureStates: Set<TrackableState>
            switch faultType {
            case .fatal:
                failureStates = [.online, .offline]
            case .nonfatal, .nonfatalWhenResolved:
                failureStates = [.failed]
            }

            let expectedSubscriberPresence: Bool
            switch faultType {
            case .nonfatal, .fatal:
                expectedSubscriberPresence = false
            case .nonfatalWhenResolved:
                expectedSubscriberPresence = true
            }

            let expectedPublisherPresence: Bool
            switch faultType {
            case .nonfatal:
                expectedPublisherPresence = !publisherDisconnected
            case .nonfatalWhenResolved, .fatal:
                expectedPublisherPresence = false
            }

            let timeout: TimeInterval
            switch faultType {
            case .fatal(let failedWithinMillis):
                timeout = Double(failedWithinMillis) / 1000
            case .nonfatal(let resolvedWithinMillis):
                timeout = Double(resolvedWithinMillis) / 1000
            case .nonfatalWhenResolved(let offlineWithinMillis, _):
                timeout = Double(offlineWithinMillis) / 1000
            }

            return SubscriberMonitor(
                sharedState: sharedState,
                logHandler: logHandler,
                subscriber: subscriber,
                subscriberClientID: subscriberClientID,
                label: label,
                trackableID: trackableID,
                expectedState: expectedState,
                failureStates: failureStates,
                expectedSubscriberPresence: expectedSubscriberPresence,
                expectedPublisherPresence: expectedPublisherPresence,
                expectedLocation: locationUpdate,
                expectedPublisherResolution: publisherResolution,
                expectedSubscriberResolution: subscriberResolution,
                timeout: timeout,
                subscriberResolutionPreferences: subscriberResolutionPreferences
            )
        }

        /**
         * Construct a `SubscriberMonitor` configured to expect appropriate transitions for
         * the given fault type after it has been resolved. `label` is used for logging.
         */
        func forResolvedFault(
            label: String,
            locationUpdate: Location? = nil,
            publisherResolution: Resolution? = nil,
            expectedPublisherPresence: Bool = true,
            subscriberResolution: Resolution? = nil
        ) -> SubscriberMonitor {
            let expectedState: TrackableState
            if !expectedPublisherPresence {
                expectedState = .offline
            } else {
                switch faultType {
                case .fatal:
                    expectedState = .failed
                case .nonfatal, .nonfatalWhenResolved:
                    expectedState = .online
                }
            }

            let failureStates: Set<TrackableState>
            switch faultType {
            case .fatal:
                failureStates = [.offline, .online]
            case .nonfatal, .nonfatalWhenResolved:
                failureStates = [.failed]
            }

            let expectedSubscriberPresence: Bool
            switch faultType {
            case .fatal:
                expectedSubscriberPresence = false
            case .nonfatal, .nonfatalWhenResolved:
                expectedSubscriberPresence = true
            }

            let timeout: TimeInterval
            switch faultType {
            case .fatal(let failedWithinMillis):
                timeout = Double(failedWithinMillis) / 1000
            case .nonfatal(let resolvedWithinMillis):
                timeout = Double(resolvedWithinMillis) / 1000
            case .nonfatalWhenResolved(let offlineWithinMillis, _):
                timeout = Double(offlineWithinMillis) / 1000
            }

            return SubscriberMonitor(
                sharedState: sharedState,
                logHandler: logHandler,
                subscriber: subscriber,
                subscriberClientID: subscriberClientID,
                label: label,
                trackableID: trackableID,
                expectedState: expectedState,
                failureStates: failureStates,
                expectedSubscriberPresence: expectedSubscriberPresence,
                expectedPublisherPresence: expectedPublisherPresence,
                expectedLocation: locationUpdate,
                expectedPublisherResolution: publisherResolution,
                expectedSubscriberResolution: subscriberResolution,
                timeout: timeout,
                subscriberResolutionPreferences: subscriberResolutionPreferences
            )
        }

        /**
         * Construct a `SubscriberMonitor` configured to expect appropriate transitions for
         * the given fault type after it has been resolved and the publisher is stopped.
         *
         * `label` is used for logging.
         */
        func forResolvedFaultWithSubscriberStopped(
            label: String,
            locationUpdate: Location? = nil,
            publisherResolution: Resolution? = nil,
            subscriberResolution: Resolution? = nil
        ) -> SubscriberMonitor {
            let timeout: TimeInterval
            switch faultType {
            case .fatal(let failedWithinMillis):
                timeout = Double(failedWithinMillis) / 1000
            case .nonfatal(let resolvedWithinMillis):
                timeout = Double(resolvedWithinMillis) / 1000
            case .nonfatalWhenResolved(let offlineWithinMillis, _):
                timeout = Double(offlineWithinMillis) / 1000
            }

            return SubscriberMonitor(
                sharedState: sharedState,
                logHandler: logHandler,
                subscriber: subscriber,
                subscriberClientID: subscriberClientID,
                label: label,
                trackableID: trackableID,
                expectedState: .offline,
                failureStates: [.failed],
                expectedSubscriberPresence: false,
                expectedPublisherPresence: true,
                expectedLocation: locationUpdate,
                expectedPublisherResolution: publisherResolution,
                expectedSubscriberResolution: subscriberResolution,
                timeout: timeout,
                subscriberResolutionPreferences: subscriberResolutionPreferences
            )
        }

        /**
         * Construct a `SubscriberMonitor` configured to expect a Trackable to come
         * online within a given timeout, and fail if the Failed state is seen at any point.
         */
        func onlineWithoutFail(
            label: String,
            timeout: TimeInterval,
            subscriberResolution: Resolution? = nil,
            locationUpdate: Location? = nil,
            publisherResolution: Resolution? = nil
        ) -> SubscriberMonitor {
            SubscriberMonitor(
                sharedState: sharedState,
                logHandler: logHandler,
                subscriber: subscriber,
                subscriberClientID: subscriberClientID,
                label: label,
                trackableID: trackableID,
                expectedState: .online,
                failureStates: [.failed],
                expectedSubscriberPresence: true,
                expectedPublisherPresence: true,
                expectedLocation: locationUpdate,
                expectedPublisherResolution: publisherResolution,
                expectedSubscriberResolution: subscriberResolution,
                timeout: timeout,
                subscriberResolutionPreferences: subscriberResolutionPreferences
            )
        }
    }
}
