import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Аватар пользователя.
    let stringUrl: String?
    /// Имя и фамилия пользователя.
    let usernameText: NSAttributedString
    /// Рейтинг.
    let ratingImage: UIImage
    /// Фото отзыва.
    let photoImages: [String]
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.avatarImageView.setImage(stringUrl: stringUrl, placeholder: UIImage(named: "l5w5aIHioYc"))
        cell.usernameTextLabel.attributedText = usernameText
        cell.ratingImageView.image = ratingImage

        // Установка изображений для photoImageViews
        for (index, imageView) in cell.photoImageViews.enumerated() {
            if index < photoImages.count {
                imageView.setImage(stringUrl: photoImages[index])
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }

        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
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

    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameTextLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate var photoImageViews: [UIImageView] = []
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()

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

        avatarImageView.frame = layout.avatarImageViewFrame
        usernameTextLabel.frame = layout.usernameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame

        for (index, frame) in layout.photoImageViewFrames.enumerated() {
            if index < photoImageViews.count {
                photoImageViews[index].frame = frame
            }
        }

        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAvatarImageView()
        setupNameAndLastNameTextLabel()
        setupRatingImageView()
        setupPhotoImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }

    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }

    func setupNameAndLastNameTextLabel() {
        contentView.addSubview(usernameTextLabel)
    }

    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }

    func setupPhotoImageView() {
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = ReviewCellLayout.photoCornerRadius
            imageView.clipsToBounds = true
            contentView.addSubview(imageView)
            photoImageViews.append(imageView)
        }
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addAction(UIAction { [weak self] _ in
            guard let self, let id = config?.id else { return }

            config?.onTapShowMore(id)
        }, for: .touchUpInside)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var photoImageViewFrames: [CGRect] = []
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let leftInset = Self.avatarSize.width + avatarToUsernameSpacing + insets.left
        let width = maxWidth - leftInset - insets.right

        var maxY = insets.top
        var showShowMoreButton = false
        // Расчет фрейма для avatarImageView
        avatarImageViewFrame = CGRect(origin: CGPoint(x: insets.left, y: maxY), size: Self.avatarSize)
        // Расчет фрейма для usernameTextLabel
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: leftInset, y: maxY),
            size: config.usernameText.boundingRect(width: width).size
        )
        maxY = usernameLabelFrame.maxY + usernameToRatingSpacing
        // Расчет фрейма для ratingImageView
        let ratingImageSize = calculateRatingImageSize(image: config.ratingImage, maxWidth: maxWidth)
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: leftInset, y: maxY),
            size: ratingImageSize
        )
        maxY = ratingImageViewFrame.maxY + ratingToPhotosSpacing
        // Расчет фрейма для photoImageView
        if !config.photoImages.isEmpty {
            let photoCount = min(config.photoImages.count, 5)
            photoImageViewFrames = []
            for i in 0..<photoCount {
                let x = leftInset + CGFloat(i) * (Self.photoSize.width + photosSpacing)
                let frame = CGRect(
                    origin: CGPoint(x: x, y: maxY),
                    size: Self.photoSize
                )
                photoImageViewFrames.append(frame)
            }
            maxY = photoImageViewFrames.last?.maxY ?? maxY
            maxY += photosToTextSpacing
        } else {
            maxY += ratingToTextSpacing
        }
        // Расчет фрейма для reviewTextLabel
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: leftInset, y: maxY),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        //Расчет фрейма для showShowMoreButton
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: leftInset, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        // Расчет фрейма для createdLabel
        createdLabelFrame = CGRect(
            origin: CGPoint(x: leftInset, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

private extension ReviewCellLayout {
    /// Рассчитывает размер изображения с сохранением пропорций.
    func calculateRatingImageSize(image: UIImage, maxWidth: CGFloat) -> CGSize {
        let originalSize = image.size
        let aspectRatio = originalSize.height / originalSize.width

        // Ограничивает ширину изображения до maxWidth.
        let scaledWidth = min(originalSize.width, maxWidth)
        let scaledHeight = scaledWidth * aspectRatio

        return CGSize(width: scaledWidth, height: scaledHeight)
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
