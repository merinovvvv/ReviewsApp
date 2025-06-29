import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Имя пользователя
    let username: NSAttributedString
    /// Рейтинг
    let rating: Int
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    private static var sizingCell: ReviewCell?
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.configure(with: self)
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Private

private extension ReviewCellConfig {
    
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    fileprivate var config: Config?
    private var currentConfigId: UUID?
    
    //MARK: Private. UI Properties
    fileprivate let userStack = UIStackView()
    fileprivate let usernameAndRatingStack = UIStackView()
    fileprivate let textStack = UIStackView()
    fileprivate let textAndEmptyStack = UIStackView()
    fileprivate let cellStack = UIStackView()
    
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate var ratingImageView = UIImageView()
    fileprivate var emptyView = UIView()
    
    
    //MARK: Private. Constants
    private enum Constants {
        // MARK: - Размеры
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
        static let avatarCornerRadius = 18.0
        static let photoCornerRadius = 8.0
        
        static let photoSize = CGSize(width: 55.0, height: 66.0)
        static let showMoreButtonSize = Config.showMoreText.size()
        
        static let usernameLabelFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        static let ratingImageViewSize = CGSize(width: 84.0, height: 16.0)
        
        static let createdLabelFont = UIFont.systemFont(ofSize: 14)
        
        // MARK: - Отступы
        static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
        
        /// Горизонтальный отступ от аватара до имени пользователя.
        static let avatarToUsernameSpacing = 10.0
        /// Вертикальный отступ от имени пользователя до вью рейтинга.
        static let usernameToRatingSpacing = 6.0
        /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
        static let ratingToTextSpacing = 6.0
        /// Вертикальный отступ от вью рейтинга до фото.
        static let ratingToPhotosSpacing = 10.0
        /// Горизонтальные отступы между фото.
        static let photosSpacing = 8.0
        /// Вертикальный отступ от фото (если они есть) до текста отзыва.
        static let photosToTextSpacing = 10.0
        /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
        static let reviewTextToCreatedSpacing = 6.0
        /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
        static let showMoreToCreatedSpacing = 6.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func configure(with config: ReviewCellConfig) {
        
        guard currentConfigId != config.id else { return }
        
        self.config = config
        currentConfigId = config.id
        reviewTextLabel.attributedText = config.reviewText
        reviewTextLabel.numberOfLines = config.maxLines
        createdLabel.attributedText = config.created
        usernameLabel.attributedText = config.username

        let renderer = RatingRenderer()
        ratingImageView.image = renderer.ratingImage(config.rating)

        avatarImageView.image = UIImage(named: "l5w5aIHioYc")
        
        configureShowMoreButton()
    }
    
    private func configureShowMoreButton() {
        guard let config = config else { return }
        
        let isTextTruncated = isTextTruncated(for: reviewTextLabel, with: config.reviewText)
        
        if isTextTruncated && config.maxLines > 0 {
            showMoreButton.isHidden = false
            addShowMoreButtonIfNeeded()
        } else {
            showMoreButton.isHidden = true
            removeShowMoreButtonIfNeeded()
        }
    }
    
