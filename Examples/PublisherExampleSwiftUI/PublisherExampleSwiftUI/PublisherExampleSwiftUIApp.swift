import SwiftUI
import Logging
import LoggingFormatAndPipe

@main
struct PublisherExampleSwiftUIApp: App {
    @State private var logger: Logger
    @State private var s3Helper: S3Helper?
    @StateObject private var uploadsManager: UploadsManager
    @State private var locationHistoryDataHandler: LocationHistoryDataHandlerProtocol

    init() {
        let logger = Logger(label: "com.ably.PublisherExampleSwiftUI") { _ in
            // Format logged timestamps as an ISO 8601 timestamp with fractional seconds.
            // Unfortunately BasicFormatter doesn’t allow us to pass an ISO8601DateFormatter,
            // so we fall back to following https://developer.apple.com/library/archive/qa/qa1480/_index.html
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSSZZZZZ"
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            let formatter = BasicFormatter(BasicFormatter.apple.format, timestampFormatter: dateFormatter)

            var handler = LoggingFormatAndPipe.Handler(
                formatter: formatter,
                pipe: LoggerTextOutputStreamPipe.standardError
            )

            handler.logLevel = .info

            return handler
        }

        self._logger = State(wrappedValue: logger)

        let s3Helper = try? S3Helper()
        self._s3Helper = State(wrappedValue: s3Helper)

        let uploadsManager = UploadsManager(s3Helper: s3Helper, logger: logger)
        _uploadsManager = StateObject(wrappedValue: uploadsManager)

        self._locationHistoryDataHandler = State(wrappedValue: LocationHistoryDataUploader(uploadsManager: uploadsManager))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    CreatePublisherView(logger: logger, s3Helper: s3Helper, locationHistoryDataHandler: locationHistoryDataHandler)
                }
                .tabItem {
                    Label("Publisher", systemImage: "car")
                }
                /*
                This navigationViewStyle(.stack) prevents UINavigationBar-related "Unable to
                simultaneously satisfy constraints" log messages on iPhone simulators with iOS
                < 16 (specifically I saw it with 15.5).  I don’t know what caused this issue
                nor why this fixes it; it's just something I tried after seeing vaguely similar
                complaints on the Web, and it seems to do no harm.
                */
                .navigationViewStyle(.stack)
                NavigationView {
                    SettingsView(uploads: uploadsManager.uploads, retry: { upload in
                        uploadsManager.retry(upload)
                    })
                }
                // Same comment as above
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
