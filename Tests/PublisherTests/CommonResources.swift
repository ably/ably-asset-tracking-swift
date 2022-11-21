import Foundation

enum CommonResources {
    static func url(forTestResourceJson name: String?, subdirectory subpath: String?) -> URL? {
        let moduleBundleSubdirectory = ("common/test-resources" as NSString).appendingPathComponent(subpath ?? "")
        return Bundle.module.url(forResource: name, withExtension: "json", subdirectory: moduleBundleSubdirectory)
    }
}
