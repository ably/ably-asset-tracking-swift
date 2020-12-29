import Foundation
@testable import Publisher

class MockLocationService: LocationService {
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
