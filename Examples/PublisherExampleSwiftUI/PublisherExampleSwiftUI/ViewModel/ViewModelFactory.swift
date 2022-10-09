protocol ViewModelFactoryProtocol {
    associatedtype SettingsViewModel: SettingsViewModelProtocol
    
    func createSettingsViewModel() -> SettingsViewModel
}

class ViewModelFactory: ViewModelFactoryProtocol {
    func createSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }
}
