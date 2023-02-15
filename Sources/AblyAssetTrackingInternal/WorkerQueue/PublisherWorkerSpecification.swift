import Foundation

public class PublisherWorkSpecification {
    public class Legacy: PublisherWorkSpecification
    {
        let callback: () -> Void
        
        public init(callback: @escaping () -> Void) {
            self.callback = callback
        }
    }
}

