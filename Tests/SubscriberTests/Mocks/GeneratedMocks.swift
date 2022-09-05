// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
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















class SubscriberDelegateMock: SubscriberDelegate {

    //MARK: - subscriber

    var subscriberSenderDidFailWithErrorCallsCount = 0
    var subscriberSenderDidFailWithErrorCalled: Bool {
        return subscriberSenderDidFailWithErrorCallsCount > 0
    }
    var subscriberSenderDidFailWithErrorReceivedArguments: (sender: Subscriber, error: ErrorInformation)?
    var subscriberSenderDidFailWithErrorReceivedInvocations: [(sender: Subscriber, error: ErrorInformation)] = []
    var subscriberSenderDidFailWithErrorClosure: ((Subscriber, ErrorInformation) -> Void)?

    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
        subscriberSenderDidFailWithErrorCallsCount += 1
        subscriberSenderDidFailWithErrorReceivedArguments = (sender: sender, error: error)
        subscriberSenderDidFailWithErrorReceivedInvocations.append((sender: sender, error: error))
        subscriberSenderDidFailWithErrorClosure?(sender, error)
    }

    //MARK: - subscriber

    var subscriberSenderDidUpdateEnhancedLocationCallsCount = 0
    var subscriberSenderDidUpdateEnhancedLocationCalled: Bool {
        return subscriberSenderDidUpdateEnhancedLocationCallsCount > 0
    }
    var subscriberSenderDidUpdateEnhancedLocationReceivedArguments: (sender: Subscriber, locationUpdate: LocationUpdate)?
    var subscriberSenderDidUpdateEnhancedLocationReceivedInvocations: [(sender: Subscriber, locationUpdate: LocationUpdate)] = []
    var subscriberSenderDidUpdateEnhancedLocationClosure: ((Subscriber, LocationUpdate) -> Void)?

    func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        subscriberSenderDidUpdateEnhancedLocationCallsCount += 1
        subscriberSenderDidUpdateEnhancedLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        subscriberSenderDidUpdateEnhancedLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        subscriberSenderDidUpdateEnhancedLocationClosure?(sender, locationUpdate)
    }

    //MARK: - subscriber

    var subscriberSenderDidUpdateRawLocationCallsCount = 0
    var subscriberSenderDidUpdateRawLocationCalled: Bool {
        return subscriberSenderDidUpdateRawLocationCallsCount > 0
    }
    var subscriberSenderDidUpdateRawLocationReceivedArguments: (sender: Subscriber, locationUpdate: LocationUpdate)?
    var subscriberSenderDidUpdateRawLocationReceivedInvocations: [(sender: Subscriber, locationUpdate: LocationUpdate)] = []
    var subscriberSenderDidUpdateRawLocationClosure: ((Subscriber, LocationUpdate) -> Void)?

    func subscriber(sender: Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate) {
        subscriberSenderDidUpdateRawLocationCallsCount += 1
        subscriberSenderDidUpdateRawLocationReceivedArguments = (sender: sender, locationUpdate: locationUpdate)
        subscriberSenderDidUpdateRawLocationReceivedInvocations.append((sender: sender, locationUpdate: locationUpdate))
        subscriberSenderDidUpdateRawLocationClosure?(sender, locationUpdate)
    }

    //MARK: - subscriber

    var subscriberSenderDidUpdateResolutionCallsCount = 0
    var subscriberSenderDidUpdateResolutionCalled: Bool {
        return subscriberSenderDidUpdateResolutionCallsCount > 0
    }
    var subscriberSenderDidUpdateResolutionReceivedArguments: (sender: Subscriber, resolution: Resolution)?
    var subscriberSenderDidUpdateResolutionReceivedInvocations: [(sender: Subscriber, resolution: Resolution)] = []
    var subscriberSenderDidUpdateResolutionClosure: ((Subscriber, Resolution) -> Void)?

    func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution) {
        subscriberSenderDidUpdateResolutionCallsCount += 1
        subscriberSenderDidUpdateResolutionReceivedArguments = (sender: sender, resolution: resolution)
        subscriberSenderDidUpdateResolutionReceivedInvocations.append((sender: sender, resolution: resolution))
        subscriberSenderDidUpdateResolutionClosure?(sender, resolution)
    }

    //MARK: - subscriber

    var subscriberSenderDidUpdateDesiredIntervalCallsCount = 0
    var subscriberSenderDidUpdateDesiredIntervalCalled: Bool {
        return subscriberSenderDidUpdateDesiredIntervalCallsCount > 0
    }
    var subscriberSenderDidUpdateDesiredIntervalReceivedArguments: (sender: Subscriber, interval: Double)?
    var subscriberSenderDidUpdateDesiredIntervalReceivedInvocations: [(sender: Subscriber, interval: Double)] = []
    var subscriberSenderDidUpdateDesiredIntervalClosure: ((Subscriber, Double) -> Void)?

    func subscriber(sender: Subscriber, didUpdateDesiredInterval interval: Double) {
        subscriberSenderDidUpdateDesiredIntervalCallsCount += 1
        subscriberSenderDidUpdateDesiredIntervalReceivedArguments = (sender: sender, interval: interval)
        subscriberSenderDidUpdateDesiredIntervalReceivedInvocations.append((sender: sender, interval: interval))
        subscriberSenderDidUpdateDesiredIntervalClosure?(sender, interval)
    }

    //MARK: - subscriber

    var subscriberSenderDidChangeAssetConnectionStatusCallsCount = 0
    var subscriberSenderDidChangeAssetConnectionStatusCalled: Bool {
        return subscriberSenderDidChangeAssetConnectionStatusCallsCount > 0
    }
    var subscriberSenderDidChangeAssetConnectionStatusReceivedArguments: (sender: Subscriber, status: ConnectionState)?
    var subscriberSenderDidChangeAssetConnectionStatusReceivedInvocations: [(sender: Subscriber, status: ConnectionState)] = []
    var subscriberSenderDidChangeAssetConnectionStatusClosure: ((Subscriber, ConnectionState) -> Void)?

    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        subscriberSenderDidChangeAssetConnectionStatusCallsCount += 1
        subscriberSenderDidChangeAssetConnectionStatusReceivedArguments = (sender: sender, status: status)
        subscriberSenderDidChangeAssetConnectionStatusReceivedInvocations.append((sender: sender, status: status))
        subscriberSenderDidChangeAssetConnectionStatusClosure?(sender, status)
    }

}
