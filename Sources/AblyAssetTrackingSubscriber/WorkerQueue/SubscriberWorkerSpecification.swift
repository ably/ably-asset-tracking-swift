import Foundation
import AblyAssetTrackingInternal

public class SubscriberWorkSpecification {
    public class Legacy: SubscriberWorkSpecification
    {
        let callback: () -> Void
        let logger: InternalLogHandler?

        public init(callback: @escaping () -> Void, logger: InternalLogHandler?) {
            self.callback = callback
            self.logger = logger
        }
    }
}
