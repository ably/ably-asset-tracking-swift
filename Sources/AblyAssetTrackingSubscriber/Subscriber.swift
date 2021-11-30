import UIKit
import Foundation
import AblyAssetTrackingCore

/**
 Main `Subscriber` interface implemented in SDK by `DefaultSubscriber`
 */
@objc
public protocol Subscriber {
    /**
     Delegate object to receive events from `Subscriber`.
     It maintains a weak reference to your delegate, so ensure to maintain your own strong reference as well.
     */
    var delegate: SubscriberDelegate? { get set }

    /**
     Sends the desired resolution for updates, to be requested from the remote publisher.
     An initial resolution may be defined from the outset of a `Subscriber`'s lifespan by using the `resolution` `Builder.resolution` method on the `Builder` instance used to `start` `Builder.start` it.
     Requests sent using this method will take time to propagate back to the publisher.
     The `onSuccess` callback will be called once the request has been successfully registered with the server,
     however this does not necessarily mean that the request has been received and actioned by the publisher.

     - Parameters:
        - resolution: The resolution to request, or `null` to indicate that this subscriber should explicitly indicate that it has no preference in respect of resolution.
        - completion: Called on completion of the `sendChangeRequest` method. Ends with:
            - `success` if the request was successfully registered with the server.
            - `failure` if the request could not be sent or it was not possible to confirm that the server had processed the request.
     */
    func resolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler/*Void*/)

    /**
     Stops asset subscriber from listening for asset location
     */
    func stop(completion: @escaping ResultHandler/*Void*/)
}
