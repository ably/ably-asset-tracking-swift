protocol CSVRowConvertible {
    var csvRows: [String] { get }
}

protocol CSVRowWithColumnNamesConvertible: CSVRowConvertible {
    static var csvHeaders: [String] { get }
}

enum CSVExport {
    // A very rudimentary CSV export that does no quoting or escaping or anything like that.
    static func export<T: CSVRowWithColumnNamesConvertible>(rows: [T]) -> String {
        let csvRowStrings = ([T.csvHeaders] + rows.map(\.csvRows)).map { $0.joined(separator: ",") }
        return csvRowStrings.joined(separator: "\n")
    }
}
