import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher
import CoreLocation
import Foundation

public class MockPublisherDelegate: PublisherDelegate {
    public init() {}

    public var publisherDidFailWithErrorCalled = false
    public var publisherDidFailWithErrorParamSender: Publisher?
    public var publisherDidFailWithErrorParamError: ErrorInformation?
    public var publisherDidFailWithErrorCallback: (() -> Void)?
    public func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        publisherDidFailWithErrorCalled = true
        publisherDidFailWithErrorParamSender = sender
        publisherDidFailWithErrorParamError = error
        publisherDidFailWithErrorCallback?()
    }

    public var publisherDidUpdateEnhancedLocationCalled = false
    public var publisherDidUpdateEnhancedLocationParamSender: Publisher?
    public var publisherDidUpdateEnhancedLocationParamLocation: EnhancedLocationUpdate?
    public var publisherDidUpdateEnhancedLocationCallback: (() -> Void)?
    public func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {
        publisherDidUpdateEnhancedLocationCalled = true
        publisherDidUpdateEnhancedLocationParamSender = sender
        publisherDidUpdateEnhancedLocationParamLocation = location
        publisherDidUpdateEnhancedLocationCallback?()
    }

    public var publisherDidChangeTrackableStateCalled = false
    public var publisherDidChangeTrackableStateParamSender: Publisher?
    public var publisherDidChangeTrackableStateParamState: TrackableState?
    public var publisherDidChangeTrackableStateParamTrackable: Trackable?
    public var publisherDidChangeTrackableStateCallback: (() -> Void)?
    public func publisher(sender: Publisher, didChangeState state: TrackableState, forTrackable trackable: Trackable) {
        publisherDidChangeTrackableStateCalled = true
        publisherDidChangeTrackableStateParamSender = sender
        publisherDidChangeTrackableStateParamState = state
        publisherDidChangeTrackableStateParamTrackable = trackable
        publisherDidChangeTrackableStateCallback?()
    }

    public var publisherDidUpdateResolutionCalled = false
    public var publisherDidUpdateResolutionParamSender: Publisher?
    public var publisherDidUpdateResolutionParamResolution: Resolution?
    public var publisherDidUpdateResolutionCallback: (() -> Void)?
    public func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        publisherDidUpdateResolutionCalled = true
        publisherDidUpdateResolutionParamSender = sender
        publisherDidUpdateResolutionParamResolution = resolution
        publisherDidUpdateResolutionCallback?()
    }

    public var publisherDidChangeTrackablesCalled = false
    public var publisherDidChangeTrackablesParamSender: Publisher?
    public var publisherDidChangeTrackablesParamTrackables: Set<Trackable>?
    public var publisherDidChangeTrackablesCallback: (() -> Void)?
    public func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>) {
        publisherDidChangeTrackablesCalled = true
        publisherDidChangeTrackablesParamSender = sender
        publisherDidChangeTrackablesParamTrackables = trackables
        publisherDidChangeTrackablesCallback?()
    }

    public var publisherDidFinishRecordingLocationHistoryDataCalled = false
    public var publisherDidFinishRecordingLocationHistoryDataParamSender: Publisher?
    public var publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData: LocationHistoryData?
    public var publisherDidFinishRecordingLocationHistoryDataCallback: (() -> Void)?
    public func publisher(sender: Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData) {
        publisherDidFinishRecordingLocationHistoryDataCalled = true
        publisherDidFinishRecordingLocationHistoryDataParamSender = sender
        publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData = locationHistoryData
        publisherDidFinishRecordingLocationHistoryDataCallback?()
    }

    public var publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled = false
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
