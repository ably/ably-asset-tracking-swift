import Foundation
import MapKit

class HorizontalAccuracyAnnotationView: MKAnnotationView, Identifiable {
    static var identifier = "MapHorizontalAccuracyAnnotationIdentifier"
    
    private var scaleFactor: Double = 0.1
    
    var accuracy: Double = .zero {
        didSet {
            updateRadius(radius: accuracy)
        }
    }
    
    private var circleView = UIView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        circleView.layer.masksToBounds = false
        circleView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        circleView.layer.borderWidth = 2.0
        circleView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        
        addSubview(circleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) has not been implemented yet")
    }
    
    private func updateRadius(radius: CGFloat) {
        circleView.isHidden = radius <= .zero
        circleView.frame.size = CGSize(width: radius * 2, height: radius * 2)
        circleView.frame.origin = CGPoint(x: -radius, y: -radius)
        circleView.layer.cornerRadius = radius
    }
}
