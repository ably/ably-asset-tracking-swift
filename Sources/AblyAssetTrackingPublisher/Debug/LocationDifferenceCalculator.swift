import CoreLocation

/// Calculates the differences between two `CLLocation` instances. To be used for debugging, for example to assess the changes in a sequence of `CLLocation` instances received over time. It takes into account all of the properties of `CLLocation` that are present in Xcode 14.0.
enum LocationDifferenceCalculator {
    enum Property: CustomDebugStringConvertible {
        enum FloorDifference: CustomDebugStringConvertible {
            case oneNilAndTheOtherNot
            case bothNonNil(Int)
            
            fileprivate init?(floorOrNil1: CLFloor?, floorOrNil2: CLFloor?) {
                if let floor1 = floorOrNil1, let floor2 = floorOrNil2 {
                    if floor1.level == floor2.level {
                        return nil
                    } else {
                        self = .bothNonNil(abs(floor1.level - floor2.level))
                    }
                } else {
                    self = .oneNilAndTheOtherNot
                }
            }
            
            var debugDescription: String {
                switch self {
                case .oneNilAndTheOtherNot: return "oneNilAndTheOtherNot"
                case let .bothNonNil(difference): return "bothNoneNil(\(difference))"
                }
            }
        }
        
        enum SourceInformationDifference: CustomDebugStringConvertible {
            enum Property: CustomDebugStringConvertible {
                case isSimulatedBySoftware
                case isProducedByAccessory
                
                var debugDescription: String {
                    switch self {
                    case .isSimulatedBySoftware: return "isSimulatedBySoftware"
                    case .isProducedByAccessory: return "isProducedByAccessory"
                    }
                }
            }
            
            case oneNilAndTheOtherNot
            case bothNonNil([Property])
            
            @available(iOS 15.0, *)
            fileprivate init?(sourceInformationOrNil1: CLLocationSourceInformation?, sourceInformationOrNil2: CLLocationSourceInformation?) {
                if let sourceInformation1 = sourceInformationOrNil1, let sourceInformation2 = sourceInformationOrNil2 {
                    var differentProperties: [Property] = []
                    if sourceInformation1.isSimulatedBySoftware != sourceInformation2.isSimulatedBySoftware {
                        differentProperties.append(.isSimulatedBySoftware)
                    }
                    if sourceInformation1.isProducedByAccessory != sourceInformation2.isProducedByAccessory {
                        differentProperties.append(.isProducedByAccessory)
                    }
                    if differentProperties.isEmpty {
                        return nil
                    } else {
                        self = .bothNonNil(differentProperties)
                    }
                } else {
                    self = .oneNilAndTheOtherNot
                }
            }
            
            var debugDescription: String {
                switch self {
                case .oneNilAndTheOtherNot: return "oneNilAndTheOtherNot"
                case let .bothNonNil(difference): return "bothNoneNil(\(difference))"
                }
            }
        }
        
        case coordinate(Double, Double)
        case altitude(Double)
        case ellipsoidalAltitude(Double)
        case horizontalAccuracy(Double)
        case verticalAccuracy(Double)
        case course(Double)
        case courseAccuracy(Double)
        case speed(Double)
        case speedAccuracy(Double)
        case timestamp(TimeInterval)
        case floor(FloorDifference)
        case sourceInformation(SourceInformationDifference)
        
        var debugDescription: String {
            switch self {
            case let .coordinate(latitudeDifference, longitudeDifference): return "coordinate(\(latitudeDifference), \(longitudeDifference))"
            case let .altitude(difference): return "altitude(\(difference))"
            case let .ellipsoidalAltitude(difference): return "ellipsoidalAltitude(\(difference))"
            case let .horizontalAccuracy(difference): return "horizontalAccuracy(\(difference))"
            case let .verticalAccuracy(difference): return "verticalAccuracy(\(difference))"
            case let .course(difference): return "course(\(difference))"
            case let .courseAccuracy(difference): return "courseAccuracy(\(difference))"
            case let .speed(difference): return "speed(\(difference))"
            case let .speedAccuracy(difference): return "speedAccuracy(\(difference))"
            case let .timestamp(difference): return "timestamp(\(difference))"
            case let .floor(difference): return "floor(\(String(reflecting: difference)))"
            case let .sourceInformation(difference): return "sourceInformation(\(String(reflecting: difference)))"
            }
        }
    }
    
    static func calculateDifferences(first: CLLocation, second: CLLocation) -> [Property] {
        var result: [Property] = []
        
        if first.coordinate != second.coordinate { result.append(.coordinate(abs(first.coordinate.latitude - second.coordinate.latitude), abs(first.coordinate.longitude - second.coordinate.longitude))) }
        if first.altitude != second.altitude { result.append(.altitude(abs(first.altitude - second.altitude))) }
        if #available(iOS 15, *) {
            if first.ellipsoidalAltitude != second.ellipsoidalAltitude { result.append(.ellipsoidalAltitude(abs(first.ellipsoidalAltitude - second.ellipsoidalAltitude))) }
        }
        if first.horizontalAccuracy != second.horizontalAccuracy { result.append(.horizontalAccuracy(abs(first.horizontalAccuracy - second.horizontalAccuracy))) }
        if first.verticalAccuracy != second.verticalAccuracy { result.append(.verticalAccuracy(abs(first.verticalAccuracy - second.verticalAccuracy))) }
        if first.course != second.course { result.append(.course(abs(first.course - second.course))) }
        if #available(iOS 13.4, *) {
            if first.courseAccuracy != second.courseAccuracy { result.append(.courseAccuracy(abs(first.courseAccuracy - second.courseAccuracy))) }
        }
        if first.speed != second.speed { result.append(.speed(abs(first.speed - second.speed))) }
        if first.speedAccuracy != second.speedAccuracy {  result.append(.speedAccuracy(abs(first.speedAccuracy - second.speedAccuracy))) }
        if first.timestamp != second.timestamp { result.append(.timestamp(abs(first.timestamp.distance(to: second.timestamp)))) }
        if let floorDifference = Property.FloorDifference(floorOrNil1: first.floor, floorOrNil2: second.floor) {
            result.append(.floor(floorDifference))
        }
        if #available(iOS 15.0, *) {
            if let sourceInformationDifference = Property.SourceInformationDifference(sourceInformationOrNil1: first.sourceInformation, sourceInformationOrNil2: second.sourceInformation) {
                result.append(.sourceInformation(sourceInformationDifference))
            }
        }
        
        return result
    }
}
