//
//  ReviewsCountCell.swift
//  Test
//
//  Created by Fedorova Maria on 01.03.2025.
//

import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewsCountCellConfig {

    /// Идентификатор для переиспользования ячейки
    static let reuseId = String(describing: ReviewsCountCellConfig.self)

    /// Количество отзывов
    let text: NSAttributedString

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = Layout()
}

// MARK: - TableCellConfig

extension ReviewsCountCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewsCountCell else { return }
        cell.countLabel.attributedText = text
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Cell

final class ReviewsCountCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let countLabel = UILabel()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let layout = config?.layout else { return }

        countLabel.frame = layout.countLabelFrame
    }
}

// MARK: - Настройка UI
private extension ReviewsCountCell {
    func setupCell() {
        setupCountLabel()
    }

    func setupCountLabel() {
        contentView.addSubview(countLabel)
        countLabel.textAlignment = .center
    }
}

// MARK: - Layout
private final class ReviewsCountCellLayout {

    // MARK: - Фреймы

    private(set) var countLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 12.0, right: 8.0)

    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let textWidth = maxWidth - insets.left - insets.right

        countLabelFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: CGSize(width: textWidth, height: config.text.boundingRect(width: textWidth).height)
        )

        return countLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = ReviewsCountCellConfig
fileprivate typealias Layout = ReviewsCountCellLayout
