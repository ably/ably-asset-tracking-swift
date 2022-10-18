//

import SwiftUI
import AblyAssetTrackingPublisher

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State var showConstantAccuracies = false
    @State var showDefaultAccuracies = false
    @State var showVehicleProfiles = false
    @State var showRoutingProfiles = false
    
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
                Text("Default resolution")
            }
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
                TitleValueListItem(title: "Routing profile", value: viewModel.getRoutingProfileDescription(routingProfile: viewModel.routingProfile))
                    .onTapGesture {
                        self.showRoutingProfiles = true
                    }
                    .actionSheet(isPresented: $showRoutingProfiles) {
                        var buttons: [Alert.Button] = viewModel.routingProfiles.map { profile in
                            Alert.Button.default(Text(profile)) {
                                viewModel.routingProfile = viewModel.getRoutingProfileFromDescription(description: profile)
                            }
                        }
                        buttons.append(.cancel())
                        return ActionSheet(
                            title: Text("Vehicle Profile"),
                            message: Text("Select vehicle profile"),
                            buttons: buttons
                        )
                    }
            } header: {
                Text("Navigation Settings")
            }
            
            Section {
                Toggle(isOn: $viewModel.areRawLocationsEnabled) {
                    Text("Raw locations enabled")
                }
            } header: {
                Text("Other settings")
            }
        }
        .listStyle(.grouped)
        .navigationBarTitle("Settings")
        .resignKeyboardOnTapGesture()
        .onDisappear {
            viewModel.save()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
