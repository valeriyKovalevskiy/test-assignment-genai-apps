import Combine
import Foundation

private struct RemoteConfigServiceKey: InjectionKey {
    static var currentValue: RemoteConfigServiceType = {
        // any other checks like `is simulator` or anything else are ok as well
        
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
    var mostPopularArticlesDaysPeriod: Int { get set }
}

fileprivate struct RemoteConfigDefaults {
    static var mostPopularArticlesDaysPeriodDefault = 1
}

private final class RemoteConfig: RemoteConfigServiceType {
    var mostPopularArticlesDaysPeriod: Int = RemoteConfigDefaults.mostPopularArticlesDaysPeriodDefault
    
    init() {
        fetchVariables()
    }
    
    private func fetchVariables() {
        // fetch from firebase or any other service
        mostPopularArticlesDaysPeriod = 30
    }
}

private final class RemoteConfigMock: RemoteConfigServiceType {
    var mostPopularArticlesDaysPeriod: Int = RemoteConfigDefaults.mostPopularArticlesDaysPeriodDefault

    init() {
        fetchVariables()
    }
    
    private func fetchVariables() {
        // use whatever you want for testing purposes
        mostPopularArticlesDaysPeriod = 1
    }
}
