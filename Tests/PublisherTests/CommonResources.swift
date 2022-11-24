import Foundation

enum CommonResources {
    static func url(forGeoTestDataJson name: String?, subdirectory subpath: String?) -> URL? {
        let moduleBundleSubdirectory = ("common/test-resources/geo/test-data" as NSString).appendingPathComponent(subpath ?? "")
        return Bundle.module.url(forResource: name, withExtension: "json", subdirectory: moduleBundleSubdirectory)
    }
}
