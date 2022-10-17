import Foundation
import MapKit

class HorizontalAccuracyAnnotation: MKPointAnnotation, Annotatable {
    var type: AnnotationType = .enhanced
    var accuracy: Double = .zero
}
