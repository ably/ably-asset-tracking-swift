import Foundation
import MapKit

class TruckAnnotationView: MKAnnotationView, Identifiable {
    static let identifier = "MapTruckAnnotationViewIdentifier"
    private let imageView: UIImageView

    var bearing: Double = 0 { didSet { updateImage() } }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        canShowCallout = false
        addSubview(imageView)
        updateImage()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateImage() {
        let step = 22.5
        switch bearing {
        case 360 - step..<360:
            imageView.image = UIImage(named: "truckN")
        case 0..<step:
            imageView.image = UIImage(named: "truckN")
        case 45 - step..<45 + step:
            imageView.image = UIImage(named: "truckNE")
        case 90 - step..<90 + step:
            imageView.image = UIImage(named: "truckE")
        case 135 - step..<135 + step:
            imageView.image = UIImage(named: "truckSE")
        case 180 - step..<180 + step:
            imageView.image = UIImage(named: "truckS")
        case 225 - step..<225 + step:
            imageView.image = UIImage(named: "truckSW")
        case 225 - step..<225 + step:
            imageView.image = UIImage(named: "truckW")
        case 315 - step..<315 + step:
            imageView.image = UIImage(named: "truckNW")
        default:
            break
        }

        if let annotation = annotation as? Annotatable, annotation.type == .raw {
            imageView.image = imageView.image?.withTintColor(.red)
            alpha = 0.3
        }
    }
}
