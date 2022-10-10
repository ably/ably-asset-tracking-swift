protocol ViewModelFactoryProtocol {
    associatedtype SettingsViewModel: SettingsViewModelProtocol
    associatedtype MapViewModel: MapViewModelProtocol
    
    func createSettingsViewModel() -> SettingsViewModel
    func createMapViewModel() -> MapViewModel
}

class ViewModelFactory: ViewModelFactoryProtocol {
    func createSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }
    
    func createMapViewModel() -> MapViewModel {
        return MapViewModel()
    }
}
