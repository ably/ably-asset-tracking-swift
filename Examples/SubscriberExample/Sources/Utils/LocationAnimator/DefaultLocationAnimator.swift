import Combine
import AblyAssetTrackingCore
import QuartzCore
import Accelerate

class DefaultLocationAnimator: NSObject, LocationAnimator {
    
    var fragmentaryPositionInterval: TimeInterval = 5.0
    
    // Default values
    private let intentionalAnimationDelay: TimeInterval = 2.0
    private let defaultDisplayLinkDuration: CFTimeInterval = 1.0/60.0
    
    // Dispatch queue for synchronized variable access
    private let globalBackgroundSyncronizeDataQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.globalBackgroundSyncronizeSharedData")
    
    // Dispatch queue for animation calculations
    private let processAnimationQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.processAnimationQueue")

    private var displayLinkStartTime: CFAbsoluteTime = .zero
    private var animationRequestSubject = PassthroughSubject<AnimationRequest, Never>()
    private var subscriptions = Set<AnyCancellable>()
        
    private var _animationPositions: [Position] = []
    private var animationPositions: [Position] {
        get {
            return globalBackgroundSyncronizeDataQueue.sync {
                _animationPositions
            }
        }
        set {
            globalBackgroundSyncronizeDataQueue.sync {
                self._animationPositions = newValue
            }
        }
    }
    
    private var previousFinalPosition: Position?
    private var displayLink: CADisplayLink?
    private var trackablePositionClosure: ((Position) -> Void)?
    private var fragmentaryPositionClosure: ((Position) -> Void)?
    
    deinit {
        stopAnimationLoop()
    }
    
    override init() {
        super.init()
        
        startAnimationLoop()
        
        animationRequestSubject.receive(on: processAnimationQueue).sink { [weak self] request in
            guard let self = self else {
                return
            }
            
            var steps = self.createAnimationStepsFromRequest(request)
            let expectedAnimationDuration = self.intentionalAnimationDelay + request.interval
            
            // Recalculate animation duration
            let animationStepDuration = expectedAnimationDuration / Double(steps.count)
            
            // Update each AnimationStep duration property
            steps = steps.map { step -> AnimationStep in
                var step = step
                step.duration = animationStepDuration
                return step
            }
            
            // Store last position from animation steps array
            // In next iteration this position could be start position for the first step of the animation
            self.previousFinalPosition = steps.last?.endPosition
            
            while !steps.isEmpty {
                self.animateStep(steps.removeFirst())
            }	
        }.store(in: &subscriptions)
    }
   
    func animateLocationUpdate(location: LocationUpdate, interval: Double) {
        animationRequestSubject.send(AnimationRequest(locationUpdate: location, interval: interval))
    }
    
    func trackablePosition(_ closure: @escaping (Position) -> Void) {
        self.trackablePositionClosure = closure
    }
    
    func fragmentaryPosition(_ closure: @escaping (Position) -> Void) {
        self.fragmentaryPositionClosure = closure
    }
    
    private func startAnimationLoop() {
        let displayLink = CADisplayLink(target: self, selector: #selector(animationLoop))
        displayLink.add(to: .current, forMode: .default)
        
        displayLinkStartTime = CFAbsoluteTimeGetCurrent()
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
    
    private func animateStep(_ step: AnimationStep?) {
        guard let step = step, step.duration > .zero else {
            return
        }
        
        let displayLinkDuration = self.displayLink?.duration ?? self.defaultDisplayLinkDuration
        
        // Interpolate position and accuracy
        let interpolatedPositions = interpolateLinear(
            numberOfSteps: UInt(step.duration / displayLinkDuration),
            first: step.startPosition,
            second: step.endPosition
        )
    
        animationPositions.append(contentsOf: interpolatedPositions)
    }
    
    private func interpolateLinear(numberOfSteps: UInt, first: Position, second: Position) -> [Position] {
        var latitudes = [Float](repeating: 0, count: Int(numberOfSteps))
        var longitudes = [Float](repeating: 0, count: Int(numberOfSteps))
        var accuracies = [Float](repeating: 0, count: Int(numberOfSteps))
        
        // Interpolate latitudes
        var start = Float(first.latitude)
        var end = Float(second.latitude)
    
        vDSP_vgen(&start, &end, &latitudes, vDSP_Stride(1), numberOfSteps)
        
        // Interpolate longitudes
        start = Float(first.longitude)
        end = Float(second.longitude)
        
        vDSP_vgen(&start, &end, &longitudes, vDSP_Stride(1), numberOfSteps)
        
        // Interpolate accuracies
        start = Float(first.accuracy)
        end = Float(second.accuracy)
        
        vDSP_vgen(&start, &end, &accuracies, vDSP_Stride(1), numberOfSteps)
                
        return latitudes.enumerated().map { index, latitude in
            DefaultPosition(
                latitude: Double(latitude),
                longitude: Double(longitudes[index]),
                accuracy: Double(accuracies[index]),
                bearing: second.bearing
            )
        }
    }

    // Animation loop based od CADisplayLink
    @objc
    private func animationLoop(link: CADisplayLink) {
        guard !animationPositions.isEmpty else {
            return
        }
        
        let animationPosition = animationPositions.removeFirst()
        trackablePositionClosure?(animationPosition)
        
        if CFAbsoluteTimeGetCurrent() - displayLinkStartTime >= fragmentaryPositionInterval {
            fragmentaryPositionClosure?(animationPosition)
            displayLinkStartTime = CFAbsoluteTimeGetCurrent()
        }
    }
}

// Models

struct DefaultPosition: Position, CustomDebugStringConvertible {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let bearing: Double
    
    var debugDescription: String {
        """
        latitude: \(latitude)
        longitude: \(longitude)
        accuracy: \(accuracy)
        bearing: \(bearing)
        """
    }
}

extension Location {
    func toPosition() -> Position {
        DefaultPosition(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            accuracy: horizontalAccuracy,
            bearing: course
        )
    }
}

struct AnimationRequest {
    let locationUpdate: LocationUpdate
    let interval: Double
}

struct AnimationStep {
    let startPosition: Position
    let endPosition: Position
    var duration: Double = -1.0 // value -1 means `unknown duration`
}
