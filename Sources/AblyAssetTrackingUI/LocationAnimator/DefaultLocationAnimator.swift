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

    private let defaultDisplayLinkDuration: CFTimeInterval = 1.0/60.0
    
    // Dispatch queue for synchronized variable access
    private let globalBackgroundSyncronizeDataQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.globalBackgroundSyncronizeSharedData")
    
    // Dispatch queue for animation calculations
    private let processAnimationQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.processAnimationQueue")

    private var animationRequestSubject = PassthroughSubject<AnimationRequest, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var animationStartTime: CFAbsoluteTime = .zero
    private var animationStepStartTime: CFAbsoluteTime = .zero
    private var currentAnimationStepProgress: Double = 1.0
    private var currentAnimationStep: AnimationStep?
    private var currentAnimationStepsSinceLastCameraUpdate: Int = 0
    
    private var _animationSteps: [AnimationStep] = []
    private var animationSteps: [AnimationStep] {
        get {
            return globalBackgroundSyncronizeDataQueue.sync {
                _animationSteps
            }
        }
        set {
            globalBackgroundSyncronizeDataQueue.sync {
                self._animationSteps = newValue
            }
        }
    }
    
    private var _previousFinalPosition: Position?
    private var previousFinalPosition: Position? {
        get {
            return globalBackgroundSyncronizeDataQueue.sync {
                _previousFinalPosition
            }
        }
        set {
            globalBackgroundSyncronizeDataQueue.sync {
                self._previousFinalPosition = newValue
            }
        }
    }
    private var displayLink: CADisplayLink?
    private let displayLinkTarget = DisplayLinkTarget()
    private var subscribeForPositionUpdatesClosure: ((Position) -> Void)?
    private var subscribeForCameraPositionUpdatesClosure: ((Position) -> Void)?
    
    deinit {
        stopAnimationLoop()
    }
    
    public override init() {
        super.init()
        
        displayLinkTarget.locationAnimator = self
        
        startAnimationLoop()
        
        animationRequestSubject.receive(on: processAnimationQueue).sink { [weak self] request in
            guard let self = self else {
                return
            }
                        
            let steps = self.createAnimationStepsFromRequest(request)
            
            // Store last position from animation steps array
            // In next iteration this position could be start position for the first step of the animation
            self.previousFinalPosition = steps.last?.endPosition
            
            // This is an animation duration for request
            let expectedAnimationDuration = self.intentionalAnimationDelay + request.expectedIntervalBetweenLocationUpdatesInMilliseconds
            
            // Recalculate each animation step duration
            let animationStepDuration = expectedAnimationDuration / Double(steps.count)
            
            var previousStepEndTime: CFAbsoluteTime = self.animationSteps.last?.endTime ?? .zero
            for step in steps {
                var step = step
                step.endTime =  previousStepEndTime + animationStepDuration
                step.duration = animationStepDuration
                                
                self.animationSteps.append(step)
                previousStepEndTime = step.endTime
            }
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
        let displayLink = CADisplayLink(target: displayLinkTarget, selector: #selector(displayLinkTarget.displayLinkDidFire))
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
    
    private func createAnimationStepsFromRequest(_ request: AnimationRequest) -> [AnimationStep] {
        let requestPositions = (request.locationUpdate.skippedLocations + [request.locationUpdate.location]).map { $0.toPosition() }
        return requestPositions.enumerated().reduce([]) { [weak self] partialResult, value in
            guard let self = self else {
                return []
            }
            
            let startPosition = value.offset == 0
            ? self.getNewAnimationStartingPosition(locationUpdate: request.locationUpdate)
            : requestPositions[value.offset - 1]
            
            return partialResult + [AnimationStep(startPosition: startPosition, endPosition: value.element)]
        }
    }
    
    private func getNewAnimationStartingPosition(locationUpdate: LocationUpdate) -> Position {
        previousFinalPosition
            ?? locationUpdate.skippedLocations.first?.toPosition()
            ?? locationUpdate.location.toPosition()
    }
    
    private func calculatePosition(firstPosition: Position, secondPosition: Position, stepProgress: Double) -> Position {
        let latitude = interpolateLinear(first: firstPosition.latitude, second: secondPosition.latitude, progress: stepProgress)
        let longitude = interpolateLinear(first: firstPosition.longitude, second: secondPosition.longitude, progress: stepProgress)
        let accuracy = interpolateLinear(first: firstPosition.accuracy, second: secondPosition.accuracy, progress: stepProgress)
        let bearing = interpolateLinear(first: firstPosition.bearing, second: secondPosition.bearing, progress: stepProgress)
        
        return Position(latitude: latitude, longitude: longitude, accuracy: accuracy, bearing: bearing)
    }
    
    private func interpolateLinear(first: Double, second: Double, progress: Double) -> Double {
        first + (second - first) * progress
    }

    // Animation loop based od CADisplayLink
    private func animationLoop(link: CADisplayLink) {
        if currentAnimationStepProgress >= 1 && !animationSteps.isEmpty {
            
            if animationStartTime == .zero {
                animationStartTime = link.timestamp
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
        let position = calculatePosition(
            firstPosition: animationStep.startPosition,
            secondPosition: animationStep.endPosition,
            stepProgress: currentAnimationStepProgress
        )

        subscribeForPositionUpdatesClosure?(position)

        if currentAnimationStepsSinceLastCameraUpdate >= animationStepsBetweenCameraUpdates {
            currentAnimationStepsSinceLastCameraUpdate = 0
            subscribeForCameraPositionUpdatesClosure?(position)
        }
    }
    
    /// Used as our CADisplayLink’s strongly-referenced target, to avoid a strong reference cycle.
    private class DisplayLinkTarget {
        weak var locationAnimator: DefaultLocationAnimator?
        
        @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
            locationAnimator?.animationLoop(link: displayLink)
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

struct AnimationRequest {
    let locationUpdate: LocationUpdate
    let expectedIntervalBetweenLocationUpdatesInMilliseconds: Double
}

struct AnimationStep {
    let startPosition: Position
    let endPosition: Position
    var endTime: CFAbsoluteTime = .zero
    var duration: Double = -1.0 // value -1 means `unknown duration`
}
