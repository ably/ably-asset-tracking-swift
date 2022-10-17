import UIKit
import MapKit

class TruckAnnotation: MKPointAnnotation, Annotatable {
    var type: AnnotationType = .enhanced
    var bearing: Double = 0
}
