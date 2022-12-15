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
        
        for line in logFile.lines {
            print(line)
        }
    }
}
