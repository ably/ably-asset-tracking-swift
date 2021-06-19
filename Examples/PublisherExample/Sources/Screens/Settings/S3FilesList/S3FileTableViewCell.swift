import UIKit

class S3FileTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var fileNameLabel: UILabel!
    @IBOutlet private weak var fileSizeLabel: UILabel!
    
    // MARK: - Overridden
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: - Configuration
    func setup(_ file: S3File) {
        fileNameLabel.text = file.name
        fileSizeLabel.text = "Size: \(file.sizeDescription)"
    }
}
