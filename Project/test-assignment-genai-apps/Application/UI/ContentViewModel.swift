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

    func changeDaysPeriod(to period: MostPopularArticle.DaysPeriod) {
        daysPeriod = period
        fetchMostPopularArticles(period: period)
    }
    
    func fetchMostPopularArticles(period: MostPopularArticle.DaysPeriod? = nil) {
        daysPeriod = period ?? .init(rawValue: remoteConfig.mostPopularArticlesDaysPeriod) ?? .one
        
        articleService
            .fetchMostPopularArticles(for: daysPeriod)
            .handleLoading(in: self, keyPath: \.isLoading, event: .mostPopulars)
            .sinkResult { result in
                switch result {
                case .success(let feed):
                    print(feed)
                    
                case .failure(let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
}
