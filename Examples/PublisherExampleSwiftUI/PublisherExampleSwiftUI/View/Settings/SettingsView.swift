//

import SwiftUI

struct SettingsView<ViewModel: SettingsViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var showAccuracies = false

    var body: some View {
        List {
            Section {
                TitleValueListItem(title: "Desired Accuracy", value: viewModel.accuracy)
                    .onTapGesture {
                        self.showAccuracies = true
                    }
                    .disabled(!viewModel.isConstantResolutionEnabled)
                TitleTextFieldListItem(title: "Min Displacement (meters)", value: $viewModel.minimumDisplacement, placeholder: "value", keyboardType: .numberPad)
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
        }
        .actionSheet(isPresented: $showAccuracies) {
            var buttons: [Alert.Button] = viewModel.accuracies.map { accuracy in
                Alert.Button.default(Text(accuracy.lowercased())) {
                    viewModel.accuracy = accuracy
                }
            }
            
            buttons.append(.cancel())
            
            return ActionSheet(
                title: Text("Desired accuracy"),
                message: Text("Select accuracy"),
                buttons: buttons
            )
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
        SettingsView(viewModel: SettingsViewModel())
    }
}
