enum LocationValidator {
    private static let latitudeRange = -90.0...90.0
    private static let longitudeRange = -180.0...180.0
    
    static func isAccuracyValid(_ value: Double) -> ErrorInformation? {
        guard value >= 0 else {
            return ErrorInformation(type: .commonError(errorMessage: "Invalid horizontal accuracy got \(value)"))
        }
        
        return nil
    }
    
    static func validate(latitude: Double, longitude: Double) -> ErrorInformation? {
        guard isLatitudeInRange(latitude) else {
            return ErrorInformation(type: .commonError(errorMessage: "Latitude out of range [-90, 90]. Received: (\(latitude))"))
        }
        
        guard isLongitudeInRange(longitude) else {
            return ErrorInformation(type: .commonError(errorMessage: "Longitude out of range [-180, 180]. Received (\(longitude))"))
        }
        
        return nil
    }
    
    private static func isLatitudeInRange(_ value: Double) -> Bool {
        return latitudeRange ~= value
    }
    
    private static func isLongitudeInRange(_ value: Double) -> Bool {
        return longitudeRange ~= value
    }
}
