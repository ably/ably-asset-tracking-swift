import Foundation

public class SubscriberWorkSpecification {
    public class Legacy: SubscriberWorkSpecification
    {
        let callback: () -> Void

        public init(callback: @escaping () -> Void) {
            self.callback = callback
        }
    }
}
