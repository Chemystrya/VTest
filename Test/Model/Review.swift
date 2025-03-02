/// Модель отзыва.
struct Review: Decodable {

    /// Имя.
    let firstName: String
    /// Фамилия.
    let lastName: String
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Рейтинг.
    let rating: Int
    /// String url аватара.
    let avatarUrl: String?
    /// Photo urls для отзывов.
    let photoUrls: [String]?

}
