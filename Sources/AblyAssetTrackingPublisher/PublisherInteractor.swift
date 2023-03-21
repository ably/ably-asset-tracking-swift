import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

/// A protocol that the publisher implements which allows
/// other internal classes (such as workers) to interact with it.
/// These methods will be implemented on the publisher as the workers require it.
protocol PublisherInteractor {
    /// Given publisher properties, set the publisher as tracking, register the location
    /// observer with mapbox and start the mapbox trip.
    // func startLocationUpdates(properties: PublisherWorkerQueueProperties)

    /// Given publisher properties, update the list of trackables that the publisher exposes
    /// to consumers.
    // func updateTrackables(properties: PublisherWorkerQueueProperties)

    /// Given a trackable and publisher properties (which contains resolution requests), use the resolution
    /// policy to resolve a resolution and set this on the publisher.
    // func resolveResolution(trackable: Trackable, properties: PublisherWorkerQueueProperties)

    /// Given publisher properties, update the list of currently known trackable states that the publisher exposes.
    /// This is usually to include new or removed trackables.
    // func updateTrackableStateFlows(properties: PublisherWorkerQueueProperties)

    /// Given publisher properties and a trackable id, update the current state of the given trackable.
    // func updateTrackableState(properties: PublisherWorkerQueueProperties, trackableId: String)

    /// Given publisher properties, a trackable id and state, give the trackable the given state as a "final" state,
    /// unless one has already been set.
    // func setFinalTrackableState(properties: PublisherWorkerQueueProperties, trackableId: String, finalState: ConnectionState)

    /// Given a trackable, use the resolution policies hooks to let the policy know that a trackable was removed
    // func notifyResolutionPolicyThatTrackableWasRemoved(trackable: Trackable)

    /// Given publisher properties, remove the current destination, estimated time to arrival and clear
    /// the current route in mapbox.
    // func removeCurrentDestination(properties: PublisherWorkerQueueProperties)

    /// Use the resolution policies hooks to let the policy know that the active trackable was changed
    // func notifyResolutionPolicyThatActiveTrackableHasChanged(trackable: Trackable?)

    /// Given publisher properties, mark the publisher as not tracking, unregister the mapbox location observer and
    /// stop the mapbox trip.
    // func stopLocationUpdates(properties: PublisherWorkerQueueProperties)

    /// Given a trackable and publisher properties, notify each subscriber that is being removed (via hooks) and
    /// remove all the subscribers for that trackable.
    // func removeAllSubscribers(trackable: Trackable, properties: PublisherWorkerQueueProperties)

    /// Given a location and publisher properties, set the current destination and mapbox route.
    // func setDestination(destination: LocationCoordinate, properties: PublisherWorkerQueueProperties)

    /// Given an enhanced location update, publisher properties and a trackable id, process the location by either
    /// sending it over the ably channel, or storing it for later.
    // func processEnhancedLocationUpdate(
    //     enhancedLocationUpdate: EnhancedLocationUpdate,
    //     properties: PublisherWorkerQueueProperties,
    //     trackableId: String
    // )

    /// Given a location update, emit the location to any consumers of the publishers
    /// list of locations. This is called when an enhanced location update is received from
    /// mapbox.
    // func updateLocations(locationUpdate: LocationUpdate)

    /// Given a curret location, trackable and estimated arrival time, check if the threshold has
    /// been reached for the current destination and if it has, let any handlers know that this is
    /// the case.
    // func checkThreshold(
    //     currentLocation: Location,
    //     activeTrackable: Trackable?,
    //     estimatedArrivalTimeInMilliseconds: Int64
    // )

    /// Given a presence member key, trackable, presence data and publisher properties register on the publisher that a subsriber has entered presence.
    /// Also notify any observers via hooks, add requested resolution and re-resolve the resolution being used.
    // func addSubscriber(memberKey: String, trackable: Trackable, data: PresenceData, properties: PublisherWorkerQueueProperties)

    /// Given a presence member key, trackable and publisher properties, remove the subsriber from the publisher subscriber list,
    /// remove any resolution requests, notify any observers via hooks, and resolve a new resolution via the policy.
    // func removeSubscriber(memberKey: String, trackable: Trackable, properties: PublisherWorkerQueueProperties)

    /// Given a presence member key, trackable and publisher properties, update or remove any resolution requests
    /// dnd resolve a new resolution via the policy.
    // func updateSubscriber(memberKey: String, trackable: Trackable, data: PresenceData, properties: PublisherWorkerQueueProperties)

    /// Given a raw location update, publisher properties and a trackable id, process the location by either
    /// sending it over the ably channel, or storing it for later.
    // func processRawLocationUpdate(
    //     rawLocationUpdate: LocationUpdate,
    //     properties: PublisherWorkerQueueProperties,
    //     trackableId: String
    // )
    
    /// Given publisher properties, a trackable id and an enhanced location update, increment
    /// the retry count for this location update and try to send it again.
    // func retrySendingEnhancedLocation(
    //     properties: PublisherWorkerQueueProperties,
    //     trackableId: String,
    //     locationUpdate: EnhancedLocationUpdate
    // )

    /// Given publisher properties, a trackable id and an enhanced location update, add the location update
    /// to the skipped locations for sending with a future update.
    // func saveEnhancedLocationForFurtherSending(properties: PublisherWorkerQueueProperties, trackableId: String, location: Location)

    /// Given publisher properties and a trackable id, check for any waiting enhanced location updates and, if present,
    /// send them.
    // func processNextWaitingEnhancedLocationUpdate(properties: PublisherWorkerQueueProperties, trackableId: String)

    /// Given publisher properties, a trackable id and a raw location update, increment
    /// the retry count for this location update and try to send it again.
    // func retrySendingRawLocation(properties: PublisherWorkerQueueProperties, trackableId: String, locationUpdate: LocationUpdate)

    /// Given publisher properties, a trackable id and a raw location update, add the location update
    /// to the skipped locations for sending with a future update.
    // func saveRawLocationForFurtherSending(properties: PublisherWorkerQueueProperties, trackableId: String, location: Location)

    /// Given publisher properties and a trackable id, check for any waiting raw location updates and, if present,
    /// send them.
    // func processNextWaitingRawLocationUpdate(properties: PublisherWorkerQueueProperties, trackableId: String)

    /// Close down the mapbox instance.
    // func closeMapbox()
}
