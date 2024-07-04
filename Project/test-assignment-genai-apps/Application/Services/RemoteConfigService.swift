import Combine
import Foundation

private struct RemoteConfigServiceKey: InjectionKey {
    static var currentValue: RemoteConfigServiceType = {

        if ApplicationSettings.shared.isInSwiftUIPreviewMode {
            return RemoteConfigMock()
        }

        if ApplicationSettings.shared.isStaging {
            return RemoteConfigMock()
        }

        return RemoteConfig()
    }()
}

extension InjectedValues {
    var remoteConfigService: RemoteConfigServiceType {
        get { Self[RemoteConfigServiceKey.self] }
        set { Self[RemoteConfigServiceKey.self] = newValue }
    }
}

protocol RemoteConfigServiceType {
    var mostPopularArticlesPageCount: Int { get set }
}

fileprivate struct RemoteConfigDefaults {
    static var mostPopularArticlesPageCountDefault = 1
}

private final class RemoteConfig: RemoteConfigServiceType {
    var mostPopularArticlesPageCount: Int = RemoteConfigDefaults.mostPopularArticlesPageCountDefault
    
    init() {
        fetchVariables()
    }
    
    private func fetchVariables() {
        // fetch from firebase or any other service
        mostPopularArticlesPageCount = 30
    }
}

private final class RemoteConfigMock: RemoteConfigServiceType {
    var mostPopularArticlesPageCount: Int = RemoteConfigDefaults.mostPopularArticlesPageCountDefault

    init() {
        fetchVariables()
    }
    
    private func fetchVariables() {
        // use whatever you want for testing purposes
        mostPopularArticlesPageCount = 1
    }
}
