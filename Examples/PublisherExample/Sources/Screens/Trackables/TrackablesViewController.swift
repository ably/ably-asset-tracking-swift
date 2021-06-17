import AblyAssetTrackingPublisher
import UIKit

protocol TrackablesViewControllerDelegate: AnyObject {
    func trackablesViewController(sender: TrackablesViewController, didAddTrackable trackable: Trackable)
    func trackablesViewController(sender: TrackablesViewController, didRemoveTrackable trackable: Trackable, wasPresent: Bool)
    func trackablesViewController(sender: TrackablesViewController, didRemoveLastTrackable trackable: Trackable)
}

class TrackablesViewController: UIViewController {
    private let cellIdentifier = "TrackablesTableViewCellIdentifier"
    private var trackables: [Trackable]
    private let publisher: Publisher?
    @IBOutlet private weak var tableView: UITableView!

    weak var delegate: TrackablesViewControllerDelegate?

    // MARK: Initialization
    init(trackables: [Trackable], publisher: Publisher?) {
        self.trackables = trackables
        self.publisher = publisher
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
        setupNavigationBar()
    }

    // MARK: View setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "TrackablesTableViewCell", bundle: .main), forCellReuseIdentifier: cellIdentifier)
        tableView.reloadData()
    }

    private func setupNavigationBar() {
        title = "Trackables"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTrackableButtonPress))
    }

    // MARK: Actions
    @objc
    private func onAddTrackableButtonPress() {
        let viewController = AddTrackableViewController(publisher: publisher)
        viewController.delegate = self
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: Private
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Alert", message: (error as? ErrorInformation)?.message ?? error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        
        let trackableToRemove = trackables[indexPath.row]
        
        publisher?.remove(trackable: trackableToRemove) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let wasPresent):
                let trackable = self.trackables.remove(at: indexPath.row)
                self.tableView.reloadData()
                self.delegate?.trackablesViewController(sender: self, didRemoveTrackable: trackable, wasPresent: wasPresent)
                
                if self.trackables.isEmpty {
                    self.delegate?.trackablesViewController(sender: self, didRemoveLastTrackable: trackable)
                }
            case .failure(let error):
                self.showError(error)
            }
        }
    }
}

extension TrackablesViewController: AddTrackableViewControllerDelegate {
    func addTrackableViewController(sender: AddTrackableViewController, onTrackableAdded trackable: Trackable) {
        trackables.append(trackable)
        tableView.reloadData()
        delegate?.trackablesViewController(sender: self, didAddTrackable: trackable)
    }
}
