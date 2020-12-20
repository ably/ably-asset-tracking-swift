/**
 * A request for a tracking [Resolution] for a [Trackable] object.
 */
public class TrackableResolutionRequest {
    /**
     * The [Trackable] object that holds optional constraints.
     */
    let trackable: Trackable

    /**
     * Remote [Resolution] requests for the [Trackable] object.
     *
     * This set may be empty.
     */
    let remoteRequests: Set<Resolution>

    /**
     Default constructor for the TrackableResolutionRequest
     */
    public init(trackable: Trackable, remoteRequests: Set<Resolution>) {
        self.trackable = trackable
        self.remoteRequests = remoteRequests
    }
}
