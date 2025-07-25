import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
    
}

// MARK: - Internal

extension ReviewsViewModel {
    
    typealias State = ReviewsViewModelState
    
    /// Метод получения отзывов (сетевая часть в фоне, UI на главном потоке)
    func getReviews() {
        guard state.shouldLoad else {
            onStateChange?(state)
            return
        }
        state.shouldLoad = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.reviewsProvider.getReviews(offset: self?.state.offset ?? 0) { [weak self] result in
                DispatchQueue.main.async {
                    self?.gotReviews(result)
                }
            }
        }
    }
    
    func refreshReviews() {
        state.offset = 0
        state.shouldLoad = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.reviewsProvider.getReviews(offset: 0) { [weak self] result in
                DispatchQueue.main.async {
                    self?.state.items.removeAll()
                    self?.gotReviews(result)
                }
            }
        }
    }
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            
            if !state.shouldLoad {
                let lastItem = makeLastItem(reviews)
                state.items.append(lastItem)
            }
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }
    
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }
    
}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    typealias ReviewsItem = TotalReviewsCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let username: NSAttributedString = {
            let firstName = review.first_name.attributed(font: .username)
            let lastName = review.last_name.attributed(font: .username)
            
            let fullName = NSMutableAttributedString()
            fullName.append(firstName)
            fullName.append(NSAttributedString(string: " "))
            fullName.append(lastName)
            
            return fullName
        }()
        let rating = review.rating
        let created = review.created.attributed(font: .created, color: .created)
        let photo_urls = review.photo_urls
        let item = ReviewItem(
            reviewText: reviewText,
            username: username,
            rating: rating,
            created: created,
            photo_urls: photo_urls,
            onTapShowMore: showMoreReview
        )
        return item
    }
    
    func makeLastItem(_ reviews: Reviews) -> ReviewsItem {
        let count = reviews.count
        let item = ReviewsItem(reviewCount: count)
        return item
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }
    
    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
    
}
