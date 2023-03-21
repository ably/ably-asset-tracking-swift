import CoreLocation
import AblyAssetTrackingCore

class ThresholdChecker {
    func isThresholdReached(
        threshold: Proximity,
        currentLocation: Location,
        currentTime: TimeInterval,
        destination: Location?,
        estimatedArrivalTime: TimeInterval?
    ) -> Bool {
        guard let threshold = threshold as? DefaultProximity
        else { return false }
        return isSpatialProximityReached(threshold: threshold, currentLocation: currentLocation, destination: destination) ||
               isTemporalProximityReached(threshold: threshold, currentTime: currentTime, estimatedArrivalTime: estimatedArrivalTime)
    }

    private func isSpatialProximityReached(threshold: DefaultProximity,
                                           currentLocation: Location,
                                           destination: Location?) -> Bool {
        guard let spatial = threshold.spatial,
              let destination
        else { return false }
        return currentLocation.distance(from: destination) < spatial
    }

    private func isTemporalProximityReached(threshold: DefaultProximity,
                                            currentTime: TimeInterval,
                                            estimatedArrivalTime: TimeInterval?) -> Bool {
        guard let temporal = threshold.temporal,
              let estimatedArrivalTime
        else { return false }
        return estimatedArrivalTime - currentTime < temporal
    }
}
