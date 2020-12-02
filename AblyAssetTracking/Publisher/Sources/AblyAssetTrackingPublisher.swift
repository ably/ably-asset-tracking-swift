import UIKit
import Core


public class AblyAssetTrackingPublisher {
    public init(configuration: AblyConfiguration) {}
        
    func testCoreDependency() {
        // Temporary function to test if we can use Core classes here
        let _ = AblyClient()
    }
}
