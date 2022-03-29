import Foundation
import Combine
import AblyAssetTrackingCore

class DefaultLocationAnimator: LocationAnimator {
    
    private let intentionalAnimationDelay: Double = 2000.0
    private let idleAnimationDelay: Double = 50.0 // in milliseconds
    private let singleAnimationFrameInterval = Double(1000.0 / 60.0) // in milliseconds (60fps)
    private let unknownDuration: Double = -1.0
    
    private let animationQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.animationLoop")
    private let processAnimationRequestQueue = DispatchQueue(label: "com.ably.tracking.SubscriberExample.locationAnimator.animationLoop")
    
    private var animationSteps: [AnimationStep] = []
    private var animationRequests: [AnimationRequest] = []
    private var previousFinalPosition: Position?
    
    private var positions: ((Position) -> ())?
    
    init() {
        animationLoop()
        animationRequestProcessLoop()
    }
   
    func animateLocationUpdate(location: LocationUpdate, interval: Double) {
        animationRequests.append(AnimationRequest(locationUpdate: location, interval: interval))
    }
    
    func positions(_ closure: @escaping (Position) -> ()) {
        self.positions = closure
    }
    
    private func animationRequestProcessLoop() {
        processAnimationRequestQueue.async { [weak self] in
            // swiftlint:disable control_statement
            while(true) {
                guard let self = self, !self.animationRequests.isEmpty  else {
                    return
                }
                
                let request = self.animationRequests.removeFirst()
                let steps = self.createAnimationStepsFromRequest(request)
                let expectedAnimationDuration = self.intentionalAnimationDelay + request.interval
                
                self.processAnimationRequestQueue.sync(flags: .barrier) {
                    self.animationSteps.append(contentsOf: steps)
                    let animationStepDuration = expectedAnimationDuration / Double(self.animationSteps.count)
                    self.animationSteps = self.animationSteps.map { step -> AnimationStep in
                        var step = step
                        step.updateDuration(animationStepDuration)
                        return step
                    }
                    self.previousFinalPosition = self.animationSteps.last?.endPosition
                }
            }
        }
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
            
            return partialResult + [AnimationStep(startPosition: startPosition, endPosition: value.element, duration: self.unknownDuration)]
        }
    }
    
    private func getNewAnimationStartingPosition(locationUpdate: LocationUpdate) -> Position {
        previousFinalPosition
            ?? locationUpdate.skippedLocations.first?.toPosition()
            ?? locationUpdate.location.toPosition()
    }
    
    private func animationLoop() {
        animationQueue.async { [weak self] in
            // swiftlint:disable control_statement
            while(true) {
                guard let self = self, !self.animationSteps.isEmpty else {
                    return
                }
                
                var step: AnimationStep?
                self.animationQueue.sync(flags: .barrier) {
                    step = self.animationSteps.removeFirst()
                }
                self.animateStep(step)
            }
        }
    }
    
    private func animateStep(_ step: AnimationStep?) {
        guard let step = step else {
            assertionFailure("No step to process")
            return
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        var timeElapsedFromStart: Double = .zero
        var timeProgressPercentage: Double = .zero
        
        while(timeProgressPercentage < 1) {
            timeElapsedFromStart = CFAbsoluteTimeGetCurrent() - startTime
            timeProgressPercentage = timeElapsedFromStart / step.duration
            let position = self.interpolateLinear(fraction: timeProgressPercentage, first: step.startPosition, second: step.endPosition)
            
            self.positions?(position)
            
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, self.singleAnimationFrameInterval, false)
        }
    }
    
    private func interpolateLinear(fraction: Double, first: Position, second: Position) -> Position {
        let latitude = interpolateLinear(fraction: fraction, first: first.latitude, second: second.latitude)
        let longitude = interpolateLinear(fraction: fraction, first: first.longitude, second: second.longitude)
        let accuracy = interpolateLinear(fraction: fraction, first: first.accuracy, second: second.accuracy)
        
        return DefaultPosition(latitude: latitude, longitude: longitude, accuracy: accuracy, bearing: second.bearing)
    }
    
    private func interpolateLinear(fraction: Double, first: Double, second: Double) -> Double {
        (second - first) * fraction + first
    }
}

struct DefaultPosition: Position {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let bearing: Double
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
    var duration: Double
    
    mutating func updateDuration(_ duration: Double) {
        self.duration = duration
    }
}
