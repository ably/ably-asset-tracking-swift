import AblyAssetTrackingCore
import Foundation

/**
  Defines the strategy by which the various `ResolutionRequest`s and preferences are translated by `Publisher`
  instances into a target `Resolution`.
 */
public protocol ResolutionPolicy {
    /**
      Determine a target `Resolution` for a `Trackable` object.

      The intention is for the resulting  `Resolution` to impact networking per `Trackable`.
     */
    func resolve(request: TrackableResolutionRequest) -> Resolution

    /**
      Determine a target `Resolution` from a set of resolutions.
      This set may be empty.
      The intention use for this method is to be applied to Resolutions returned by first overload
      of `resolve` and to determine out of different resolutions per `Trackable` which `Resolution`
      should be used for setting the location engine updates frequency.
     */
    func resolve(resolutions: Set<Resolution>) -> Resolution
}
