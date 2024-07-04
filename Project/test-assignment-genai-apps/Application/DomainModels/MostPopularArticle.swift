import Foundation

struct MostPopularArticle: Identifiable, Equatable {
    let id: String
    let copyright: String
}

extension MostPopularArticle {
    enum DaysPeriod: Int {
        case one = 1
        case seven = 7
        case thirty = 30
    }
}
