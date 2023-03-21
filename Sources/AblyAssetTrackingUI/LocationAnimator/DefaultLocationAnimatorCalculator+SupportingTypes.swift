import AblyAssetTrackingCore
import QuartzCore

extension DefaultLocationAnimatorCalculator {
    /// Contains the data needed to calculate the events that should be emitted to subscribers of an asset’s map position in the current animation frame. Should be constructed inside a `CADisplayLink` callback invocation.
    struct Input {
        /// A moment in time, as described by the return value of `CACurrentMediaTime`.
        typealias MediaTime = CFTimeInterval

        /// Contains user-specified parameters for configuring the speed of the animation of an asset’s position on a map, and the frequency at which the map is re-centred on the asset’s position.
        struct Config {
            /// The number of locations in the input’s `locationsAwaitingAnimation` that the animation must transition between before another camera update will be emitted. Must be non-negative.
            var locationTransitionsBetweenCameraUpdates: Int {
                willSet {
                    precondition(newValue >= 0)
                }
            }

            /// An additional duration to be added to the animation duration, on top of the duration given by the input’s `nextLocationUpdatePrediction`. Must be non-negative.
            var intentionalAnimationDelay: TimeInterval {
                willSet {
                    precondition(newValue >= 0)
                }
            }

            init(locationTransitionsBetweenCameraUpdates: Int, intentionalAnimationDelay: TimeInterval) {
                precondition(locationTransitionsBetweenCameraUpdates >= 0)
                precondition(intentionalAnimationDelay >= 0)

                self.locationTransitionsBetweenCameraUpdates = locationTransitionsBetweenCameraUpdates
                self.intentionalAnimationDelay = intentionalAnimationDelay
            }
        }

        /// Contains information about the state of the world at the start of the current `CADisplayLink` callback invocation.
        struct Context {
            /// A prediction about when we will receive updated information about the asset’s current location. It’s used to determine the duration over which we will animate through the locations currently given by the input’s `locationsAwaitingAnimation`.
            struct NextLocationUpdatePrediction {
                /// The value returned by `CACurrentMediaTime` at the moment when this prediction about the next location update was received.
                var receivedAt: MediaTime
                /// The duration after `receivedAt` at which we expect to receive updated information about the asset’s current location. Must be non-negative.
                var nextUpdateExpectedIn: TimeInterval {
                    willSet {
                        precondition(newValue >= 0)
                    }
                }

                init(receivedAt: MediaTime, nextUpdateExpectedIn: TimeInterval) {
                    precondition(nextUpdateExpectedIn >= 0)
                    self.receivedAt = receivedAt
                    self.nextUpdateExpectedIn = nextUpdateExpectedIn
                }

                /// The value that this prediction tells us will be returned by `CACurrentMediaTime` at the moment when updated information about the asset’s current location is next received.
                var expectedAt: MediaTime {
                    receivedAt + nextUpdateExpectedIn
                }

                /// The duration after which, according to this prediction, we expect to receive updated information about the asset’s current location. Always returns a non-negative value; that is, if the expected time has already elapsed, then it returns zero.
                ///
                /// - Parameters:
                ///     - now: The current time, as returned by `CACurrentMediaTime`.
                func timeUntilExpected(now: MediaTime) -> TimeInterval {
                    max(0, expectedAt - now)
                }
            }

            /// The value returned by `CACurrentMediaTime` at the start of the current `CADisplayLink` callback invocation.
            var now: MediaTime
            /// The latest prediction of when the next location update will be received.
            var nextLocationUpdatePrediction: NextLocationUpdatePrediction?

            init(now: MediaTime, nextLocationUpdatePrediction: NextLocationUpdatePrediction?) {
                self.now = now
                self.nextLocationUpdatePrediction = nextLocationUpdatePrediction
            }
        }

        /// Contains information about the progress of the animation and the work that remains to be done. You should not manipulate this value yourself, other than to add additional locations to its `locationsAwaitingAnimation` using the `add(_:)` method. All other manipulation of this value will be done by `DefaultLocationAnimationCalculator.calculate(input:)`, which will return an updated state value.
        struct State {
            /// The value returned by `CACurrentMediaTime` at the start of the previous `CADisplayLink` callback invocation. If `nil`, then the current invocation is the first one.
            var displayLinkLastFiredAt: MediaTime?

            /// Contains information about the locations of the asset that we still need to animate through.
            enum LocationsAwaitingAnimation {
                /// There are no locations awaiting animation.
                case noLocations
                /// There is a single location awaiting animation.
                case singleLocation(Location)
                /// There are at least two locations awaiting animation, in which case we also store information about how much of the journey between the first and second location we’ve already animated.
                case multipleLocations(MultipleLocations)

                /// Converts a `OneOrMoreLocationsAwaitingAnimation` value into a `LocationsAwaitingAnimation` value.
                init(oneOrMoreLocationsAwaitingAnimation: MultipleLocations.OneOrMoreLocationsAwaitingAnimation) {
                    switch oneOrMoreLocationsAwaitingAnimation {
                    case let .singleLocation(location):
                        self = .singleLocation(location)
                    case let .multipleLocations(multipleLocations):
                        self = .multipleLocations(multipleLocations)
                    }
                }

