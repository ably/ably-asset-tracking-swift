import AblyAssetTrackingCore
import QuartzCore

enum DefaultLocationAnimatorCalculator {
    /// Calculates the events that should be emitted to subscribers of an asset’s map position in the current animation frame.
    ///
    /// - Parameters:
    ///     - input: The data needed to calculate the events to be emitted.
    ///
    /// - Returns: Information about what actions should be taken in the current frame.
    static func calculate(input: Input) -> CalculationResult {
        switch input.state.locationsAwaitingAnimation {
        case .noLocations:
            return .noOp(currentState: input.state, now: input.context.now)
        case let .singleLocation(location):
            var newState = input.state
            newState.displayLinkLastFiredAt = input.context.now
            newState.numberOfLocationsPoppedSinceLastCameraUpdate = input.state
                .numberOfLocationsPoppedSinceLastCameraUpdate ?? 0

            let shouldEmitCameraPositionUpdate = input.state.numberOfLocationsPoppedSinceLastCameraUpdate == nil

            let subscriberUpdates = CalculationResult.SubscriberUpdates(positionToEmit: location.toPosition(),
                                                                        shouldEmitCameraPositionUpdate: shouldEmitCameraPositionUpdate)

            return .init(newState: newState, subscriberUpdates: subscriberUpdates)
        case let .multipleLocations(multipleLocations):
            guard let nextLocationUpdatePrediction = input.context.nextLocationUpdatePrediction else {
                return .noOp(currentState: input.state, now: input.context.now)
            }

            let predictedTimeUntilNextLocationUpdate = nextLocationUpdatePrediction
                .timeUntilExpected(now: input.context.now)

            // We aim to animate through all of the contents of self.locationsAwaitingAnimation within this time.
            let locationQueueTargetEmptyDuration = predictedTimeUntilNextLocationUpdate + input.config
                .intentionalAnimationDelay

            let numberOfLocationTransitionsToProgressThisFrame: Double
            if let displayLinkLastFiredAt = input.state.displayLinkLastFiredAt {
                // We use the time elapsed since the CADisplayLink last fired to determine the current frame rate. I’m not sure whether this is the _best_ way to determine the current frame rate, but seems okay until I find out otherwise.
                let timeElapsedSinceDisplayLinkLastFired = input.context.now - displayLinkLastFiredAt
                precondition(timeElapsedSinceDisplayLinkLastFired >= 0)

                // This value has no upper bound.
                let proportionOfLocationUpdateQueueTargetEmptyDurationElapsedSinceDisplayLinkLastFired =
                    timeElapsedSinceDisplayLinkLastFired / locationQueueTargetEmptyDuration

                numberOfLocationTransitionsToProgressThisFrame = min(
                    proportionOfLocationUpdateQueueTargetEmptyDurationElapsedSinceDisplayLinkLastFired,
                    1
                ) * multipleLocations.locationTransitionsCount
            } else {
                numberOfLocationTransitionsToProgressThisFrame = 0
            }

            let newLocationsAwaitingAnimation = multipleLocations
                .progressing(byNumberOfLocationTransitions: numberOfLocationTransitionsToProgressThisFrame)
            let numberOfLocationsPoppped = input.state.locationsAwaitingAnimation.count - newLocationsAwaitingAnimation
                .count

            let numberOfLocationsPoppedSinceLastCameraUpdate: Int
            let shouldEmitCameraPositionUpdate: Bool
            if let inputNumberOfLocationsPoppedSinceLastCameraUpdate = input.state
                .numberOfLocationsPoppedSinceLastCameraUpdate {
                if inputNumberOfLocationsPoppedSinceLastCameraUpdate + numberOfLocationsPoppped >= input.config
                    .locationTransitionsBetweenCameraUpdates {
                    numberOfLocationsPoppedSinceLastCameraUpdate = 0
                    shouldEmitCameraPositionUpdate = true
                } else {
                    numberOfLocationsPoppedSinceLastCameraUpdate = inputNumberOfLocationsPoppedSinceLastCameraUpdate +
                        numberOfLocationsPoppped
                    shouldEmitCameraPositionUpdate = false
                }
            } else {
                numberOfLocationsPoppedSinceLastCameraUpdate = 0
                shouldEmitCameraPositionUpdate = true
            }

            let newState = Input.State(
                displayLinkLastFiredAt: input.context.now,
                locationsAwaitingAnimation: .init(oneOrMoreLocationsAwaitingAnimation: newLocationsAwaitingAnimation),
                numberOfLocationsPoppedSinceLastCameraUpdate: numberOfLocationsPoppedSinceLastCameraUpdate
            )

            let subscriberUpdates = CalculationResult.SubscriberUpdates(
                positionToEmit: newLocationsAwaitingAnimation.startPosition,
                shouldEmitCameraPositionUpdate: shouldEmitCameraPositionUpdate
            )

            return .init(newState: newState, subscriberUpdates: subscriberUpdates)
        }
    }
}
