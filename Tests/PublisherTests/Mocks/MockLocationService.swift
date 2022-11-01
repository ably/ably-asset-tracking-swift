import Foundation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class MockLocationService: LocationService {
    var changeLocationEngineResolutionCalled: Bool = false
    var changeLocationEngineResolutionParamResolution: Resolution?
    func changeLocationEngineResolution(resolution: Resolution) {
        changeLocationEngineResolutionCalled = true
        changeLocationEngineResolutionParamResolution = resolution
    }

    var wasDelegateSet: Bool = false
    var delegate: LocationServiceDelegate? {
        didSet { wasDelegateSet = true }
    }

    var startUpdatingLocationCalled: Bool = false
    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }

    var stopUpdatingLocationCalled: Bool = false
    func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }
    
    var startRecordingLocationCalled = false
    func startRecordingLocation() {
        startRecordingLocationCalled = true
    }
    
    var stopRecordingLocationCalled = false
    var stopRecordingLocationParamCompletion: ResultHandler<LocationHistoryData?>?
    var stopRecordingLocationCallback: ((@escaping ResultHandler<LocationHistoryData?>) -> Void)?
    func stopRecordingLocation(completion: @escaping ResultHandler<LocationHistoryData?>) {
        stopRecordingLocationCalled = true
        stopRecordingLocationParamCompletion = completion
        stopRecordingLocationCallback?(completion)
    }
}
