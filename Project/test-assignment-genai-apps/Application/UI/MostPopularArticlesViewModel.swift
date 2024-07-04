import Foundation
import Combine

extension MostPopularArticlesViewModel {
    enum LoadingContent {
        case mostPopulars
    }
}

final class MostPopularArticlesViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    
    @Injected(\.articleService) private var articleService
    @Injected(\.remoteConfigService) private var remoteConfig
    
    @Published var isLoading: Set<LoadingContent> = .init()
    @Published var daysPeriod: MostPopularArticle.DaysPeriod?
    @Published var alertInfo: AlertInfo?
    @Published var articles: [MostPopularArticle]?
    
    func changeDaysPeriod(to period: MostPopularArticle.DaysPeriod) {
        if daysPeriod != period {
            fetchMostPopularArticles(period: period)
        }
    }
    
    func fetchMostPopularArticles(period: MostPopularArticle.DaysPeriod? = nil) {
        let period = period ?? .init(rawValue: remoteConfig.mostPopularArticlesDaysPeriod) ?? .one
        
        articleService
            .fetchMostPopularArticles(for: period)
            .handleLoading(in: self, keyPath: \.isLoading, event: .mostPopulars)
            .sinkResult { [weak self] result in
                switch result {
                case .success(let articles):
                    self?.articles = articles
                    self?.daysPeriod = period

                case .failure(let error):
                    self?.alertInfo = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}
