import Foundation
import AblyAssetTrackingCore

/// A reference to a temporary file which will be deleted once there are no remaining strong references to this object.
public final class TemporaryFile {
    public let fileURL: URL
    private let logHandler: LogHandler?
    // For testing this class.
    private let didDeleteCallback: (() -> Void)?
    private static let cleanupQueue = DispatchQueue(label: "com.ably.AssetTracking.TemporaryFile.cleanupQueue", qos: .background)
    
    init(fileURL: URL, logHandler: LogHandler?, didDeleteCallback: (() -> Void)? = nil) {
        self.fileURL = fileURL
        self.logHandler = logHandler
        self.didDeleteCallback = didDeleteCallback
    }
    
    /// Executes the block and ensures that the file at ``fileURL`` will not be deleted during its execution.
    public func stayAlive(whilstExecuting action: () throws -> Void) rethrows {
        // (Here I’m relying on my belief that an object won’t be deallocated during the execution of one of its instance methods.)
        try action()
    }
    
    deinit {
        Self.cleanupQueue.async { [fileURL, logHandler, didDeleteCallback] in
            do {
                try FileManager.default.removeItem(at: fileURL)
                logHandler?.debug(message: "\(Self.self): Removed file at \(fileURL)", error: nil)
                didDeleteCallback?()
            } catch {
                logHandler?.error(message: "\(Self.self): Failed to remove file at \(fileURL)", error: error)
            }
        }
    }
}
