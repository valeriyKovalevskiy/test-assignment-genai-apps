import Combine
import Foundation

private struct ArticleServiceKey: InjectionKey {
    static var currentValue: ArticleServiceType = {
        // any other checks like `is simulator` or anything else are ok as well

        if ApplicationSettings.shared.isInSwiftUIPreviewMode {
            return ArticleServiceMock()
        }

        if ApplicationSettings.shared.isStaging {
            return ArticleServiceMock()
        }

        return ArticleService()
    }()
}

extension InjectedValues {
    var articleService: ArticleServiceType {
        get { Self[ArticleServiceKey.self] }
        set { Self[ArticleServiceKey.self] = newValue }
    }
}

protocol ArticleServiceType {
    // use protocols for dependency injection and for unit testing
    func fetchMostPopularArticles(for daysPeriod: MostPopularArticle.DaysPeriod) -> AnyPublisher<[MostPopularArticle], Error>
}

private final class ArticleService: ArticleServiceType {
    func fetchMostPopularArticles(for daysPeriod: MostPopularArticle.DaysPeriod) -> AnyPublisher<[MostPopularArticle], Error> {
        API.MostPopular.Viewed(period: daysPeriod.rawValue)
            .request()
            .compactMap { $0.results?.compactMap { try? $0.toDomain() }}
            .eraseToAnyPublisher()
    }
}

private final class ArticleServiceMock: ArticleServiceType {
    // fake request will allow you to test mapping errors
    // alternatively you could send response like `Just(.mockModel).eraseToAnyPublisher()`
    func fetchMostPopularArticles(for daysPeriod: MostPopularArticle.DaysPeriod) -> AnyPublisher<[MostPopularArticle], Error> {
        API.MostPopular.Viewed(period: daysPeriod.rawValue)
            .fakeRequest()
            .compactMap { $0.results?.compactMap { try? $0.toDomain() }}
            .eraseToAnyPublisher()
    }
}
