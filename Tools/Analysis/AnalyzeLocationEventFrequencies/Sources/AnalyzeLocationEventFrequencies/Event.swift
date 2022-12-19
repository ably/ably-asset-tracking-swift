import Foundation

struct Event: Comparable, CSVRowWithColumnNamesConvertible {
    var timestamp: Date
    var type: EventType
    
    enum EventType: CSVRowWithColumnNamesConvertible, Hashable {
        case locationUpdate
        case requestLocationUpdate
        case recordedLocation
        
        static var csvHeaders: [String] {
            return ["Event type"]
        }
        
        var csvRows: [String] {
            switch self {
            case .locationUpdate:
                return ["Location update"]
            case .requestLocationUpdate:
                return ["Request location update"]
            case .recordedLocation:
                return ["Recorded location"]
            }
        }
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
    
    static func fromLogLine(_ logLine: LogLine) -> [Self] {
        switch logLine {
        case let .locationUpdate(timestamp):
            return [.init(timestamp: timestamp, type: .locationUpdate)]
        case let .requestLocationUpdate(timestamp):
            return [.init(timestamp: timestamp, type: .requestLocationUpdate)]
        case let .locationHistoryData(locationHistoryData):
            return locationHistoryData.events.map { event in
                return .init(timestamp: Date(timeIntervalSince1970: event.properties.time), type: .recordedLocation)
            }
        }
    }
    
    static var csvHeaders: [String] {
        return ["Timestamp (ISO 8601)"] + EventType.csvHeaders
    }
    
    var csvRows: [String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
        return [formatter.string(from: timestamp)] + type.csvRows
    }
}
