import Foundation

struct MostPopularArticle: Identifiable, Equatable {
    let id: Int
    let url: URL?
    let author: String?
    let publishedAt: String?
    let title: String
    let description: String?
    let type: String
    let thumbnail: Image?
}

extension MostPopularArticle {
    struct Image: Identifiable, Equatable {
        let id: String = UUID().uuidString
        let url: URL?
        let width: CGFloat
        let height: CGFloat
    }
}

extension MostPopularArticle {
    enum DaysPeriod: Int {
        case one = 1
        case seven = 7
        case thirty = 30
    }
}
