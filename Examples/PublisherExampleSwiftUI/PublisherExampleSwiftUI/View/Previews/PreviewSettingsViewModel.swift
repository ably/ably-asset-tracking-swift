/// A dummy implementation of SettingsViewModelProtocol for use in Xcode view previews.
class PreviewSettingsViewModel: SettingsViewModelProtocol {
    var areRawLocationsEnabled = true
    var isConstantResolutionEnabled = true
    var minimumDisplacement = "10"
    var accuracy = "MINIMUM"
    
    func save() {}
}
