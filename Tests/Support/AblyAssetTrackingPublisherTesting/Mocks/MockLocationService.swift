import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher
import Foundation

public class MockLocationService: LocationService {
    public init() {}

    public var changeLocationEngineResolutionCalled: Bool = false
    public var changeLocationEngineResolutionParamResolution: Resolution?
    public func changeLocationEngineResolution(resolution: Resolution) {
        changeLocationEngineResolutionCalled = true
        changeLocationEngineResolutionParamResolution = resolution
    }

    public var wasDelegateSet: Bool = false
    public var delegate: LocationServiceDelegate? {
        didSet { wasDelegateSet = true }
    }

    public var startUpdatingLocationCalled: Bool = false
    public func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }

    public var stopUpdatingLocationCalled: Bool = false
    public func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }

    public var startRecordingLocationCalled = false
    public func startRecordingLocation() {
        startRecordingLocationCalled = true
    }

    public var stopRecordingLocationCalled = false
    public var stopRecordingLocationParamCompletion: ResultHandler<LocationRecordingResult?>?
    public var stopRecordingLocationCallback: ((@escaping ResultHandler<LocationRecordingResult?>) -> Void)?
    public func stopRecordingLocation(completion: @escaping ResultHandler<LocationRecordingResult?>) {
        stopRecordingLocationCalled = true
        stopRecordingLocationParamCompletion = completion
        stopRecordingLocationCallback?(completion)
    }
}
