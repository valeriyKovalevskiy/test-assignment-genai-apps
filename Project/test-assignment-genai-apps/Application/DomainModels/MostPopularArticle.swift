import Foundation

struct MostPopularArticle: Identifiable, Equatable {
    let id: Int
    let url: URL?
    let author: String?
    let publishedAt: Date?
    let updatedAt: Date?
    let title: String
    let description: String?
    let type: String
}

extension MostPopularArticle {
    enum DaysPeriod: Int {
        case one = 1
        case seven = 7
        case thirty = 30
    }
}
