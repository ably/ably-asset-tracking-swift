import UIKit

class S3FilesListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    private let awsS3Service: S3Service
    private let selectionHandler: (S3File) -> Void
    
    private let cellIdentifier = "S3FileTableViewCell"
    private var dataSource = [S3File]()
    
    // MARK: - Initialization
    init(awsS3Service: S3Service, selectionHandler: @escaping (S3File) -> Void) {
        self.awsS3Service = awsS3Service
        self.selectionHandler = selectionHandler
        let viewControllerType = S3FilesListViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        title = "S3 Files"
        super.viewDidLoad()
        self.setActivityIndicatorState(false)
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: .main), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Private
    private func loadData() {
        self.setActivityIndicatorState(true)
        awsS3Service.getFilesList { [weak self] result in
            self?.setActivityIndicatorState(false)
            switch result {
            case .success(let list):
                self?.dataSource = list
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.showErrorDialog(for: error)
            }
        }
    }
    
    private func setActivityIndicatorState(_ isLoading: Bool) {
        DispatchQueue.main.async {
            isLoading
                ? self.activityIndicator.startAnimating()
                : self.activityIndicator.stopAnimating()
        }
    }
    
    private func showErrorDialog(for error: S3Error) {
        let alertController = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate extension
extension S3FilesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = dataSource[indexPath.row]
        selectionHandler(selectedFile)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource extension
extension S3FilesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? S3FileTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(dataSource[indexPath.row])
        
        return cell
    }
}
