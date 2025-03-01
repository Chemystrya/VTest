/// Модель отзыва.
struct Review: Decodable {

    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Рейтинг
    let rating: Int

}
