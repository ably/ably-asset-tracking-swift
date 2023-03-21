@testable import AblyAssetTrackingPublisher
import XCTest

class TemporaryFileTests: XCTestCase {
    func testDeinit_removesFile() throws {
        let fileManager = FileManager.default

        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)
        try Data().write(to: fileURL)

        let expectation = expectation(description: "File is deleted")
        // swiftlint:disable:next trailing_closure
        var temporaryFile: TemporaryFile? = TemporaryFile(fileURL: fileURL, logHandler: nil, didDeleteCallback: {
            XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path))
            expectation.fulfill()
        })

        _ = temporaryFile // To avoid warning "Variable 'temporaryFile' was written to, but never read"
        temporaryFile = nil

        waitForExpectations(timeout: 10)
    }

    func testStayAlive_doesntRemoveFileWhilstExecutingAction() throws {
        let fileManager = FileManager.default

        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)
        try Data().write(to: fileURL)

        let expectation = expectation(description: "stayAlive’s action is executed")
        TemporaryFile(fileURL: fileURL, logHandler: nil).stayAlive {
            XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
