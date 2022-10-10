class PreviewMapViewModel: MapViewModelProtocol {
    var isConnected = false
    
    var errorInfo: String? = nil
    
    var isDestinationAvailable = false
    
    var didChangeRoutingProfile = false
    
    // TODO
    
    var rawLocationsInfo: [StackedTextModel] = []
    
    var constantResolutionInfo: [StackedTextModel] = []
    
    var connectionStatusAndProfileInfo: [StackedTextModel] = []
    
    var resolutionInfo: [StackedTextModel] = []
    
    func connectPublisher(trackableId: String) {}
    
    func disconnectPublisher(_ completion: ((Result<Void, AblyAssetTrackingCore.ErrorInformation>) -> Void)?) {}
}
