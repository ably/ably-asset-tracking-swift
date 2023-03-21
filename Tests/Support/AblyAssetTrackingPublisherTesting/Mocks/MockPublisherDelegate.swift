import CoreLocation
import Foundation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockPublisherDelegate: PublisherDelegate {
    public init() {}

    public var publisherDidFailWithErrorCalled: Bool = false
    public var publisherDidFailWithErrorParamSender: Publisher?
    public var publisherDidFailWithErrorParamError: ErrorInformation?
    public var publisherDidFailWithErrorCallback: (() -> Void)?
    public func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        publisherDidFailWithErrorCalled = true
        publisherDidFailWithErrorParamSender = sender
        publisherDidFailWithErrorParamError = error
        publisherDidFailWithErrorCallback?()
    }

    public var publisherDidUpdateEnhancedLocationCalled: Bool = false
    public var publisherDidUpdateEnhancedLocationParamSender: Publisher?
    public var publisherDidUpdateEnhancedLocationParamLocation: EnhancedLocationUpdate?
    public var publisherDidUpdateEnhancedLocationCallback: (() -> Void)?
    public func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {
        publisherDidUpdateEnhancedLocationCalled = true
        publisherDidUpdateEnhancedLocationParamSender = sender
        publisherDidUpdateEnhancedLocationParamLocation = location
        publisherDidUpdateEnhancedLocationCallback?()
    }

    public var publisherDidChangeTrackableConnectionStateCalled: Bool = false
    public var publisherDidChangeTrackableConnectionStateParamSender: Publisher?
    public var publisherDidChangeTrackableConnectionStateParamState: ConnectionState?
    public var publisherDidChangeTrackableConnectionStateParamTrackable: Trackable?
    public var publisherDidChangeTrackableConnectionStateCallback: (() -> Void)?
    public func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        publisherDidChangeTrackableConnectionStateCalled = true
        publisherDidChangeTrackableConnectionStateParamSender = sender
        publisherDidChangeTrackableConnectionStateParamState = state
        publisherDidChangeTrackableConnectionStateParamTrackable = trackable
        publisherDidChangeTrackableConnectionStateCallback?()
    }

    public var publisherDidUpdateResolutionCalled: Bool = false
    public var publisherDidUpdateResolutionParamSender: Publisher?
    public var publisherDidUpdateResolutionParamResolution: Resolution?
    public var publisherDidUpdateResolutionCallback: (() -> Void)?
    public func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        publisherDidUpdateResolutionCalled = true
        publisherDidUpdateResolutionParamSender = sender
        publisherDidUpdateResolutionParamResolution = resolution
        publisherDidUpdateResolutionCallback?()
    }

    public var publisherDidChangeTrackablesCalled: Bool = false
    public var publisherDidChangeTrackablesParamSender: Publisher?
    public var publisherDidChangeTrackablesParamTrackables: Set<Trackable>?
    public var publisherDidChangeTrackablesCallback: (() -> Void)?
    public func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>) {
        publisherDidChangeTrackablesCalled = true
        publisherDidChangeTrackablesParamSender = sender
        publisherDidChangeTrackablesParamTrackables = trackables
        publisherDidChangeTrackablesCallback?()
    }

    public var publisherDidFinishRecordingLocationHistoryDataCalled: Bool = false
    public var publisherDidFinishRecordingLocationHistoryDataParamSender: Publisher?
    public var publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData: LocationHistoryData?
    public var publisherDidFinishRecordingLocationHistoryDataCallback: (() -> Void)?
    public func publisher(sender: Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData) {
        publisherDidFinishRecordingLocationHistoryDataCalled = true
        publisherDidFinishRecordingLocationHistoryDataParamSender = sender
        publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData = locationHistoryData
        publisherDidFinishRecordingLocationHistoryDataCallback?()
    }

    public var publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled: Bool = false
    public var publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamSender: Publisher?
    public var publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamTemporaryFile: TemporaryFile?
    public var publisherDidFinishRecordingRawMapboxDataToTemporaryFileCallback: (() -> Void)?
    public func publisher(sender: Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile) {
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled = true
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamSender = sender
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamTemporaryFile = temporaryFile
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileCallback?()
    }
}
