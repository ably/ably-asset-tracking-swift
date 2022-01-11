
import Foundation

public struct Location {
    
    /**
     Latitude of the location in degrees.
     */
    public let latitude: Double
    
    /**
     Longitude of the location in degrees.
     */
    public let longitude: Double
    
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
     The unix timestamp at which this location was determined.
     */
    public let timestamp: Double
}
