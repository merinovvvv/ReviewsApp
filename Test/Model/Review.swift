/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя пользователя
    let first_name: String
    /// Фамилия пользователя
    let last_name: String
    /// Рейтинг
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
}
