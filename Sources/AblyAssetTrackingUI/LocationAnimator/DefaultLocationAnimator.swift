import Combine
import AblyAssetTrackingCore
import QuartzCore

public class DefaultLocationAnimator: NSObject, LocationAnimator {
            
    /**
       Defines how many animation steps have to complete before an event is passed to
       `subscribeForCameraPositionUpdatesClosure`
     */
    public var animationStepsBetweenCameraUpdates: Int = 1
    /**
     * A constant delay added to the animation duration. It helps to smooth out movement
     * when we receive a location update later than we've expected.
     */
    public var intentionalAnimationDelay: TimeInterval = 2.0
    
    // Dispatch queue for synchronized variable access
    private let globalBackgroundSynchronizeDataQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.globalBackgroundSyncronizeSharedData")
    
    // Dispatch queue for animation calculations
    private let processAnimationQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.processAnimationQueue")

    private var animationRequestSubject = PassthroughSubject<AnimationRequest, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private var animationStartTime: CFAbsoluteTime?
    private var animationStepStartTime: CFAbsoluteTime = .zero
    private var currentAnimationStepProgress = 0.0
    private var currentAnimationStep: AnimationStepWithTiming?
    private var currentAnimationStepsSinceLastCameraUpdate = 0
    
    private var _animationSteps: [AnimationStepWithTiming] = []
    private var animationSteps: [AnimationStepWithTiming] {
        get {
            return globalBackgroundSynchronizeDataQueue.sync {
                _animationSteps
            }
        }
        set {
            globalBackgroundSynchronizeDataQueue.sync {
                self._animationSteps = newValue
            }
        }
    }
    
    private var displayLink: CADisplayLink?
    private var subscribeForPositionUpdatesClosure: ((Position) -> Void)?
    private var subscribeForCameraPositionUpdatesClosure: ((Position) -> Void)?
    
    deinit {
        stopAnimationLoop()
    }
    
    public override init() {
        super.init()
        
        startAnimationLoop()
        
        animationRequestSubject.receive(on: processAnimationQueue).sink { [weak self] request in
            guard let self = self else {
                return
            }
                        
            let previousFinalPosition = self.animationSteps.last?.step.endPosition
            let steps = DefaultLocationAnimator.createAnimationStepsFromLocationUpdate(request.locationUpdate, previousFinalPosition: previousFinalPosition)
            
            let stepsWithTiming = DefaultLocationAnimator.addTimingToAnimationSteps(steps,
                                                                                    intentionalAnimationDelay: self.intentionalAnimationDelay,
                                                                                    expectedIntervalBetweenLocationUpdatesInMilliseconds: request.expectedIntervalBetweenLocationUpdatesInMilliseconds,
                                                                                    currentFinalStepEndTime: self.animationSteps.last?.endTime)

            self.animationSteps += stepsWithTiming
        }.store(in: &subscriptions)
    }
    
    public func stop() {
        stopAnimationLoop()
    }
   
    public func animateLocationUpdate(location: LocationUpdate, expectedIntervalBetweenLocationUpdatesInMilliseconds: Double) {
        animationRequestSubject.send(AnimationRequest(locationUpdate: location, expectedIntervalBetweenLocationUpdatesInMilliseconds: expectedIntervalBetweenLocationUpdatesInMilliseconds))
    }
    
    public func subscribeForPositionUpdates(_ closure: @escaping (Position) -> Void) {
        self.subscribeForPositionUpdatesClosure = closure
    }
    
    public func subscribeForCameraPositionUpdates(_ closure: @escaping (Position) -> Void) {
        self.subscribeForCameraPositionUpdatesClosure = closure
    }
    
