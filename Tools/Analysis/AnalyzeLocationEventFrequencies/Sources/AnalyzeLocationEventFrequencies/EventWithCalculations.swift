import Foundation

struct EventWithCalculations: CSVRowWithColumnNamesConvertible {
    var event: Event
    var timeSinceLastOfType: TimeInterval?
    
    static func fromEvents(_ events: [Event]) -> [EventWithCalculations] {
        var lastTimestamps: [Event.EventType : Date] = [:]
        
        return events.map { event in
            let timeSinceLastOfType: TimeInterval?
            if let lastTimestamp = lastTimestamps[event.type] {
                timeSinceLastOfType = event.timestamp.timeIntervalSince(lastTimestamp)
            } else {
                timeSinceLastOfType = nil
            }
            
            lastTimestamps[event.type] = event.timestamp
            
            return .init(event: event, timeSinceLastOfType: timeSinceLastOfType)
        }
    }
    
    static var csvHeaders: [String] {
        return Event.csvHeaders + ["Time since last location update", "Time since last recorded location"]
    }
    
    var csvRows: [String] {
        let formattedTimeSinceLastOfType: String
        if let timeSinceLastOfType {
            formattedTimeSinceLastOfType = String(format: "%.3f", timeSinceLastOfType)
        } else {
            formattedTimeSinceLastOfType = ""
        }
        
        return event.csvRows + [
            event.type == .locationUpdate ? formattedTimeSinceLastOfType : "",
            event.type == .recordedLocation ? formattedTimeSinceLastOfType : ""
        ]
    }
}
