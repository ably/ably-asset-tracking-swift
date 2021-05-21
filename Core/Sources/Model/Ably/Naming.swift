/**
 Returns a fully qualified channel name ready to be used with the core Ably library.
 
 - Warning: This API should not be relied upon by app developers and is subject to change without notice.
 */
public func ablyChannelNameFromTrackableId(_ trackableId: String) -> String {
    "tracking:\(trackableId)"
}
