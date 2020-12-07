import CoreLocation

/**
 Part of DTO used in `GeoJSONMessage`, used to map GeoJSON properties field (as defined in https://geojson.org ).
 All properties match properties from `CLLocation`.
 */
class GeoJSONProperties: Codable {
    
    /**
     Object horizontal accuracy in meters.
     */
    let accuracyHorizontal: Double?
    
    /**
     Object vertical accuracy in meters.
     */
    let accuracyVertical: Double?
    
    /**
     Object altitude in meters. May be positive or negative for abowe and below sea level measurement.
     */
    let altitude: Double
    
    /**
     Object bearing (or course) in degrees true North
     */
    let bearing: Double?
    
    /**
     Object bearing (or course) accuracy in degrees.
     */
    let accuracyBearing: Double?
    
    /**
     Object speed in meters per second
     */
    let speed: Double?
    
    /**
     Object speed accuracy in meters per second
     */
    let accuracySpeed: Double?
    
    /**
     Timestamp from a moment when measurment was done (in seconds since 1st of January 1970)
     */
    let time: Double
    
    /**
     Contains information about the logical floor that object is on
     in the current building if inside a supported venue. Nil if floor is unavailable.
     It's estimated value based on altitude and may not refer to actual building.
     
     Check list of supported
     [Airports](https://www.apple.com/ios/feature-availability/#maps-indoor-maps-airports) and
     [Malls](https://www.apple.com/ios/feature-availability/#maps-indoor-maps-malls) .
     */
    let floor: Int?
    
    
    init(location: CLLocation) {
        time = location.timestamp.timeIntervalSince1970
        floor = location.floor?.level
        altitude = location.altitude
        
        speed = location.speed >= 0 ? location.speed : nil
        accuracySpeed = location.speedAccuracy >= 0 ? location.speedAccuracy : nil
        accuracyHorizontal = location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil
        accuracyVertical = location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil
        
        bearing = location.course >= 0 ? location.course : nil
        if #available(iOS 13.4, *) {
            accuracyBearing = location.courseAccuracy
        } else {
            accuracyBearing = nil
        }
    }
}
