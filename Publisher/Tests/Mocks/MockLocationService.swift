@testable import Core
@testable import Publisher

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
}
