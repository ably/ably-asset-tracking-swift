/// A dummy implementation of ViewModelFactoryProtocol for use in Xcode view previews.
class PreviewViewModelFactory: ViewModelFactoryProtocol {
    func createSettingsViewModel() -> PreviewSettingsViewModel {
        return PreviewSettingsViewModel()
    }
}
