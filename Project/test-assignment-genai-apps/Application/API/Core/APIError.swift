import Moya
import Combine
import Foundation

extension API {

    /// Wrapper for different error types
    indirect enum Error: CustomNSError {

        case moyaError(MoyaError)
        case error(URLRequest?, Swift.Error)

        var errorCode: Int {
            switch self {
            case let .moyaError(moyaError): return moyaError.response?.statusCode ?? Int.min
            case let .error(_, error): return (error as NSError).code
            }
        }

        init?(
            request: URLRequest?,
            body data: Data
        ) {
            do {
                let errorBody = try JSONDecoder().decode(ErrorBody.self, from: data)
                self = .error(request, NSError(domain: "", code: errorBody.errorCode, userInfo: [NSLocalizedDescriptionKey: errorBody.message]))
            } catch {
                return nil
            }
        }

        struct ErrorBody: Codable {
            let errorCode: Int
            let message: String
        }
    }
}
