import Foundation
import AblyAssetTrackingCore

protocol AblySubscriberService: AnyObject {
    var delegate: AblySubscriberServiceDelegate? { get set }
    
    func start(completion: @escaping ResultHandler/*Void*/)
    func stop(completion: @escaping ResultHandler/*Void*/)
    func sendResolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler/*Void*/)
}