    private func startAnimationLoop() {
        currentAnimationStepsSinceLastCameraUpdate = animationStepsBetweenCameraUpdates
        let displayLink = CADisplayLink(target: self, selector: #selector(animationLoop))
        displayLink.add(to: .current, forMode: .default)
        
        self.displayLink = displayLink
    }
    
    private func stopAnimationLoop() {
        guard let displayLink = displayLink else {
            return
        }
        
        displayLink.remove(from: .current, forMode: .default)
        displayLink.invalidate()
    }
    
    private static func createAnimationStepsFromLocationUpdate(_ locationUpdate: LocationUpdate, previousFinalPosition: Position?) -> [AnimationStep] {
        let locationUpdatePositions = (locationUpdate.skippedLocations + [locationUpdate.location]).map { $0.toPosition() }
        return locationUpdatePositions.enumerated().reduce([]) { partialResult, value in
            let startPosition = value.offset == 0
            ? getNewAnimationStartingPosition(locationUpdate: locationUpdate, previousFinalPosition: previousFinalPosition)
            : locationUpdatePositions[value.offset - 1]
            
            return partialResult + [AnimationStep(startPosition: startPosition, endPosition: value.element)]
        }
    }
    
    private static func getNewAnimationStartingPosition(locationUpdate: LocationUpdate, previousFinalPosition: Position?) -> Position {
        previousFinalPosition
            ?? locationUpdate.skippedLocations.first?.toPosition()
            ?? locationUpdate.location.toPosition()
    }
    
    private static func addTimingToAnimationSteps(_ steps: [AnimationStep], intentionalAnimationDelay: TimeInterval, expectedIntervalBetweenLocationUpdatesInMilliseconds: Double, currentFinalStepEndTime: CFAbsoluteTime?) -> [AnimationStepWithTiming] {
        var previousStepEndTime = currentFinalStepEndTime ?? .zero
        
        // This is an animation duration for request
        let expectedAnimationDuration = intentionalAnimationDelay + expectedIntervalBetweenLocationUpdatesInMilliseconds
        
        // Recalculate each animation step duration
        let animationStepDuration = expectedAnimationDuration / Double(steps.count)
        
        var stepsWithTiming: [AnimationStepWithTiming] = []
        
        for step in steps {
            let stepWithTiming = AnimationStepWithTiming(
                step: step,
                endTime: previousStepEndTime + animationStepDuration,
                duration: animationStepDuration)
            
            stepsWithTiming.append(stepWithTiming)
            previousStepEndTime = stepWithTiming.endTime
        }
        
        return stepsWithTiming
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

    // Animation loop based on CADisplayLink
    @objc
    private func animationLoop(link: CADisplayLink) {
        if (currentAnimationStep == nil || currentAnimationStepProgress >= 1) && !animationSteps.isEmpty {
            
            var animationStartTime: CFAbsoluteTime
            if let currentAnimationStartTime = self.animationStartTime {
                animationStartTime = currentAnimationStartTime
            } else {
                animationStartTime = link.timestamp
                self.animationStartTime = animationStartTime
            }
            
            animationStepStartTime = link.timestamp
            
            /**
             Step index is calculated against the time elapsed since receive first animation request.
             Each animation step has it's unique `endTime` which is estimated animation end time.
             */
            let stepIndex = animationSteps.firstIndex {
                $0.endTime >= (link.timestamp - animationStartTime)
            } ?? .zero
            currentAnimationStep = animationSteps[stepIndex]
            
            // Remove used steps and increase the `currentAnimationStepsSinceLastCameraUpdate` count
            let removeStepsRange = 0..<stepIndex
            currentAnimationStepsSinceLastCameraUpdate += removeStepsRange.count
            animationSteps.removeSubrange(removeStepsRange)
        } else if animationSteps.isEmpty && currentAnimationStepProgress >= 1 {
            
            currentAnimationStep = nil
        }
        
        guard let animationStep = currentAnimationStep else {
            return
        }
        
        /**
         Each animation step has it's own animation progress based on `animationStep` duration and `CADisplayLink` timestamp.
         */
        currentAnimationStepProgress = (link.timestamp - animationStepStartTime) / animationStep.duration

        /**
         Current position is interpolated against current step animation progress
         */
        let position = DefaultLocationAnimator.calculatePosition(
            firstPosition: animationStep.step.startPosition,
            secondPosition: animationStep.step.endPosition,
            stepProgress: currentAnimationStepProgress
        )

        subscribeForPositionUpdatesClosure?(position)

        if currentAnimationStepsSinceLastCameraUpdate >= animationStepsBetweenCameraUpdates {
            currentAnimationStepsSinceLastCameraUpdate = 0
            subscribeForCameraPositionUpdatesClosure?(position)
        }
    }
}

// Models
public extension Location {
    func toPosition() -> Position {
        Position(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            accuracy: horizontalAccuracy,
            bearing: course
        )
    }
}

private struct AnimationRequest {
    let locationUpdate: LocationUpdate
    let expectedIntervalBetweenLocationUpdatesInMilliseconds: Double
}

private struct AnimationStep {
    var startPosition: Position
    var endPosition: Position
}

private struct AnimationStepWithTiming {
    var step: AnimationStep
    var endTime: CFAbsoluteTime
    var duration: Double
}
