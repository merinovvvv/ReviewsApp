//
//  TotalReviewsCell.swift
//  Test
//
//  Created by Yaroslav Merinov on 29.06.25.
//

import UIKit

struct TotalReviewsCellConfig {
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: TotalReviewsCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст ячейки.
    let reviewCount: Int
}

// MARK: - TableCellConfig

extension TotalReviewsCellConfig: TableCellConfig {
    private static var sizingCell: ReviewCell?
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? TotalReviewsCell else { return }
        cell.configure(with: self)
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Cell

final class TotalReviewsCell: UITableViewCell {
    
    fileprivate var config: Config?
    private var currentConfigId: UUID?
    
    //MARK: Private. UI Properties
    fileprivate var reviewsLabel = UILabel()
    
    //MARK: Private. Constants
    private enum Constants {
        // MARK: - Размеры
        static let reviewsLabelFont = UIFont.systemFont(ofSize: 14)
        
        // MARK: - Отступы
        static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func configure(with config: TotalReviewsCellConfig) {
        self.config = config
        currentConfigId = config.id
        reviewsLabel.text = "\(config.reviewCount) отзывов"
        setNeedsLayout()
    }
    
}

// MARK: - Private. Setup UI

private extension TotalReviewsCell {
    
    func setupCell() {
        setupViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func setupViewHierarchy() {
        contentView.addSubview(reviewsLabel)
    }

    func configureViews() {
        reviewsLabel.textColor = .gray
        reviewsLabel.font = Constants.reviewsLabelFont
    }
    
    func setupConstraints() {
        reviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reviewsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            reviewsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Typealias

fileprivate typealias Config = TotalReviewsCellConfig
