// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import AblyAssetTrackingSubscriber





















public class SubscriberMock: Subscriber {

    public init() {}

    public var delegate: SubscriberDelegate?

    //MARK: - resolutionPreference

    public var resolutionPreferenceResolutionCompletionCallsCount = 0
    public var resolutionPreferenceResolutionCompletionCalled: Bool {
        return resolutionPreferenceResolutionCompletionCallsCount > 0
    }
    public var resolutionPreferenceResolutionCompletionReceivedArguments: (resolution: Resolution?, completion: ResultHandler<Void>)?
    public var resolutionPreferenceResolutionCompletionReceivedInvocations: [(resolution: Resolution?, completion: ResultHandler<Void>)] = []
    public var resolutionPreferenceResolutionCompletionClosure: ((Resolution?, @escaping ResultHandler<Void>) -> Void)?

    public func resolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        resolutionPreferenceResolutionCompletionCallsCount += 1
        resolutionPreferenceResolutionCompletionReceivedArguments = (resolution: resolution, completion: completion)
        resolutionPreferenceResolutionCompletionReceivedInvocations.append((resolution: resolution, completion: completion))
        resolutionPreferenceResolutionCompletionClosure?(resolution, completion)
    }

    //MARK: - stop

    public var stopCompletionCallsCount = 0
    public var stopCompletionCalled: Bool {
        return stopCompletionCallsCount > 0
    }
    public var stopCompletionReceivedCompletion: ResultHandler<Void>?
    public var stopCompletionReceivedInvocations: [ResultHandler<Void>] = []
    public var stopCompletionClosure: ((@escaping ResultHandler<Void>) -> Void)?

    public func stop(completion: @escaping ResultHandler<Void>) {
        stopCompletionCallsCount += 1
        stopCompletionReceivedCompletion = completion
        stopCompletionReceivedInvocations.append(completion)
        stopCompletionClosure?(completion)
    }

}
public class SubscriberDelegateMock: SubscriberDelegate {

    public init() {}


    //MARK: - subscriber

    public var subscriberSenderDidFailWithErrorCallsCount = 0
    public var subscriberSenderDidFailWithErrorCalled: Bool {
        return subscriberSenderDidFailWithErrorCallsCount > 0
    }
    public var subscriberSenderDidFailWithErrorReceivedArguments: (sender: Subscriber, error: ErrorInformation)?
    public var subscriberSenderDidFailWithErrorReceivedInvocations: [(sender: Subscriber, error: ErrorInformation)] = []
    public var subscriberSenderDidFailWithErrorClosure: ((Subscriber, ErrorInformation) -> Void)?

