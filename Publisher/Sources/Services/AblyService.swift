import UIKit
import Ably

public class AblyService {
    private let client: ARTRealtime
    
    init(apiKey: String) {
        self.client = ARTRealtime(key: apiKey)
    }
}