                /// Contains information about two or more locations awaiting animation, as well as information about how much of the journey between the first and second location we’ve already animated.
                struct MultipleLocations {
                    /// The first location awaiting animation.
                    var first: Location
                    /// The second location awaiting animation.
                    var second: Location
                    /// The proportion of the journey between the first and second location we’ve already animated. Lies in (0...1).
                    var proportionOfFirstToSecondAlreadyAnimated: Double {
                        willSet {
                            precondition((0 ... 1.0).contains(newValue))
                        }
                    }

                    /// The remaining locations to be animated through, after `first` and `second`.
                    var remaining: [Location]

                    init(
                        first: Location,
                        second: Location,
                        proportionOfFirstToSecondAlreadyAnimated: Double,
                        remaining: [Location]
                    ) {
                        precondition((0 ... 1.0).contains(proportionOfFirstToSecondAlreadyAnimated))

                        self.first = first
                        self.second = second
                        self.proportionOfFirstToSecondAlreadyAnimated = proportionOfFirstToSecondAlreadyAnimated
                        self.remaining = remaining
                    }

                    /// Like `LocationsAwaitingAnimation`, contains information about the locations of the asset that we still need to animate through. It differs from `LocationsAwaitingAnimation` in that it always contains at least one location; that is, it has no `noLocations` case.
                    enum OneOrMoreLocationsAwaitingAnimation {
                        /// Same as `LocationsAwaitingAnimation.singleLocation`.
                        case singleLocation(Location)
                        /// Same as `LocationsAwaitingAnimation.multipleLocations`.
                        case multipleLocations(MultipleLocations)

                        /// The first position, taking into account any of the journey already animated.
                        var startPosition: Position {
                            switch self {
                            case let .singleLocation(location):
                                return location.toPosition()
                            case let .multipleLocations(multipleLocations):
                                return multipleLocations.startPosition
                            }
                        }

                        /// The number of locations awaiting animation. Always >= 1.
                        var count: Int {
                            LocationsAwaitingAnimation(oneOrMoreLocationsAwaitingAnimation: self).count
                        }
                    }

                    /// Interpolates between locations by a given number of location transitions, taking into account the proportion of the journey between the first and second location we’ve already animated.
                    ///
                    /// - Parameters:
                    ///     - numberOfLocationTransitionsToProgress: The number of journeys from one location to the next that we should progress by. Must lie in (0...locationTransitionsCount).
                    ///
                    /// - Returns: A new list of locations awaiting animation, with any locations that are no longer needed removed, and with an updated animation progress.
                    func progressing(byNumberOfLocationTransitions numberOfLocationTransitionsToProgress: Double)
                        -> OneOrMoreLocationsAwaitingAnimation {
                        precondition((0 ... locationTransitionsCount).contains(numberOfLocationTransitionsToProgress))

                        // This may be greater than 1 (i.e. we have now progressed beyond the second location).
                        let overallPartialLocationIndexAfterProgressing = proportionOfFirstToSecondAlreadyAnimated +
                            numberOfLocationTransitionsToProgress

                        // If we have progressed beyond some locations, we want to pop those locations from our list of locations.
                        let numberOfLocationsToPop = Int(floor(overallPartialLocationIndexAfterProgressing))

                        var locations = [first, second] + remaining
                        precondition(numberOfLocationsToPop < locations.count) // sense check
                        locations.removeFirst(numberOfLocationsToPop)

                        let firstToSecondAlreadyAnimatedAfterProgressing = overallPartialLocationIndexAfterProgressing -
                            Double(numberOfLocationsToPop)

                        if locations.count > 1 {
                            return .multipleLocations(
                                .init(
                                    first: locations[0],
                                    second: locations[1],
                                    proportionOfFirstToSecondAlreadyAnimated: firstToSecondAlreadyAnimatedAfterProgressing,
                                    remaining: Array(locations.dropFirst(2))
                                )
                            )
                        } else { // locations.count == 1, confirmed by the “sense check” precondition above
                            return .singleLocation(locations[0])
                        }
                    }

                    /// The number of transitions between locations that remain to be animated, taking into account the proportion of the journey between the first and second location we’ve already animated.
                    var locationTransitionsCount: Double {
                        1 + Double(remaining.count) - proportionOfFirstToSecondAlreadyAnimated
                    }

                    /// The last position to be animated, taking into account the proportion of the journey between the first and second location we’ve already animated.
                    var startPosition: Position {
                        MultipleLocations.interpolatePositionLinear(
                            first: first.toPosition(),
                            second: second.toPosition(),
                            progress: proportionOfFirstToSecondAlreadyAnimated
                        )
                    }

