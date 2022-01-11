
import Foundation

public struct Location: Equatable {
    
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
     */
    public let horizontalAccuracy: Double
    
    /**
     The validity of the altitude values, and their estimated uncertainty, measured in meters.
     */
    public let verticalAccuracy: Double
    
    /**
     The direction in which the device is traveling, measured in degrees and relative to due north.
     */
    public let course: Double
    
    /**
     The accuracy of the course value, measured in degrees.
     */
    public let courseAccuracy: Double
    
    /**
     The instantaneous speed of the device, measured in meters per second.
     */
    public let speed: Double
    
    /**
     The accuracy of the speed value, measured in meters per second.
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
}
