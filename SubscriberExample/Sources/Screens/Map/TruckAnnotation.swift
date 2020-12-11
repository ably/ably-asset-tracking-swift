import UIKit
import MapKit

enum TruckAnnotationType {
    case raw
    case enhanced
}

class TruckAnnotation: MKPointAnnotation {
    var bearing: Double = 0
    var type: TruckAnnotationType = .raw
}
