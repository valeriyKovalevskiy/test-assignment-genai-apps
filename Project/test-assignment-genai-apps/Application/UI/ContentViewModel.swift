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

    func fetchMostPopularArticles() {
        let daysRange = remoteConfig.mostPopularArticlesPageCount
        
        articleService
            .fetchMostPopularArticles(for: daysRange)
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
