import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockTrackableSetListener: TrackableSetListener {
    public init() {}

    public var onTrackableAddedCalled = false
    public var onTrackableAddedParamTrackable: Trackable?
    public func onTrackableAdded(trackable: Trackable) {
        onTrackableAddedCalled = true
        onTrackableAddedParamTrackable = trackable
    }

    public var onTrackableRemovedCalled = false
    public var onTrackableRemovedParamTrackable: Trackable?
    public func onTrackableRemoved(trackable: Trackable) {
        onTrackableRemovedCalled = true
        onTrackableRemovedParamTrackable = trackable
    }

    public var onActiveTrackableChangedCalled = false
    public var onActiveTrackableChangedParamTrackable: Trackable?
    public func onActiveTrackableChanged(trackable: Trackable?) {
        onActiveTrackableChangedCalled = true
        onActiveTrackableChangedParamTrackable = trackable
    }
}
