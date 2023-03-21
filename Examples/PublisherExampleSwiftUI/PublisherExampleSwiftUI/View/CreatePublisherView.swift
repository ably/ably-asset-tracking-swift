//

import AblyAssetTrackingPublisher
import Logging
import SwiftUI

struct CreatePublisherView: View {
    @StateObject private var viewModel: CreatePublisherViewModel
    @State var showConstantAccuracies = false
    @State var showVehicleProfiles = false
    @State var showRoutingProfiles = false
    @State var showLocationSources = false
    @State var showS3Files = false
    @State private var isShowingPublisherDetailsView = false
    @State private var publisher: ObservablePublisher?
    @State private var isCreatingPublisher = false
    @State private var error: ErrorInformation?
    @State private var showAlert = false
    @Environment(\.colorScheme) var colorScheme

    private var s3Helper: S3Helper?

    init(logger: Logger, s3Helper: S3Helper? = nil, locationHistoryDataHandler: LocationHistoryDataHandlerProtocol? = nil) {
        self.s3Helper = s3Helper
        _viewModel = StateObject(wrappedValue: CreatePublisherViewModel(logger: logger, s3Helper: s3Helper, locationHistoryDataHandler: locationHistoryDataHandler))
    }

    var body: some View {
        VStack {
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-programmatic-navigation-in-swiftui
            // swiftlint:disable:next multiline_arguments
            NavigationLink(isActive: $isShowingPublisherDetailsView) {
                // This seems a bit dodgy, not really sure of the right way to pass data to the destination of a NavigationLink
                if let publisher {
                    PublisherDetailsView(publisher: publisher)
                } else {
                    EmptyView()
                }
            } label: {
                EmptyView()
            }

            List {
                Section {
                    TitleValueListItem(title: "Desired Accuracy", value: viewModel.constantResolutionAccuracy)
                        .onTapGesture {
                            self.showConstantAccuracies = true
                        }
                        .disabled(!viewModel.isConstantResolutionEnabled)
                        .actionSheet(isPresented: $showConstantAccuracies) {
                            var buttons: [Alert.Button] = viewModel.accuracies.map { accuracy in
                                Alert.Button.default(Text(accuracy.lowercased())) {
                                    viewModel.constantResolutionAccuracy = accuracy
                                }
                            }
                            buttons.append(.cancel())
                            return ActionSheet(
                                title: Text("Desired constant resolution accuracy"),
                                message: Text("Select accuracy"),
                                buttons: buttons
                            )
                        }
                    TitleTextFieldListItem(title: "Min Displacement (meters)", value: $viewModel.constantResolutionMinimumDisplacement, placeholder: "value", keyboardType: .numberPad)
                        .disabled(!viewModel.isConstantResolutionEnabled)
                } header: {
                    HStack {
                        Text("Constant Resolution")
                        Toggle(isOn: $viewModel.isConstantResolutionEnabled) {}
                    }
                }

                Section {
                    Toggle(isOn: $viewModel.areRawLocationsEnabled) {
                        Text("Raw locations enabled")
                    }
                } header: {
                    Text("Other settings")
                }

                Section {
                    TitleValueListItem(title: "Location Source", value: viewModel.locationSource.description())
                        .onTapGesture {
                            self.showLocationSources = true
                        }
                        .actionSheet(isPresented: $showLocationSources) {
                            var buttons: [Alert.Button] = viewModel.locationSources.map { source in
                                Alert.Button.default(Text(source)) {
                                    viewModel.locationSource = LocationSourceOption.fromDescription(description: source)
                                }
                            }
                            buttons.append(.cancel())
                            return ActionSheet(
                                title: Text("Location Source"),
                                message: Text("Select location source"),
                                buttons: buttons
                            )
                        }
                    if viewModel.locationSource == .s3File {
                        TitleValueListItem(title: "S3 File", value: viewModel.s3FileName ?? "")
                            .onTapGesture {
                                self.showS3Files = true
                            }
                            .sheet(isPresented: $showS3Files) {
                                S3FilesView(s3Helper: s3Helper, fileName: $viewModel.s3FileName)
                            }
                    }
                    TitleValueListItem(title: "Vehicle Profile", value: viewModel.vehicleProfile.description())
                        .onTapGesture {
                            self.showVehicleProfiles = true
                        }
                        .actionSheet(isPresented: $showVehicleProfiles) {
                            var buttons: [Alert.Button] = viewModel.vehicleProfiles.map { profile in
                                Alert.Button.default(Text(profile)) {
                                    viewModel.vehicleProfile = VehicleProfile.fromDescription(description: profile)
                                }
                            }
                            buttons.append(.cancel())
                            return ActionSheet(
                                title: Text("Vehicle Profile"),
                                message: Text("Select vehicle profile"),
                                buttons: buttons
                            )
                        }
                    TitleValueListItem(title: "Routing Profile", value: viewModel.routingProfile.description())
                        .onTapGesture {
                            self.showRoutingProfiles = true
                        }
                        .actionSheet(isPresented: $showRoutingProfiles) {
                            var buttons: [Alert.Button] = viewModel.routingProfiles.map { profile in
                                Alert.Button.default(Text(profile)) {
                                    viewModel.routingProfile = RoutingProfile.fromDescription(description: profile)
                                }
                            }
                            buttons.append(.cancel())
                            return ActionSheet(
                                title: Text("Routing Profile"),
                                message: Text("Select routing profile"),
                                buttons: buttons
                            )
                        }
                } header: {
                    Text("Navigation Settings")
                }

                Section {
                    Button {
                        isCreatingPublisher = true
                        // This is a temporary workaround so that the keyboard is no longer present if we
                        // navigate back to this screen. We can remove it after the fix to #421 below.
                        UIApplication.endEditing(true)

                        viewModel.save()
                        Task {
                            do {
                                publisher = try await viewModel.createPublisher()
                                isShowingPublisherDetailsView = true
                            } catch {
                                self.error = .init(error: error)
                                showAlert = true
                            }
                            isCreatingPublisher = false
                        }
                    } label: {
                        HStack {
                            Text("Create publisher")
                                .padding(.trailing)
                            ProgressView()
                                .opacity(isCreatingPublisher ? 1 : 0)
                        }
                    }
                    .disabled(isCreatingPublisher)
                    .alert(isPresented: $showAlert) {
                        .init(title: "Failed to create publisher", errorInformation: error)
                    }
                }

                Section {
                } header: {
                    HStack {
                        Spacer()
                        Image("ably-logo", bundle: nil)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 100
                            )
                            .padding()
                            .background(
                                Color(UIColor.white)
                                    .opacity(colorScheme == .dark ? 1 : 0)
                            )
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle("Create publisher")
            // Had to remove this because it stops the "Create publisher" button from doing anything.
            // See https://github.com/ably/ably-asset-tracking-swift/issues/421
            // .resignKeyboardOnTapGesture()
        }
    }
}

struct CreatePublisherView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePublisherView(logger: Logger(label: ""))
    }
}
