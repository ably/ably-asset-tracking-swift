/**
 Helper class used in `GeoJSONMessage` to map GeoJSON properties field (as defined at https://geojson.org ).
 All properties match properties from `CLLocation`.
 */
struct GeoJSONProperties: Codable {

    /**
     Object horizontal accuracy in meters.
     */
    let accuracyHorizontal: Double

    /**
     Timestamp from a moment when measurment was done (in seconds since 1st of January 1970)
     */
    let time: Double

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let horizontalAccuracy = try container.decode(Double.self, forKey: .accuracyHorizontal)
        if let accuracyValidationError = LocationValidator.isAccuracyValid(horizontalAccuracy) {
            throw accuracyValidationError
        }
        
        accuracyHorizontal = horizontalAccuracy
        time = try container.decode(Double.self, forKey: .time)
        
        floor = try? container.decode(Int.self, forKey: .floor)
        speed = try? container.decode(Double.self, forKey: .speed).isLessThanZeroThenNil()
        accuracySpeed = try? container.decode(Double.self, forKey: .accuracySpeed).isLessThanZeroThenNil()
        accuracyVertical = try? container.decode(Double.self, forKey: .accuracyVertical).isLessThanZeroThenNil()
        accuracyBearing = try? container.decode(Double.self, forKey: .accuracyBearing).isLessThanZeroThenNil()
        bearing = try? container.decode(Double.self, forKey: .bearing).isLessThanZeroThenNil()
    }

    init(location: Location) throws {
        if let accuracyValidationError = LocationValidator.isAccuracyValid(location.horizontalAccuracy) {
            throw accuracyValidationError
        }
        
        accuracyHorizontal = location.horizontalAccuracy
        time = location.timestamp
        
        floor = location.floorLevel
        speed = location.speed.isLessThanZeroThenNil()
        accuracySpeed = location.speedAccuracy.isLessThanZeroThenNil()
        accuracyVertical = location.verticalAccuracy.isLessThanZeroThenNil()
        bearing = location.course.isLessThanZeroThenNil()
        
        if #available(iOS 13.4, *) {
            accuracyBearing = location.courseAccuracy.isLessThanZeroThenNil()
        } else {
            accuracyBearing = nil
        }
    }
}

private extension Optional where Wrapped == Double {
    func isLessThanZeroThenNil() -> Double? {
        guard let value = self else {
            return nil
        }
        
        return value.isLessThanZeroThenNil()
    }
}

private extension Double {
    func isLessThanZeroThenNil() -> Double? {
        return self.isLess(than: 0) ? nil : self
    }
}
