import Combine
import CombineMoya
import Foundation
import Moya

extension ModelTargetType {

    func fakeRequest(
        delaySeconds: TimeInterval = 1.5
    ) -> AnyPublisher <Response, Error> {
        CombineMoyaProviderRequest(self, stubClosure: MoyaProvider.delayedStub(delaySeconds))
            .filterSuccessfulStatusCodes()
            .map(Response.self, using: decoder)
            .mapError { moyaError -> API.Error in
                guard let data = moyaError.response?.data, let error = API.Error(request: moyaError.response?.request, body: data) else {
                    return .moyaError(moyaError)
                }
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func request() -> AnyPublisher<Response, Error> {
        CombineMoyaProviderRequest(self)
            .filterSuccessfulStatusCodes()
            .retry(
                behavior: .immediate(retries: 3),
                shouldRetry: { error in
                    guard case let .underlying(error, _) = error as? MoyaError,
                          case let .sessionTaskFailed(error as NSError) = error.asAFError
                    else { return false }
                    return error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut
                },
                scheduler: DispatchQueue.main
            )
            .map(Response.self, using: decoder)
            .mapError { moyaError -> API.Error in
                guard let data = moyaError.response?.data, let error = API.Error(request: moyaError.response?.request, body: data) else {
                    return .moyaError(moyaError)
                }
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension SuccessTargetType {
    func fakeRequest(
        delaySeconds: TimeInterval = 1.5
    ) -> AnyPublisher<Void, Error> {
        CombineMoyaProviderRequest(self, stubClosure: MoyaProvider.delayedStub(delaySeconds))
            .filterSuccessfulStatusCodes()
            .map { _ in }
            .mapError { moyaError -> API.Error in
                guard let data = moyaError.response?.data, let error = API.Error(request: moyaError.response?.request, body: data) else {
                    return .moyaError(moyaError)
                }
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func request() -> AnyPublisher<Void, Error> {
        CombineMoyaProviderRequest(self)
            .filterSuccessfulStatusCodes()
            .map { _ in }
            .mapError { moyaError -> API.Error in
                guard let data = moyaError.response?.data, let error = API.Error(request: moyaError.response?.request, body: data) else {
                    return .moyaError(moyaError)
                }
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension AppTargetType {

    func rawRequest() -> AnyPublisher<Moya.Response, MoyaError> {
        CombineMoyaProviderRequest(self)
    }
}

// MARK: - TargetType Provider caching

private func CombineMoyaProviderRequest<T: AppTargetType>(
    _ target: T,
    stubClosure: @escaping (T) -> StubBehavior = MoyaProvider.neverStub
) -> AnyPublisher<Moya.Response, MoyaError> {
   let provider = MoyaProvider<T>.default(stubClosure: stubClosure)

    // Keeps strong reference to the provider until completed or failed
    return provider
        .request(target)
        .handleEvents(receiveCompletion: { _ in _ = provider })
        .eraseToAnyPublisher()
}
