import UIKit
import os.log

private let subsystem = "io.ably.asset-tracking.Publisher"
extension OSLog {
    static let publisher = OSLog(subsystem: subsystem, category: "Publisher")
    static let location = OSLog(subsystem: subsystem, category: "LocationService")
    static let ably = OSLog(subsystem: subsystem, category: "AblyService")
}
