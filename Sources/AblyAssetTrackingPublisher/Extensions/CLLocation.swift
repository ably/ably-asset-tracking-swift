//
//  Created by Łukasz Szyszkowski on 01/09/2021.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func toCLLocation() -> CLLocation? {
        guard CLLocationCoordinate2DIsValid(self) else {
            return nil
        }
        
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
