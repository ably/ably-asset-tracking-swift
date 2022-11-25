import CoreLocation
import Foundation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class MockPublisherDelegate: PublisherDelegate {
    var publisherDidFailWithErrorCalled: Bool = false
    var publisherDidFailWithErrorParamSender: Publisher?
    var publisherDidFailWithErrorParamError: ErrorInformation?
    var publisherDidFailWithErrorCallback: (() -> Void)?
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        publisherDidFailWithErrorCalled = true
        publisherDidFailWithErrorParamSender = sender
        publisherDidFailWithErrorParamError = error
        publisherDidFailWithErrorCallback?()
    }

    var publisherDidUpdateEnhancedLocationCalled: Bool = false
    var publisherDidUpdateEnhancedLocationParamSender: Publisher?
    var publisherDidUpdateEnhancedLocationParamLocation: EnhancedLocationUpdate?
    var publisherDidUpdateEnhancedLocationCallback: (() -> Void)?
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {
        publisherDidUpdateEnhancedLocationCalled = true
        publisherDidUpdateEnhancedLocationParamSender = sender
        publisherDidUpdateEnhancedLocationParamLocation = location
        publisherDidUpdateEnhancedLocationCallback?()
    }

    var publisherDidChangeTrackableConnectionStateCalled: Bool = false
    var publisherDidChangeTrackableConnectionStateParamSender: Publisher?
    var publisherDidChangeTrackableConnectionStateParamState: ConnectionState?
    var publisherDidChangeTrackableConnectionStateParamTrackable: Trackable?
    var publisherDidChangeTrackableConnectionStateCallback: (() -> Void)?
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        publisherDidChangeTrackableConnectionStateCalled = true
        publisherDidChangeTrackableConnectionStateParamSender = sender
        publisherDidChangeTrackableConnectionStateParamState = state
        publisherDidChangeTrackableConnectionStateParamTrackable = trackable
        publisherDidChangeTrackableConnectionStateCallback?()
    }
    
    var publisherDidUpdateResolutionCalled: Bool = false
    var publisherDidUpdateResolutionParamSender: Publisher?
    var publisherDidUpdateResolutionParamResolution: Resolution?
    var publisherDidUpdateResolutionCallback: (() -> Void)?
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        publisherDidUpdateResolutionCalled = true
        publisherDidUpdateResolutionParamSender = sender
        publisherDidUpdateResolutionParamResolution = resolution
        publisherDidUpdateResolutionCallback?()
    }
    
    var publisherDidChangeTrackablesCalled: Bool = false
    var publisherDidChangeTrackablesParamSender: Publisher?
    var publisherDidChangeTrackablesParamTrackables: Set<Trackable>?
    var publisherDidChangeTrackablesCallback: (() -> Void)?
    func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>) {
        publisherDidChangeTrackablesCalled = true
        publisherDidChangeTrackablesParamSender = sender
        publisherDidChangeTrackablesParamTrackables = trackables
        publisherDidChangeTrackablesCallback?()
    }
    
    var publisherDidFinishRecordingLocationHistoryDataCalled: Bool = false
    var publisherDidFinishRecordingLocationHistoryDataParamSender: Publisher?
    var publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData: LocationHistoryData?
    var publisherDidFinishRecordingLocationHistoryDataCallback: (() -> Void)?
    func publisher(sender: Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData) {
        publisherDidFinishRecordingLocationHistoryDataCalled = true
        publisherDidFinishRecordingLocationHistoryDataParamSender = sender
        publisherDidFinishRecordingLocationHistoryDataParamLocationHistoryData = locationHistoryData
        publisherDidFinishRecordingLocationHistoryDataCallback?()
    }
    
    var publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled: Bool = false
    var publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamSender: Publisher?
    var publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamTemporaryFile: TemporaryFile?
    var publisherDidFinishRecordingRawMapboxDataToTemporaryFileCallback: (() -> Void)?
    func publisher(sender: Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile) {
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled = true
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamSender = sender
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileParamTemporaryFile = temporaryFile
        publisherDidFinishRecordingRawMapboxDataToTemporaryFileCallback?()
    }
}
