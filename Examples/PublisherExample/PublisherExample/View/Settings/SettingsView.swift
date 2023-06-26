import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State var showDefaultAccuracies = false
    var uploads: [Upload]
    var retry: (Upload) -> Void

    var body: some View {
        List {
            Section {
                TitleValueListItem(title: "Accuracy", value: viewModel.defaultResolutionAccuracy)
                    .onTapGesture {
                        self.showDefaultAccuracies = true
                    }
                    .actionSheet(isPresented: $showDefaultAccuracies) {
                        var buttons: [Alert.Button] = viewModel.accuracies.map { accuracy in
                            Alert.Button.default(Text(accuracy.lowercased())) {
                                viewModel.defaultResolutionAccuracy = accuracy
                            }
                        }
                        buttons.append(.cancel())
                        return ActionSheet(
                            title: Text("Default resolution accuracy"),
                            message: Text("Select accuracy"),
                            buttons: buttons
                        )
                    }
                TitleTextFieldListItem(title: "Desired interval (ms)", value: $viewModel.defaultResolutionDesiredInterval, placeholder: "value", keyboardType: .numberPad)
                TitleTextFieldListItem(title: "Minimum displacement (meters)", value: $viewModel.defaultResolutionMinimumDisplacement, placeholder: "value", keyboardType: .numberPad)
            } header: {
                Text("Default resolution when setting resolution constraints")
            }

            Section {
                Toggle(isOn: $viewModel.useMapboxMap) {
                    Text("Use Mapbox map")
                }

                NavigationLink("Uploads") {
                    // swiftlint:disable:next trailing_closure
                    UploadsView(uploads: uploads, retry: { upload in
                        retry(upload)
                    })
                }
            } header: {
                Text("Other settings")
            }

            Section {
                Toggle(isOn: $viewModel.logLocationHistoryJSON) {
                    Text("Log location history JSON")
                    Text("Causes the app to emit a `debug` level log message when a `LocationHistoryData` is received from the Asset Tracking SDK. The log message will contain a JSON serialization of this history data.")
                }
            } header: {
                Text("Developer settings")
            }
        }
        .listStyle(.grouped)
        .navigationBarTitle("Settings")
        // Had to remove this because it stops the "Create publisher" button from doing anything.
        // See https://github.com/ably/ably-asset-tracking-swift/issues/421
        // .resignKeyboardOnTapGesture()
        .onDisappear {
            viewModel.save()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let upload = Upload(id: UUID(), request: .init(type: .locationHistoryData(archiveVersion: ""), generatedAt: Date()), status: .uploading)
        SettingsView(uploads: [upload]) { _ in }
    }
}
