import Foundation

public class DefaultSubscriber: AssetTrackingSubscriber {
    private let configuration: AssetTrackingSubscriberConfiguration
    public var delegate: AssetTrackingSubscriberDelegate?
    
    /**
     Default constructor. Initializes Subscriber with given `AssetTrackingSubscriberConfiguration`.
     Subscriber starts listening (and notifying delegate) after initialization.
     - Parameters:
     -  configuration: Configuration struct to use in this instance.
     */
    public init(configuration: AssetTrackingSubscriberConfiguration) {
        self.configuration = configuration
    }
    
    public func stop() {
        
    }
}
