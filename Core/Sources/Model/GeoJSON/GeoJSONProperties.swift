import CoreLocation

/**
 Helper class used in `GeoJSONMessage` to map GeoJSON properties field (as defined at https://geojson.org ).
 All properties match properties from `CLLocation`.
 */
class GeoJSONProperties: Codable {

    /**
     Object horizontal accuracy in meters.
     */
    let accuracyHorizontal: Double

    /**
     Timestamp from a moment when measurment was done (in seconds since 1st of January 1970)
     */
    let time: Double

    /**
     Object altitude in meters. May be positive or negative for abowe and below sea level measurement.
     */
    let altitude: Double

    /**
     Object vertical accuracy in meters.
     */
    let accuracyVertical: Double?

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
     Contains information about the logical floor that object is on
     in the current building if inside a supported venue. Nil if floor is unavailable.
     It's estimated value based on altitude and may not refer to actual building.
     
     Check list of supported
     [Airports](https://www.apple.com/ios/feature-availability/#maps-indoor-maps-airports) and
     [Malls](https://www.apple.com/ios/feature-availability/#maps-indoor-maps-malls) .
     */
    let floor: Int?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accuracyHorizontal = try container.decode(Double.self, forKey: .accuracyHorizontal)
        time = try container.decode(Double.self, forKey: .time)
        altitude = try container.decode(Double.self, forKey: .altitude)

        floor = try? container.decode(Int.self, forKey: .floor)
        speed = try? container.decode(Double.self, forKey: .speed)
        accuracySpeed = try? container.decode(Double.self, forKey: .accuracySpeed)
        accuracyVertical = try? container.decode(Double.self, forKey: .accuracyVertical)
        accuracyBearing = try? container.decode(Double.self, forKey: .accuracyBearing)
        bearing = try? container.decode(Double.self, forKey: .bearing)

        guard accuracyHorizontal >= 0 else {
            throw AblyError.inconsistentData("Invalid horizontal accuracy got \(accuracyHorizontal)")
        }
    }

    init(location: CLLocation) {
        time = location.timestamp.timeIntervalSince1970
        floor = location.floor?.level
        altitude = location.altitude
        accuracyHorizontal = location.horizontalAccuracy

        speed = location.speed >= 0 ? location.speed : nil
        accuracySpeed = location.speedAccuracy >= 0 ? location.speedAccuracy : nil
        accuracyVertical = location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil

        bearing = location.course >= 0 ? location.course : nil
        if #available(iOS 13.4, *) {
            accuracyBearing = location.courseAccuracy
        } else {
            accuracyBearing = nil
        }
    }
}
