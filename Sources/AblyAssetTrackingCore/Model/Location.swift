import Foundation

public struct Location: Equatable {

    /**
     The latitude and longitude associated with a location, specified using the WGS 84 reference frame.
     */
    public let coordinate: LocationCoordinate

    /**
     The altitude above mean sea level associated with a location, measured in meters.
     */
    public let altitude: Double

    /**
     Altitude of the location in meters above the WGS 84 reference ellipsoid.
     0.0 if not available.
     */
    public let ellipsoidalAltitude: Double

    /**
     The radius of uncertainty for the location, measured in meters.
     Negative if the lateral accuracy is invalid.
     */
    public let horizontalAccuracy: Double

    /**
     The validity of the altitude values, and their estimated uncertainty, measured in meters.
     Negative if the vertical accuracy is invalid.
     */
    public let verticalAccuracy: Double

    /**
     The direction in which the device is traveling, measured in degrees and relative to due north.
     Negative if course is invalid.
     */
    public let course: Double

    /**
     The accuracy of the course value, measured in degrees.
     Negative if course accuracy is invalid.
     */
    public let courseAccuracy: Double

    /**
     The instantaneous speed of the device, measured in meters per second.
     Negative if speed is invalid.
     */
    public let speed: Double

    /**
     The accuracy of the speed value, measured in meters per second.
     Negative if speed accuracy is invalid.
     */
    public let speedAccuracy: Double

    /**
     The logical floor of the building.
     nil if not available
     */
    public let floorLevel: Int?

    /**
     The unix timestamp at which this location was determined.
     */
    public let timestamp: Double

    public init(
        coordinate: LocationCoordinate,
        altitude: Double,
        ellipsoidalAltitude: Double,
        horizontalAccuracy: Double,
        verticalAccuracy: Double,
        course: Double,
        courseAccuracy: Double,
        speed: Double,
        speedAccuracy: Double,
        floorLevel: Int?,
        timestamp: Double
    ) {

        self.coordinate = coordinate
        self.altitude = altitude
        self.ellipsoidalAltitude = ellipsoidalAltitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.floorLevel = floorLevel
        self.timestamp = timestamp
    }

    public init(coordinate: LocationCoordinate) {
        self.coordinate = coordinate
        self.altitude = .zero
        self.ellipsoidalAltitude = .zero
        self.horizontalAccuracy = .zero
        self.verticalAccuracy = .zero
        self.course = .zero
        self.courseAccuracy = .zero
        self.speed = .zero
        self.speedAccuracy = .zero
        self.floorLevel = nil
        self.timestamp = .zero
    }

    /**
     Utility function that coerces NaN values to sensible defaults or negative values.
     */
    func sanitize() -> Location {
        return Location(
            coordinate: coordinate,
            altitude: altitude,
            ellipsoidalAltitude: ellipsoidalAltitude.isFinite ? ellipsoidalAltitude : .zero,
            horizontalAccuracy: horizontalAccuracy.isFinite ? horizontalAccuracy : -1.0,
            verticalAccuracy: verticalAccuracy.isFinite ? verticalAccuracy : -1.0,
            course: course.isFinite ? course : -1.0,
            courseAccuracy: courseAccuracy.isFinite ? courseAccuracy : -1.0,
            speed: speed.isFinite ? speed : -1.0,
            speedAccuracy: speedAccuracy.isFinite ? speedAccuracy : -1.0,
            floorLevel: floorLevel,
            timestamp: timestamp
        )
    }

    /**
     Utility function that returns a successful result with the Location if and only if it is valid.
     If it is invalid, the result is failed with a list of validation errors.
     */
    func validate() -> Result<Location, LocationValidationError> {
        var locationValidationErrors: [ErrorInformation] = []
        if !coordinate.latitude.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "latitude must be finite, got \(coordinate.latitude)")))
        }
        if !coordinate.longitude.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "longitude must be finite, got \(coordinate.longitude)")))
        }
        if !altitude.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "altitude must be finite, got \(altitude)")))
        }
        if !ellipsoidalAltitude.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "ellipsoidalAltitude must be finite, got \(ellipsoidalAltitude)")))
        }
        if !horizontalAccuracy.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "horizontalAccuracy must be finite, got \(horizontalAccuracy)")))
        }
        if !verticalAccuracy.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "verticalAccuracy must be finite, got \(verticalAccuracy)")))
        }
        if !course.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "course must be finite, got \(course)")))
        }
        if !courseAccuracy.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "courseAccuracy must be finite, got \(courseAccuracy)")))
        }
        if !speed.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "speed must be finite, got \(speed)")))
        }
        if !speedAccuracy.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "speedAccuracy must be finite, got \(speedAccuracy)")))
        }
        if timestamp == 0 || !timestamp.isFinite {
            locationValidationErrors.append(ErrorInformation(type: .commonError(errorMessage: "timestamp must be non-zero and finite, got \(timestamp)")))
        }
        if !locationValidationErrors.isEmpty {
            return Result.failure(LocationValidationError(errors: locationValidationErrors))
        }
        return Result.success(self)
    }
}
