import UIKit

final class ReviewsViewController: UIViewController {
    
    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupRefreshControl()
        viewModel.getReviews()
    }
    
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    private func setupRefreshControl() {
        reviewsView.tableView.refreshControl?.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )
    }
    
    @objc private func handleRefresh() {
        viewModel.getReviews()
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] _ in
            DispatchQueue.main.async {
                if self?.reviewsView.tableView.refreshControl?.isRefreshing == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.reviewsView.tableView.refreshControl?.endRefreshing()
                    }
                }
                self?.reviewsView.tableView.reloadData()
            }
        }
    }
}
