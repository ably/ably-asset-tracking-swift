import Foundation

public class Version {
    
    enum ErrorInfo: Error {
        case fileNotFound(String)
        case cantReadData(URL)
        case cantConvertData
    }
    
    private static let fileName = "VERSION"
    
    public static func currentVersion() -> String {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: nil) else {
            fatalError("\(ErrorInfo.fileNotFound(fileName))")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("\(ErrorInfo.cantReadData(url))")
        }
        
        guard let versionString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            fatalError("\(ErrorInfo.cantConvertData)")
        }

        return versionString
    }
}
