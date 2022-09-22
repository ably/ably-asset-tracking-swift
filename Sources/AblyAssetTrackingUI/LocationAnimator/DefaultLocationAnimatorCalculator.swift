import AblyAssetTrackingCore
import QuartzCore

struct DefaultLocationAnimatorCalculator {
    struct Input {
        struct Config {
            var animationStepsBetweenCameraUpdates: Int
            var intentionalAnimationDelay: TimeInterval
        }
        
        struct Context {
            struct NextLocationUpdatePrediction {
                /// The value returned by CACurrentMediaTime() at the moment when the predication about the next location update was received.
                var receivedAt: CFTimeInterval
                /// Non-negative.
                var nextUpdateExpectedIn: CFTimeInterval
            }
            
            /// The value returned by CACurrentMediaTime() in the current CADisplayLink invocation.
            var now: CFTimeInterval
            var nextLocationUpdatePrediction: NextLocationUpdatePrediction?
            
            init(now: CFTimeInterval, nextLocationUpdatePrediction: NextLocationUpdatePrediction?) {
                self.now = now
                self.nextLocationUpdatePrediction = nextLocationUpdatePrediction
            }
        }
        
        struct State {
            /// The value returned by CACurrentMediaTime() in the last CADisplayLink callback invocation.
            var displayLinkLastFiredAt: CFTimeInterval?
            var locationsAwaitingAnimation: [Location]
            var proportionOfFirstStepAlreadyAnimated: Double?
            var numberOfLocationsPoppedSinceLastCameraUpdate: Int?
            
            init(displayLinkLastFiredAt: CFTimeInterval?, locationsAwaitingAnimation: [Location], proportionOfFirstStepAlreadyAnimated: Double?, numberOfLocationsPoppedSinceLastCameraUpdate: Int?) {
                self.displayLinkLastFiredAt = displayLinkLastFiredAt
                self.locationsAwaitingAnimation = locationsAwaitingAnimation
                self.proportionOfFirstStepAlreadyAnimated = proportionOfFirstStepAlreadyAnimated
                self.numberOfLocationsPoppedSinceLastCameraUpdate = numberOfLocationsPoppedSinceLastCameraUpdate
            }
            
            static let initial = State(displayLinkLastFiredAt: nil, locationsAwaitingAnimation: [], proportionOfFirstStepAlreadyAnimated: nil, numberOfLocationsPoppedSinceLastCameraUpdate: nil)
        }
        
        var config: Config
        var context: Context
        var state: State
    }
    
    struct CalculationResult {
        struct SubscriberUpdates {
            var positionToEmit: Position
            var shouldEmitCameraPositionUpdate: Bool
        }
        
        var newState: Input.State
        var subscriberUpdates: SubscriberUpdates?
        
        init(newState: Input.State, subscriberUpdates: SubscriberUpdates?) {
            self.newState = newState
            self.subscriberUpdates = subscriberUpdates
        }
        
        static func noOp(input: Input) -> Self {
            var newState = input.state
            newState.displayLinkLastFiredAt = input.context.now
            return .init(newState: newState, subscriberUpdates: nil)
        }
    }

