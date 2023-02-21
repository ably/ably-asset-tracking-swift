import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

/// A protocol that the publisher implements which allows
/// other internal classes (such as workers) to interact with it.
/// These methods will be implemented on the publisher as the workers require it.
protocol PublisherInteractor
{
//    func startLocationUpdates(properties: PublisherProperties)
//    func updateTrackables(properties: PublisherProperties)
//    func resolveResolution(trackable: Trackable, properties: PublisherProperties)
//    func updateTrackableStateFlows(properties: PublisherProperties)
//    func updateTrackableState(properties: PublisherProperties, trackableId: String)
//    func setFinalTrackableState(properties: PublisherProperties, trackableId: String, finalState: ConnectionState)
//    func notifyResolutionPolicyThatTrackableWasRemoved(trackable: Trackable)
//    func removeCurrentDestination(properties: PublisherProperties)
//    func notifyResolutionPolicyThatActiveTrackableHasChanged(trackable: Trackable?)
//    func stopLocationUpdates(properties: PublisherProperties)
//    func removeAllSubscribers(trackable: Trackable, properties: PublisherProperties)
//    func setDestination(destination: LocationCoordinate, properties: PublisherProperties)
//    func processEnhancedLocationUpdate(
//        enhancedLocationUpdate: EnhancedLocationUpdate,
//        properties: PublisherProperties,
//        trackableId: String
//    )
//    func updateLocations(locationUpdate: LocationUpdate)
//    func checkThreshold(
//        currentLocation: Location,
//        activeTrackable: Trackable?,
//        estimatedArrivalTimeInMilliseconds: Int64
//    )
//    func addSubscriber(memberKey: String, trackable: Trackable, data: PresenceData, properties: PublisherProperties)
//    func removeSubscriber(memberKey: String, trackable: Trackable, properties: PublisherProperties)
//    func updateSubscriber(memberKey: String, trackable: Trackable, data: PresenceData, properties: PublisherProperties)
//    func processRawLocationUpdate(
//        rawLocationUpdate: LocationUpdate,
//        properties: PublisherProperties,
//        trackableId: String
//    )
//
//    func retrySendingEnhancedLocation(
//        properties: PublisherProperties,
//        trackableId: String,
//        locationUpdate: EnhancedLocationUpdate
//    )
//
//    func saveEnhancedLocationForFurtherSending(properties: PublisherProperties, trackableId: String, location: Location)
//    func processNextWaitingEnhancedLocationUpdate(properties: PublisherProperties, trackableId: String)
//    func retrySendingRawLocation(properties: PublisherProperties, trackableId: String, locationUpdate: LocationUpdate)
//    func saveRawLocationForFurtherSending(properties: PublisherProperties, trackableId: String, location: Location)
//    func processNextWaitingRawLocationUpdate(properties: PublisherProperties, trackableId: String)
//    func closeMapbox()
}
