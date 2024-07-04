import Alamofire
import Combine
import Foundation
import Moya

enum API {
    static var baseURL: URL { Target.current.baseURL }

    static func headers() -> [String: String] {
        [
            "X-DeviceType": "app",
            "X-OperatingSystem": "iOS",
            "X-DeviceId": ApplicationSettings.shared.vendorIdentifier,
            "X-SystemVersion": ApplicationSettings.shared.systemVersion,
            "X-AppVersion": ApplicationSettings.shared.versionNumber,
            "X-Build": ApplicationSettings.shared.buildNumber,
            "X-TimeZone": ApplicationSettings.shared.timeZone
        ]
            .compactMapValues { $0 }
    }
}

// MARK: - Default TargetType values

extension TargetType {
    var baseURL: URL { API.baseURL }
    var sampleData: Data { Data() }
    var validate: Bool { false }
    var validationType: Moya.ValidationType { .none }
    var decoder: JSONDecoder { .init() }
    var encoder: JSONEncoder { .init() }
    var headers: [String: String]? { API.headers() }
}

// MARK: - Authorized MoyaProvider

extension MoyaProvider {

    static func `default`(
        stubClosure: @escaping (Target) -> Moya.StubBehavior
    ) -> OnlineProvider<Target> {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 45

        let session = Alamofire.Session(configuration: configuration)

        return OnlineProvider(
            endpointClosure: { target in MoyaProvider.defaultEndpointMapping(for: target) },
            requestClosure: { endpoint, closure in
                guard let request = try? endpoint.urlRequest() else {
                    closure(.failure(MoyaError.requestMapping("Failed to generete url in API.swift MoyaProvider extension")))
                    return
                }
                closure(.success(request))
            },
            stubClosure: stubClosure,
            session: session,
            plugins: [] // add plugins like authorization handling or error handling. won't overengineer due to test assignment
        )
    }
}

// MARK: - OnlineProvider
import UIKit

final class OnlineProvider<Target> where Target: TargetType {
    
    fileprivate let provider: MoyaProvider<Target>
    
    init(
        endpointClosure: @escaping Moya.MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
        requestClosure: @escaping Moya.MoyaProvider<Target>.RequestClosure,
        stubClosure: @escaping Moya.MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        session: Moya.Session = MoyaProvider<Target>.defaultAlamofireSession(),
        plugins: [Moya.PluginType] = [],
        trackInflights: Bool = false
    ) {
        provider = MoyaProvider(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }
    
    func request(
        _ target: Target
    ) -> AnyPublisher<Moya.Response, MoyaError> {
        let cancelPublisher = NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .map { _ in }
            .eraseToAnyPublisher()
        
        return Publishers.CancelableRequest(
            provider.requestPublisher(target),
            cancelPublisher: cancelPublisher
        ).eraseToAnyPublisher()
    }
}
