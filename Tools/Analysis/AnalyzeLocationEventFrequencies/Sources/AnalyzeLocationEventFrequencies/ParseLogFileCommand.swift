import ArgumentParser
import LogParser
import Foundation

@main struct ParseLogFile: ParsableCommand {
    @Argument(help: "The path to the example app log file.")
    var input: String
    
    mutating func run() throws {
        let url = URL(fileURLWithPath: input)
        let data = try Data(contentsOf: url)
        let logFile = try ExampleAppLogFile(data: data)
                
        let lines = logFile.lines.compactMap { LogLine(exampleAppLine: $0) }
        let events = lines.flatMap { Event.fromLogLine($0) }.sorted()
        let eventsWithCalculations = EventWithCalculations.fromEvents(events)
        
        let csv = CSVExport.export(rows: eventsWithCalculations)
        print(csv)
    }
}