    static func calculate(input: Input) -> CalculationResult {
        guard let nextLocationUpdatePrediction = input.context.nextLocationUpdatePrediction else {
            return .noOp(input: input)
        }
        
        guard input.state.locationsAwaitingAnimation.count > 1 else {
            return .noOp(input: input)
        }
        
        let predictedTimeUntilNextLocationUpdate = nextLocationUpdatePrediction.receivedAt + nextLocationUpdatePrediction.nextUpdateExpectedIn - input.context.now
        
        // We aim to animate through all of the contents of self.locationsAwaitingAnimation within this time.
        let locationQueueTargetEmptyDuration = max(0, predictedTimeUntilNextLocationUpdate) + input.config.intentionalAnimationDelay
        
        // We just want to finish off the current animation before locationQueueTargetEmptyDuration elapses
        let numberOfLocationTransitionsToClear = Double(input.state.locationsAwaitingAnimation.count) - (input.state.proportionOfFirstStepAlreadyAnimated ?? 0) - 1
                
        var numberOfLocationTransitionsToProgressThisFrame: Double
        if let displayLinkLastFiredAt = input.state.displayLinkLastFiredAt {
            let timeElapsedSinceDisplayLinkLastFired = input.context.now - displayLinkLastFiredAt
            let proportionOfLocationUpdateQueueTargetEmptyDurationElapsedSinceDisplayLinkLastFired = timeElapsedSinceDisplayLinkLastFired / locationQueueTargetEmptyDuration
            numberOfLocationTransitionsToProgressThisFrame = proportionOfLocationUpdateQueueTargetEmptyDurationElapsedSinceDisplayLinkLastFired * Double(numberOfLocationTransitionsToClear)
        } else {
            numberOfLocationTransitionsToProgressThisFrame = 0
        }
                
        var numberOfLocationsToPop = 0
        // Now we need to figure out how many updates (if any) we need to drop, drop them, and update numberOfLocationTransitionsToProgressThisFrame
        var proportionOfFirstStepAlreadyAnimated = input.state.proportionOfFirstStepAlreadyAnimated ?? 0
        while proportionOfFirstStepAlreadyAnimated + numberOfLocationTransitionsToProgressThisFrame > 1 {
            numberOfLocationTransitionsToProgressThisFrame -= (1 - proportionOfFirstStepAlreadyAnimated)
            numberOfLocationsToPop += 1
            proportionOfFirstStepAlreadyAnimated = 0
        }
        
        var locationsAwaitingAnimation = input.state.locationsAwaitingAnimation
        locationsAwaitingAnimation.removeFirst(numberOfLocationsToPop)
                
        let startLocation = locationsAwaitingAnimation[0]
        let endLocation = locationsAwaitingAnimation[1]
        let stepProgress = proportionOfFirstStepAlreadyAnimated + numberOfLocationTransitionsToProgressThisFrame
        let position = calculatePosition(
            firstPosition: startLocation.toPosition(),
            secondPosition: endLocation.toPosition(),
            stepProgress: stepProgress
        )
        
        let numberOfLocationsPoppedSinceLastCameraUpdate: Int
        let shouldEmitCameraPositionUpdate: Bool
        if let inputNumberOfLocationsPoppedSinceLastCameraUpdate = input.state.numberOfLocationsPoppedSinceLastCameraUpdate {
            if inputNumberOfLocationsPoppedSinceLastCameraUpdate + numberOfLocationsToPop >= input.config.animationStepsBetweenCameraUpdates {
                numberOfLocationsPoppedSinceLastCameraUpdate = 0
                shouldEmitCameraPositionUpdate = true
            } else {
                numberOfLocationsPoppedSinceLastCameraUpdate = inputNumberOfLocationsPoppedSinceLastCameraUpdate + numberOfLocationsToPop
                shouldEmitCameraPositionUpdate = false
            }
        } else {
            numberOfLocationsPoppedSinceLastCameraUpdate = 0
            shouldEmitCameraPositionUpdate = true
        }
                
        let newState = Input.State(
            displayLinkLastFiredAt: input.context.now,
            locationsAwaitingAnimation: locationsAwaitingAnimation,
            proportionOfFirstStepAlreadyAnimated: stepProgress,
            numberOfLocationsPoppedSinceLastCameraUpdate: numberOfLocationsPoppedSinceLastCameraUpdate)
        
        let subscriberUpdates = CalculationResult.SubscriberUpdates(positionToEmit: position,
                                                                    shouldEmitCameraPositionUpdate: shouldEmitCameraPositionUpdate)
        
        return .init(newState: newState, subscriberUpdates: subscriberUpdates)
    }
        
    private static func calculatePosition(firstPosition: Position, secondPosition: Position, stepProgress: Double) -> Position {
        let latitude = interpolateLinear(first: firstPosition.latitude, second: secondPosition.latitude, progress: stepProgress)
        let longitude = interpolateLinear(first: firstPosition.longitude, second: secondPosition.longitude, progress: stepProgress)
        let accuracy = interpolateLinear(first: firstPosition.accuracy, second: secondPosition.accuracy, progress: stepProgress)
        let bearing = interpolateLinear(first: firstPosition.bearing, second: secondPosition.bearing, progress: stepProgress)
        
        return Position(latitude: latitude, longitude: longitude, accuracy: accuracy, bearing: bearing)
    }
    
    private static func interpolateLinear(first: Double, second: Double, progress: Double) -> Double {
        first + (second - first) * progress
    }
}
