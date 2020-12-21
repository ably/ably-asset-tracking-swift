/**
 Governs how often to sample locations, at what level of positional accuracy, and how often to send them to
 subscribers.
 */
public class Resolution {
    /**
     The general priority for accuracy of location updates, used to govern any trade-off between power usage and
     positional accuracy.
     The highest positional accuracy will be achieved by specifying `Accuracy.maximum`, but at the expense of
     significantly increased power usage. Conversely, the lowest power usage will be achieved by specifying
     `Accuracy.minimum` but at the expense of significantly decreased positional accuracy.
     */
    let accuracy: Accuracy

    /**
     Desired time between updates, in milliseconds. Lowering this value increases the temporal resolution.
     Location updates whose timestamp differs from the last captured update timestamp by less that this value are to
     be filtered out.
     Used to govern the frequency of updates requested from the underlying location provider, as well as the frequency
     of messages broadcast to subscribers.
     */
    let desiredInterval: TimeInterval

    /**
     Minimum positional granularity required, in metres. Lowering this value increases the spatial resolution.

     Location updates whose position differs from the last known position by a distance smaller than this value are to
     be filtered out.

     Used to configure the underlying location provider, as well as to filter the broadcast of updates to subscribers.
     */
    let minimumDisplacement: Double

    /**
     Default constructor for the Resolution
     */
    public init(accuracy: Accuracy, desiredInterval: TimeInterval, minimumDisplacement: Double) {
        self.accuracy = accuracy
        self.desiredInterval = desiredInterval
        self.minimumDisplacement = minimumDisplacement
    }
}

extension Resolution: Hashable {
    public static func == (lhs: Resolution, rhs: Resolution) -> Bool {
        return lhs.accuracy == rhs.accuracy &&
            lhs.desiredInterval == rhs.desiredInterval &&
            lhs.minimumDisplacement == rhs.minimumDisplacement
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(accuracy)
        hasher.combine(desiredInterval)
        hasher.combine(minimumDisplacement)
    }
}
