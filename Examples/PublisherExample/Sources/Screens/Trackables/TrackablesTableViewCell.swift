import UIKit
import AblyAssetTrackingPublisher

class TrackablesTableViewCell: UITableViewCell {
    @IBOutlet private weak var trackableIdLabel: UILabel!
    @IBOutlet private weak var trackableDestinationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setup(withTrackable trackable: Trackable) {
        trackableIdLabel.text = trackable.id
        trackableDestinationLabel.text = nil
        if let destination = trackable.destination {
            trackableDestinationLabel.text = String(format: "%.5f %.5f", destination.latitude, destination.longitude)
        }
    }
}
