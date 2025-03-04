import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()

    private lazy var activityIndicator: ReviewsActivityIndicator = {
        let spinner = ReviewsActivityIndicator(squareLength: 70)
        return spinner
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshReviews), for: .valueChanged)
        return control
    }()
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
        view.addSubview(activityIndicator)

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

    // Обновляем обработчик состояния
    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            if !state.isRefreshing && !state.isInitialLoading {
                reviewsView.tableView.reloadData()
            }

            if state.isInitialLoading {
                activityIndicator.startAnimation(delay: 0.04, replicates: 20)
            } else {
                activityIndicator.stopAnimation()
            }

            if state.isRefreshing {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }

    private func setupRefreshControl() {
        reviewsView.tableView.refreshControl = refreshControl
    }

    @objc private func refreshReviews() {
        viewModel.refreshReviews()
    }

    private func makeActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }

}