    public func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
        subscriberSenderDidFailWithErrorCallsCount += 1
        subscriberSenderDidFailWithErrorReceivedArguments = (sender: sender, error: error)
        subscriberSenderDidFailWithErrorReceivedInvocations.append((sender: sender, error: error))
        subscriberSenderDidFailWithErrorClosure?(sender, error)
    }

    //MARK: - subscriber

    public var subscriberSenderDidUpdateEnhancedLocationCallsCount = 0
    public var subscriberSenderDidUpdateEnhancedLocationCalled: Bool {
        return subscriberSenderDidUpdateEnhancedLocationCallsCount > 0
    }
    public var subscriberSenderDidUpdateEnhancedLocationReceivedArguments: (sender: Subscriber, locationUpdate: LocationUpdate)?
    public var subscriberSenderDidUpdateEnhancedLocationReceivedInvocations: [(sender: Subscriber, locationUpdate: LocationUpdate)] = []
    public var subscriberSenderDidUpdateEnhancedLocationClosure: ((Subscriber, LocationUpdate) -> Void)?

    public func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        subscriberSenderDidUpdateEnhancedLocationCallsCount += 1
        subscriberSenderDidUpdateEnhancedLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        subscriberSenderDidUpdateEnhancedLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        subscriberSenderDidUpdateEnhancedLocationClosure?(sender, locationUpdate)
    }

    //MARK: - subscriber

    public var subscriberSenderDidUpdateRawLocationCallsCount = 0
    public var subscriberSenderDidUpdateRawLocationCalled: Bool {
        return subscriberSenderDidUpdateRawLocationCallsCount > 0
    }
    public var subscriberSenderDidUpdateRawLocationReceivedArguments: (sender: Subscriber, locationUpdate: LocationUpdate)?
    public var subscriberSenderDidUpdateRawLocationReceivedInvocations: [(sender: Subscriber, locationUpdate: LocationUpdate)] = []
    public var subscriberSenderDidUpdateRawLocationClosure: ((Subscriber, LocationUpdate) -> Void)?

    public func subscriber(sender: Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate) {
        subscriberSenderDidUpdateRawLocationCallsCount += 1
        subscriberSenderDidUpdateRawLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        subscriberSenderDidUpdateRawLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        subscriberSenderDidUpdateRawLocationClosure?(sender, locationUpdate)
    }

    //MARK: - subscriber

    public var subscriberSenderDidUpdateResolutionCallsCount = 0
    public var subscriberSenderDidUpdateResolutionCalled: Bool {
        return subscriberSenderDidUpdateResolutionCallsCount > 0
    }
    public var subscriberSenderDidUpdateResolutionReceivedArguments: (sender: Subscriber, resolution: Resolution)?
    public var subscriberSenderDidUpdateResolutionReceivedInvocations: [(sender: Subscriber, resolution: Resolution)] = []
    public var subscriberSenderDidUpdateResolutionClosure: ((Subscriber, Resolution) -> Void)?

    public func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution) {
        subscriberSenderDidUpdateResolutionCallsCount += 1
        subscriberSenderDidUpdateResolutionReceivedArguments = (sender: sender, resolution: resolution)
        subscriberSenderDidUpdateResolutionReceivedInvocations.append((sender: sender, resolution: resolution))
        subscriberSenderDidUpdateResolutionClosure?(sender, resolution)
    }

    //MARK: - subscriber

    public var subscriberSenderDidUpdateDesiredIntervalCallsCount = 0
    public var subscriberSenderDidUpdateDesiredIntervalCalled: Bool {
        return subscriberSenderDidUpdateDesiredIntervalCallsCount > 0
    }
    public var subscriberSenderDidUpdateDesiredIntervalReceivedArguments: (sender: Subscriber, interval: Double)?
    public var subscriberSenderDidUpdateDesiredIntervalReceivedInvocations: [(sender: Subscriber, interval: Double)] = []
    public var subscriberSenderDidUpdateDesiredIntervalClosure: ((Subscriber, Double) -> Void)?

    public func subscriber(sender: Subscriber, didUpdateDesiredInterval interval: Double) {
        subscriberSenderDidUpdateDesiredIntervalCallsCount += 1
        subscriberSenderDidUpdateDesiredIntervalReceivedArguments = (sender: sender, interval: interval)
        subscriberSenderDidUpdateDesiredIntervalReceivedInvocations.append((sender: sender, interval: interval))
        subscriberSenderDidUpdateDesiredIntervalClosure?(sender, interval)
    }

    //MARK: - subscriber

    public var subscriberSenderDidChangeAssetConnectionStatusCallsCount = 0
    public var subscriberSenderDidChangeAssetConnectionStatusCalled: Bool {
        return subscriberSenderDidChangeAssetConnectionStatusCallsCount > 0
    }
    public var subscriberSenderDidChangeAssetConnectionStatusReceivedArguments: (sender: Subscriber, status: ConnectionState)?
    public var subscriberSenderDidChangeAssetConnectionStatusReceivedInvocations: [(sender: Subscriber, status: ConnectionState)] = []
    public var subscriberSenderDidChangeAssetConnectionStatusClosure: ((Subscriber, ConnectionState) -> Void)?

    public func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        subscriberSenderDidChangeAssetConnectionStatusCallsCount += 1
        subscriberSenderDidChangeAssetConnectionStatusReceivedArguments = (sender: sender, status: status)
        subscriberSenderDidChangeAssetConnectionStatusReceivedInvocations.append((sender: sender, status: status))
        subscriberSenderDidChangeAssetConnectionStatusClosure?(sender, status)
    }

    //MARK: - subscriber

    public var subscriberSenderDidUpdatePublisherPresenceCallsCount = 0
    public var subscriberSenderDidUpdatePublisherPresenceCalled: Bool {
        return subscriberSenderDidUpdatePublisherPresenceCallsCount > 0
    }
    public var subscriberSenderDidUpdatePublisherPresenceReceivedArguments: (sender: Subscriber, isPresent: Bool)?
    public var subscriberSenderDidUpdatePublisherPresenceReceivedInvocations: [(sender: Subscriber, isPresent: Bool)] = []
    public var subscriberSenderDidUpdatePublisherPresenceClosure: ((Subscriber, Bool) -> Void)?

    public func subscriber(sender: Subscriber, didUpdatePublisherPresence isPresent: Bool) {
        subscriberSenderDidUpdatePublisherPresenceCallsCount += 1
        subscriberSenderDidUpdatePublisherPresenceReceivedArguments = (sender: sender, isPresent: isPresent)
        subscriberSenderDidUpdatePublisherPresenceReceivedInvocations.append((sender: sender, isPresent: isPresent))
        subscriberSenderDidUpdatePublisherPresenceClosure?(sender, isPresent)
    }

}
