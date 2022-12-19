import Foundation
import LogParser

enum LogLine {
    case locationUpdate(timestamp: Date)
    case requestLocationUpdate(timestamp: Date)
    case locationHistoryData(LocationHistoryData)
    
    private struct KnownLogMessage {
        var lastSubsystem: String
        var prefix: String
        
        static let locationUpdate = Self(lastSubsystem: "DefaultLocationService", prefix: "passiveLocationManager.didUpdateLocation")
        static let requestLocationUpdate = Self(lastSubsystem: "DefaultLocationService", prefix: "Received requestLocationUpdate")
        
        func matches(_ exampleAppSDKLine: ExampleAppSDKLogLine) -> Bool {
            return exampleAppSDKLine.message.subsystems.last == lastSubsystem && exampleAppSDKLine.message.message.hasPrefix(prefix)
        }
    }
    
    init?(exampleAppLine: ExampleAppLogFile.Line) {
        switch exampleAppLine {
        case let .other(line):
            let prefix = "Received location history data: "
            guard let prefixRange = line.range(of: prefix) else {
                return nil
            }
            
            let jsonString = line[prefixRange.upperBound...]
            let jsonData = jsonString.data(using: .utf8)!
            let locationHistoryData = try! JSONDecoder().decode(LocationHistoryData.self, from: jsonData)
            self = .locationHistoryData(locationHistoryData)
        case let .sdk(exampleAppSDKLine):
            if KnownLogMessage.locationUpdate.matches(exampleAppSDKLine) {
                self = .locationUpdate(timestamp: exampleAppSDKLine.timestamp)
            } else if KnownLogMessage.requestLocationUpdate.matches(exampleAppSDKLine) {
                self = .requestLocationUpdate(timestamp: exampleAppSDKLine.timestamp)
            } else {
                return nil
            }
        }
    }
}
