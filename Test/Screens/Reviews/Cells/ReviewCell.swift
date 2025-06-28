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
    
    //TODO: как работает
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        let cell = ReviewCellConfig.sizingCell ?? ReviewCell(style: .default, reuseIdentifier: nil)
        ReviewCellConfig.sizingCell = cell
        
        // Настройка контента
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.usernameLabel.attributedText = username
        
        // Настройка рейтинга
        let renderer = RatingRenderer()
        cell.ratingImageView.image = renderer.ratingImage(rating)
        
        // Установка ширины для расчета
        cell.bounds = CGRect(x: 0, y: 0, width: size.width, height: .greatestFiniteMagnitude)
        
        // Принудительный расчет лейаута
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell.contentView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height.rounded(.up)
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
    
    //MARK: Private. UI Properties
    
    fileprivate let avatarStack = UIStackView()
    fileprivate let ratingStack = UIStackView()
    fileprivate let cellStack = UIStackView()
    
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate var ratingImageView = UIImageView()
    
    //MARK: Private. Constants
    private enum Constants {
        // MARK: - Размеры
        
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
        static let avatarCornerRadius = 18.0
        static let photoCornerRadius = 8.0
        
        static let usernameLabelFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        static let photoSize = CGSize(width: 55.0, height: 66.0)
        static let showMoreButtonSize = Config.showMoreText.size()
        
        static let ratingImageViewSize = CGSize(width: 16 * 5 + 4 * 1, height: 16)
        
        // MARK: - Отступы
        
        /// Отступы от краёв ячейки до её содержимого.
        static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
        
        /// Горизонтальный отступ от аватара до имени пользователя.
        static let avatarToUsernameSpacing = 10.0
        /// Вертикальный отступ для элементов стека
        static let stackVerticalSpacing = 6.0
        
        
        //TODO: что с этим делать
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
        self.config = config
        reviewTextLabel.attributedText = config.reviewText
        reviewTextLabel.numberOfLines = config.maxLines
        createdLabel.attributedText = config.created
        usernameLabel.attributedText = config.username
        
        let renderer = RatingRenderer()
        ratingImageView.image = renderer.ratingImage(config.rating)
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
        cellStack.addArrangedSubview(avatarStack)
        cellStack.addArrangedSubview(ratingStack)
        avatarStack.addArrangedSubview(avatarImageView)
        ratingStack.addArrangedSubview(usernameLabel)
        ratingStack.addArrangedSubview(ratingImageView)
        ratingStack.addArrangedSubview(reviewTextLabel)
        ratingStack.addArrangedSubview(createdLabel)
    }
    
    func configureViews() {
        reviewTextLabel.lineBreakMode = .byWordWrapping
        
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        
        avatarImageView.image = UIImage(named: "l5w5aIHioYc")
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = Constants.avatarCornerRadius
        avatarImageView.clipsToBounds = true
        
        usernameLabel.font = Constants.usernameLabelFont
        
        ratingImageView.contentMode = .scaleAspectFit
        
        avatarStack.axis = .vertical
        
        ratingStack.axis = .vertical
        ratingStack.spacing = Constants.stackVerticalSpacing
        ratingStack.alignment = .leading
        
        cellStack.axis = .horizontal
        cellStack.spacing = Constants.avatarToUsernameSpacing
    }
    
    func setupConstraints() {
        avatarStack.translatesAutoresizingMaskIntoConstraints = false
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        cellStack.translatesAutoresizingMaskIntoConstraints = false
        
        reviewTextLabel.translatesAutoresizingMaskIntoConstraints = false
        createdLabel.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height),
            
            showMoreButton.widthAnchor.constraint(equalToConstant: Constants.showMoreButtonSize.width),
            showMoreButton.heightAnchor.constraint(equalToConstant: Constants.showMoreButtonSize.height),
            
            ratingImageView.heightAnchor.constraint(equalToConstant: Constants.ratingImageViewSize.height),
            ratingImageView.widthAnchor.constraint(equalToConstant: Constants.ratingImageViewSize.width),
            
            cellStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.insets.left),
            cellStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.insets.top),
            cellStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.insets.right),
            cellStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.insets.bottom),
        ])
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
