//

import SwiftUI
import AblyAssetTrackingPublisher

struct CreatePublisherView: View {
    @StateObject private var viewModel = CreatePublisherViewModel()
    @State var showConstantAccuracies = false
    @State var showVehicleProfiles = false
    @State var showRoutingProfiles = false
    @State private var isShowingMainView = false
    @State private var publisher: ObservablePublisher?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-programmatic-navigation-in-swiftui
            NavigationLink(isActive: $isShowingMainView) {
                // This seems a bit dodgy, not really sure of the right way to pass data to the destination of a NavigationLink
                if let publisher = publisher {
                    MainView(publisher: publisher)
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
                    TitleValueListItem(title: "Routing profile", value: viewModel.routingProfile.description())
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
                                title: Text("Vehicle Profile"),
                                message: Text("Select vehicle profile"),
                                buttons: buttons
                            )
                        }
                } header: {
                    Text("Navigation Settings")
                }
                
                Section {
                    Button {
                        // This is a temporary workaround so that the keyboard is no longer present if we
                        // navigate back to this screen. We can remove it after the fix to #421 below.
                        UIApplication.endEditing(true)
                        
                        viewModel.save()
                        publisher = viewModel.createPublisher()
                        isShowingMainView = true
                    } label: {
                        Text("Create publisher")
                    }
                }
                
                Section {
                } header: {
                    HStack{
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
        CreatePublisherView()
    }
}
