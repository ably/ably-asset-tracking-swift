import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class MockTrackableSetListener: TrackableSetListener {
    var onTrackableAddedCalled: Bool = false
    var onTrackableAddedParamTrackable: Trackable?
    func onTrackableAdded(trackable: Trackable) {
        onTrackableAddedCalled = true
        onTrackableAddedParamTrackable = trackable
    }

    var onTrackableRemovedCalled: Bool = false
    var onTrackableRemovedParamTrackable: Trackable?
    func onTrackableRemoved(trackable: Trackable) {
        onTrackableRemovedCalled = true
        onTrackableRemovedParamTrackable = trackable
    }

    var onActiveTrackableChangedCalled: Bool = false
    var onActiveTrackableChangedParamTrackable: Trackable?
    func onActiveTrackableChanged(trackable: Trackable?) {
        onActiveTrackableChangedCalled = true
        onActiveTrackableChangedParamTrackable = trackable
    }
}
