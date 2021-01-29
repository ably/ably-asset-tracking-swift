/**
  A request for a tracking `Resolution` for a `Trackable` object.
 */
public class TrackableResolutionRequest {
    /**
      The `Trackable` object that holds optional constraints.
     */
    public let trackable: Trackable

    /**
      Remote `Resolution` requests for the `Trackable` object.
      This set may be empty.
     */
    public let remoteRequests: Set<Resolution>

    /**
     Default constructor for the TrackableResolutionRequest
     */
    public init(trackable: Trackable, remoteRequests: Set<Resolution>) {
        self.trackable = trackable
        self.remoteRequests = remoteRequests
    }
}
