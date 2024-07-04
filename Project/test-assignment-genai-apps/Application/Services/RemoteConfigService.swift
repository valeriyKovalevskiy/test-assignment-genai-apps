import Combine
import Foundation

// i've decided to implment abstract service that might simulate remote config variables fetch

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
    // removte variables  usually stored as a primitive types
    // so that's why i've used integer instead of stricted enum cases
    static var mostPopularArticlesDaysPeriodDefault: Int = 1
}

private final class RemoteConfig: RemoteConfigServiceType {
    var mostPopularArticlesDaysPeriod: Int = RemoteConfigDefaults.mostPopularArticlesDaysPeriodDefault
    
    init() {
        fetchVariables()
    }
    
    private func fetchVariables() {
        // fetch from firebase or any other service
        mostPopularArticlesDaysPeriod = 7
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