    private func isTextTruncated(for label: UILabel, with attributedText: NSAttributedString) -> Bool {
        guard label.numberOfLines > 0 else { return false }
        
        let labelSize = label.bounds.size
        let textSize = attributedText.boundingRect(
            with: CGSize(width: labelSize.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        let lineHeight = label.font.lineHeight
        let maxHeight = lineHeight * CGFloat(label.numberOfLines)
        
        return textSize.height > maxHeight
    }

    private func addShowMoreButtonIfNeeded() {
        if !textStack.arrangedSubviews.contains(showMoreButton) {
            textStack.insertArrangedSubview(showMoreButton, at: textStack.arrangedSubviews.count - 1)
        }
    }

    private func removeShowMoreButtonIfNeeded() {
        if textStack.arrangedSubviews.contains(showMoreButton) {
            textStack.removeArrangedSubview(showMoreButton)
            showMoreButton.removeFromSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        reviewTextLabel.attributedText = nil
        reviewTextLabel.text = nil
        reviewTextLabel.numberOfLines = 0

        createdLabel.attributedText = nil
        createdLabel.text = nil

        usernameLabel.attributedText = nil
        usernameLabel.text = nil

        ratingImageView.image = nil
        avatarImageView.image = nil

        showMoreButton.isHidden = true
        removeShowMoreButtonIfNeeded()

        config = nil
        currentConfigId = nil
    }
    
}

// MARK: - Private. Setup UI

private extension ReviewCell {
    
    func setupCell() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        contentView.addSubview(cellStack)
        
        cellStack.addArrangedSubview(userStack)
        cellStack.addArrangedSubview(textAndEmptyStack)
        
        userStack.addArrangedSubview(avatarImageView)
        userStack.addArrangedSubview(usernameAndRatingStack)
        
        usernameAndRatingStack.addArrangedSubview(usernameLabel)
        usernameAndRatingStack.addArrangedSubview(ratingImageView)
        
        textAndEmptyStack.addArrangedSubview(emptyView)
        textAndEmptyStack.addArrangedSubview(textStack)
        
        textStack.addArrangedSubview(reviewTextLabel)
        textStack.addArrangedSubview(createdLabel)
    }
    
    func configureViews() {
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Constants.avatarCornerRadius
        avatarImageView.clipsToBounds = true
        
        
        usernameLabel.font = Constants.usernameLabelFont
        usernameLabel.numberOfLines = 1
        
        createdLabel.textColor = .gray
        createdLabel.font = Constants.createdLabelFont
        
        reviewTextLabel.numberOfLines = 0 // Будет переопределено в configure
        reviewTextLabel.lineBreakMode = .byWordWrapping
        
        ratingImageView.contentMode = .left
          
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.isHidden = true
        showMoreButton.addTarget(self, action: #selector(showMoreButtonTapped), for: .touchUpInside)
        
        cellStack.axis = .vertical
        cellStack.spacing = Constants.ratingToTextSpacing
        cellStack.alignment = .fill
        
        userStack.axis = .horizontal
        userStack.spacing = Constants.avatarToUsernameSpacing
        userStack.alignment = .center
        
        usernameAndRatingStack.axis = .vertical
        usernameAndRatingStack.spacing = Constants.usernameToRatingSpacing
        usernameAndRatingStack.alignment = .leading
        
        textAndEmptyStack.axis = .horizontal
        textAndEmptyStack.spacing = Constants.avatarToUsernameSpacing
        textAndEmptyStack.alignment = .top
        
        textStack.axis = .vertical
        textStack.spacing = Constants.reviewTextToCreatedSpacing
        textStack.alignment = .leading
        
        setupContentPriorities()
    }
    
    @objc private func showMoreButtonTapped() {
        guard let config = config, let configId = currentConfigId else { return }
        config.onTapShowMore(configId)
    }
    
    func setupContentPriorities() {
        usernameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        createdLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        reviewTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        ratingImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        usernameLabel.setContentHuggingPriority(.required, for: .vertical)
        createdLabel.setContentHuggingPriority(.required, for: .vertical)
        ratingImageView.setContentHuggingPriority(.required, for: .vertical)
        reviewTextLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        ratingImageView.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setupConstraints() {
        [cellStack, userStack, usernameAndRatingStack, textAndEmptyStack, textStack,
         avatarImageView, usernameLabel, ratingImageView, reviewTextLabel, createdLabel, emptyView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height),
            
            ratingImageView.heightAnchor.constraint(equalToConstant: Constants.ratingImageViewSize.height),
            ratingImageView.widthAnchor.constraint(equalToConstant: Constants.ratingImageViewSize.width),
            
            emptyView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width),
            
            reviewTextLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            reviewTextLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
            
            cellStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.insets.left),
            cellStack.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: Constants.insets.top),
            cellStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -Constants.insets.right),
            cellStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -Constants.insets.bottom)
        ])
    }
}


// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
