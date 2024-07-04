import Combine
import Moya
import Foundation

typealias TargetMethod = Moya.Method

// MARK: - Protocols

/// `TargetType` with typealias `T: JSONJoy`
protocol ModelTargetType: AppTargetType {
    associatedtype Response: Decodable
}

/// `TargetType` with success type
protocol SuccessTargetType: AppTargetType {}

// MARK: - TargetType

protocol AppTargetType: TargetType {
    var method: TargetMethod { get }
    var request: TargetRequest? { get }
    var encoding: URLEncoding? { get }
    var baseURL: URL { get }
}

extension AppTargetType {
    var request: TargetRequest? { nil }
    var encoding: URLEncoding? { nil }
    var baseURL: URL { API.baseURL }

    var task: Moya.Task {
        switch request {
        case let .multipart(data): return .uploadMultipart(data)
        case let .parameters(parameters): return .requestParameters(parameters: parameters, encoding: encoding ?? URLEncoding.queryString)
        case let .encodable(encodable): return .requestCustomJSONEncodable(encodable, encoder: encoder)
        case let .data(data): return .requestData(data)
        case .none: return .requestPlain
        }
    }
}

// MARK: - TargetRequest

enum TargetRequest {
    case parameters([String: Any])
    case multipart([MultipartFormData])
    case data(Data)
    case encodable(Encodable)
}
