import CoreLocation
import AblyAssetTrackingCore

protocol LocationServiceDelegate: AnyObject {
    func locationService(sender: LocationService, didFailWithError error: ErrorInformation)
    func locationService(sender: LocationService, didUpdateEnhancedLocationUpdate locationUpdate: EnhancedLocationUpdate)
    func locationService(sender: LocationService, didUpdateRawLocationUpdate locationUpdate: RawLocationUpdate)
}

struct LocationRecordingResult {
    var locationHistoryData: LocationHistoryData
    var rawHistoryFile: TemporaryFile
}

protocol LocationService: AnyObject {
    var delegate: LocationServiceDelegate? { get set }
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startRecordingLocation()
    func stopRecordingLocation(completion: @escaping ResultHandler<LocationRecordingResult?>)
    func changeLocationEngineResolution(resolution: Resolution)
}