                    /// Linearly interpolates the journey between two positions.
                    private static func interpolatePositionLinear(
                        first: Position,
                        second: Position,
                        progress: Double
                    ) -> Position {
                        let latitude = interpolateLinear(
                            first: first.latitude,
                            second: second.latitude,
                            progress: progress
                        )
                        let longitude = interpolateLinear(
                            first: first.longitude,
                            second: second.longitude,
                            progress: progress
                        )
                        let accuracy = interpolateLinear(
                            first: first.accuracy,
                            second: second.accuracy,
                            progress: progress
                        )
                        let bearing = interpolateLinear(
                            first: first.bearing,
                            second: second.bearing,
                            progress: progress
                        )

                        return Position(latitude: latitude, longitude: longitude, accuracy: accuracy, bearing: bearing)
                    }

                    /// Linearly interpolates between two numbers.
                    private static func interpolateLinear(first: Double, second: Double, progress: Double) -> Double {
                        first + (second - first) * progress
                    }
                }

                /// The list of locations that this `LocationsAwaitingAnimation` value contains.
                private var locations: [Location] {
                    switch self {
                    case .noLocations:
                        return []
                    case let .singleLocation(location):
                        return [location]
                    case let .multipleLocations(multipleLocations):
                        return [multipleLocations.first, multipleLocations.second] + multipleLocations.remaining
                    }
                }

                /// Creates a `LocationsAwaitingAnimation` value from a list of locations.
                private init(locations: [Location]) {
                    switch locations.count {
                    case 0:
                        self = .noLocations
                    case 1:
                        self = .singleLocation(locations[0])
                    default:
                        self = .multipleLocations(.init(
                            first: locations[0],
                            second: locations[1],
                            proportionOfFirstToSecondAlreadyAnimated: 0,
                            remaining: Array(locations.dropFirst(2))
                        ))
                    }
                }

                /// Appends a list of locations to a `LocationsAwaitingAnimation` value.
                mutating func add(_ locations: [Location]) {
                    let newLocations = self.locations + locations

                    switch self {
                    case .noLocations, .singleLocation:
                        self = .init(locations: newLocations)
                    case let .multipleLocations(multipleLocations):
                        self = .multipleLocations(
                            .init(
                                first: newLocations[0],
                                second: newLocations[1],
                                proportionOfFirstToSecondAlreadyAnimated: multipleLocations.proportionOfFirstToSecondAlreadyAnimated,
                                remaining: Array(newLocations.dropFirst(2))
                            )
                        )
                    }
                }

                /// The number of locations that this `LocationsAwaitingAnimation` value contains.
                var count: Int {
                    locations.count
                }
            }

            /// The locations of the asset that we still need to animate through.
            var locationsAwaitingAnimation: LocationsAwaitingAnimation
            /// The number of locations that we’ve animated through since we last emitted a camera update. If `nil`, then we have not yet emitted a camera update.
            var numberOfLocationsPoppedSinceLastCameraUpdate: Int?

            init(
                displayLinkLastFiredAt: MediaTime?,
                locationsAwaitingAnimation: LocationsAwaitingAnimation,
                numberOfLocationsPoppedSinceLastCameraUpdate: Int?
            ) {
                self.displayLinkLastFiredAt = displayLinkLastFiredAt
                self.locationsAwaitingAnimation = locationsAwaitingAnimation
                self.numberOfLocationsPoppedSinceLastCameraUpdate = numberOfLocationsPoppedSinceLastCameraUpdate
            }

            /// The initial state that should be used before the first call to `DefaultLocationCalculatorcalculate(input:)` is made.
            static let initial = State(
                displayLinkLastFiredAt: nil,
                locationsAwaitingAnimation: .noLocations,
                numberOfLocationsPoppedSinceLastCameraUpdate: nil
            )
        }

        /// User-specified parameters for configuring the animation.
        var config: Config
        /// The state of the world at the start of the current `CADisplayLink` callback invocation.
        var context: Context
        /// Information about the progress of the animation and the work that remains to be done.
        var state: State
    }

    /// Contains information about what actions should be taken in the current frame of the animation of an asset’s position on a map.
    struct CalculationResult {
        /// Contains information about animation-related events that should be emitted to subscribers.
        struct SubscriberUpdates {
            /// The new position that the asset should be moved to on the map.
            var positionToEmit: Position
            /// Whether the map should be re-centred on `positionToEmit`.
            var shouldEmitCameraPositionUpdate: Bool
        }

        /// The state that should be passed to the next invocation of `DefaultLocationAnimationCalculator.calculate(input:)`.
        var newState: Input.State
        /// Describes any animation-related events that should be emitted to subscribers.
        var subscriberUpdates: SubscriberUpdates?

        init(newState: Input.State, subscriberUpdates: SubscriberUpdates?) {
            self.newState = newState
            self.subscriberUpdates = subscriberUpdates
        }

        /// Returns a calculation result that specifies that no actions should be taken in the current frame.
        ///
        /// - Parameters:
        ///      - currentState: The current state.
        ///      - now: The value returned by `CACurrentMediaTime` at the start of the current `CADisplayLink` callback invocation.
        ///
        ///  - Returns: A new state, with updated timing information.
        static func noOp(currentState: Input.State, now: Input.MediaTime) -> Self {
            var newState = currentState
            newState.displayLinkLastFiredAt = now
            return .init(newState: newState, subscriberUpdates: nil)
        }
    }
}
