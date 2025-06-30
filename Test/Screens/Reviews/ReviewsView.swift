import UIKit

final class ReviewsView: UIView {
    
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
    }
    
}

// MARK: - Private

private extension ReviewsView {
    
    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        refreshControl.tintColor = .systemGray
        tableView.refreshControl = refreshControl
        
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(TotalReviewsCell.self, forCellReuseIdentifier: TotalReviewsCellConfig.reuseId)
    }
}
