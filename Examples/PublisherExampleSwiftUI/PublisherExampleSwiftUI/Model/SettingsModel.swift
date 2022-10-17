import Foundation
import AblyAssetTrackingPublisher

class SettingsModel {
    static let shared = SettingsModel()
    
    private let fallbackResolution = Resolution(
        accuracy: .balanced,
        desiredInterval: 2000.0,
        minimumDisplacement: 100.0
    )
    
    private let fallbackVehicleProfile = VehicleProfile.car
    private let fallbackRoutingProfile = RoutingProfile.driving
    
    var areRawLocationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "areRawLocationsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "areRawLocationsEnabled")
        }
    }
    
    var isConstantResolutionEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isConstantResolutionEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isConstantResolutionEnabled")
        }
    }
    
    var constantResolution: Resolution {
        get {
            guard let resolution: Resolution = UserDefaults.standard.get("constantResolution") else {
                return fallbackResolution
            }
            
            return resolution
        }
        set {
            UserDefaults.standard.save(newValue, forKey: "constantResolution")
        }
    }
    
    var defaultResolution: Resolution {
        get {
            guard let resolution: Resolution = UserDefaults.standard.get("defaultResolution") else {
                return fallbackResolution
            }
            
            return resolution
        }
        set {
            UserDefaults.standard.save(newValue, forKey: "defaultResolution")
        }
    }
    
    var vehicleProfile: VehicleProfile {
        get {
            guard let profile: VehicleProfile = UserDefaults.standard.get("vehicleProfile") else {
                return fallbackVehicleProfile
            }
            
            return profile
        }
        set {
            UserDefaults.standard.save(newValue, forKey: "vehicleProfile")
        }
    }
    
    var routingProfile: RoutingProfile {
        get {
            guard let profileRawValue: Int = UserDefaults.standard.get("routingProfile"),
                  let profile = RoutingProfile.init(rawValue: profileRawValue)
            else {
                return fallbackRoutingProfile
            }
            
            return profile
        }
        set {
            UserDefaults.standard.save(newValue.rawValue, forKey: "routingProfile")
        }
    }
    
    private init() {}
}

