import AblyAssetTrackingCore
import SwiftUI

struct AddTrackableView: View {
    @ObservedObject var publisher: ObservablePublisher

    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var locationManager = LocationManager.shared
    @State private var error: ErrorInformation?
    @State private var showAlert = false
    @State private var isAdding = false
    @State private var hasAdded = false
    @StateObject private var viewModel = AddTrackableViewModel()
    @State var showDefaultAccuracies = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section(header: Text("Trackable ID")) {
                    TextField("Trackable ID", text: $viewModel.trackableId)
                        .disabled(locationManager.isLocationAuthorizationDenied)
                }
                Section(header: Text("Destination")) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("Lat: \(viewModel.getLatitudeString())").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Long: \(viewModel.getLongitudeString())").frame(maxWidth: .infinity, alignment: .leading)
                    }
                    NavigationLink {
                        SelectDestinationView(destination: $viewModel.destination)
                    } label: {
                        Text("Select destination")
                    }
                }
                Section {
                    Toggle(isOn: $viewModel.setResolutionConstraints) {
                        Text("Set resolution constraints")
                    }

                    if viewModel.setResolutionConstraints {
                        TitleValueListItem(title: "Accuracy", value: viewModel.resolutionAccuracy)
                            .onTapGesture {
                                self.showDefaultAccuracies = true
                            }
                            .actionSheet(isPresented: $showDefaultAccuracies) {
                                var buttons: [Alert.Button] = viewModel.accuracies.map { accuracy in
                                    Alert.Button.default(Text(accuracy.lowercased())) {
                                        viewModel.resolutionAccuracy = accuracy
                                    }
                                }
                                buttons.append(.cancel())
                                return ActionSheet(
                                    title: Text("Default resolution accuracy"),
                                    message: Text("Select accuracy"),
                                    buttons: buttons
                                )
                            }
                        TitleTextFieldListItem(title: "Desired interval (ms)", value: $viewModel.resolutionDesiredInterval, placeholder: "value", keyboardType: .numberPad)
                        TitleTextFieldListItem(title: "Minimum displacement (meters)", value: $viewModel.resolutionMinimumDisplacement, placeholder: "value", keyboardType: .numberPad)
                    }
                } header: {
                    Text("Resolution constraints")
                }

                Section {
                    Button {
                        let trackable = viewModel.createTrackable()
                        isAdding = true
                        publisher.track(trackable: trackable) { result in
                            isAdding = false
                            switch result {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                                hasAdded = true
                            case .failure(let error):
                                self.error = error
                                showAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("Add trackable")
                                .padding(.trailing)
                            ProgressView()
                                .opacity(isAdding ? 1 : 0)
                        }
                    }
                    .disabled(!viewModel.isValid ||
                              locationManager.isLocationAuthorizationDenied ||
                              isAdding ||
                              hasAdded)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: "Failed to add trackable",
                            errorInformation: error
                        )
                    }
                }

                Section {
                    Text("Location permission status:")
                        .foregroundColor(.gray)
                        .font(.system(size: 10)) +
                    Text(locationManager.statusTitle)
                        .font(.system(size: 10))
                        .bold()
                    if locationManager.isLocationAuthorizationDenied {
                        Button("Open system preferences") {
                            guard
                                let settingsURL = URL(string: UIApplication.openSettingsURLString),
                                UIApplication.shared.canOpenURL(settingsURL)
                            else {
                                return
                            }

                            UIApplication.shared.open(settingsURL)
                        }
                        .font(.system(size: 10))
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
        }
        .navigationTitle("Add trackable")
    }
}

struct AddTrackableView_Previews: PreviewProvider {
    static var previews: some View {
        let publisher = ObservablePublisher(publisher: DummyPublisher(), configInfo: .init(areRawLocationsEnabled: false))
        NavigationView {
            AddTrackableView(publisher: publisher)
        }
    }
}
