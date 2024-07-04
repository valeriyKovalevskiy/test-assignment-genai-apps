import Combine
import Foundation

private struct ArticleServiceKey: InjectionKey {
    static var currentValue: ArticleServiceType = {

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
    func fetchMostPopularArticles(for days: Int) -> AnyPublisher<MostPopularArticle, Error>
}

private final class ArticleService: ArticleServiceType {
    func fetchMostPopularArticles(for days: Int) -> AnyPublisher<MostPopularArticle, Error> {
        API.MostPopular.Viewed(period: days)
            .request()
            .compactMap { try? $0.toDomain() }
            .eraseToAnyPublisher()
    }
}

private final class ArticleServiceMock: ArticleServiceType {
    func fetchMostPopularArticles(for days: Int) -> AnyPublisher<MostPopularArticle, Error> {
        API.MostPopular.Viewed(period: days)
            .fakeRequest()
            .compactMap { try? $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
