import Foundation
import AblyAssetTrackingInternal

public class PublisherWorkSpecification {
    public class Legacy: PublisherWorkSpecification
    {
        let callback: () -> Void
        let logger: InternalLogHandler?
        
        public init(callback: @escaping () -> Void, logger: InternalLogHandler?) {
            self.callback = callback
            self.logger = logger
        }
    }
}

