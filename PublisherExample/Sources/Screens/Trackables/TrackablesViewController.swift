import AblyAssetTracking
import UIKit

protocol TrackablesViewControllerDelegate: AnyObject {
    func trackablesViewController(sender: TrackablesViewController, didAddTrackable trackable: Trackable)
    func trackablesViewController(sender: TrackablesViewController, didRemoveTrackable trackable: Trackable)
}

class TrackablesViewController: UIViewController {
    private let cellIdentifier = "TrackablesTableViewCellIdentifier"
    private var trackables: [Trackable]
    @IBOutlet private weak var tableView: UITableView!

    weak var delegate: TrackablesViewControllerDelegate?

    // MARK: Initialization
    init(trackables: [Trackable]) {
        self.trackables = trackables
        let viewControllerType = TrackablesViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "TrackablesTableViewCell", bundle: .main), forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
    }
}

extension TrackablesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackables.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TrackablesTableViewCell
        else { return UITableViewCell() }
        let trackable = trackables[indexPath.row]
        cell.setup(withTrackable: trackable)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let trackable = trackables.remove(at: indexPath.row)
        tableView.reloadData()
        delegate?.trackablesViewController(sender: self, didRemoveTrackable: trackable)
    }
}
