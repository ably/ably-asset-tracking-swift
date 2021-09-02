//
//  Created by Łukasz Szyszkowski on 01/09/2021.
//

import Foundation

public enum ChannelName: String {
    /**
     * This is a metachannel, which will be defined across the Ably infrastructure.
     *
     * **Note**: Simply using `tracking` as the namespace prefix wouldn't be enough as,
     * in the wider Ably context, `tracking` can mean many things. Whereas,
     * `asset-tracking` specifies a product.
     */
    case metaDataTrip = "[meta]asset-tracking:trip-lifecycle"
}
