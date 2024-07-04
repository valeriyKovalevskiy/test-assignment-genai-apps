import Foundation
import Combine

extension ContentViewModel {
    enum LoadingContent {
        case mostPopulars
    }
}

final class ContentViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    
    @Injected(\.articleService) private var articleService
    @Injected(\.remoteConfigService) private var remoteConfig
    
    @Published var isLoading: Set<LoadingContent> = .init()
    @Published var daysPeriod: MostPopularArticle.DaysPeriod = .one
    @Published var alertInfo: AlertInfo?
    @Published var articles: [MostPopularArticle]?
    
    func changeDaysPeriod(to period: MostPopularArticle.DaysPeriod) {
        guard daysPeriod != period else {
            return
        }
        
        daysPeriod = period
        fetchMostPopularArticles(period: period)
    }
    
    func fetchMostPopularArticles(period: MostPopularArticle.DaysPeriod? = nil) {
        daysPeriod = period ?? .init(rawValue: remoteConfig.mostPopularArticlesDaysPeriod) ?? .one
        
        articleService
            .fetchMostPopularArticles(for: daysPeriod)
            .handleLoading(in: self, keyPath: \.isLoading, event: .mostPopulars)
            .sinkResult { [weak self] result in
                switch result {
                case .success(let articles):
                    self?.articles = articles

                case .failure(let error):
                    self?.alertInfo = .error(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}
