import Foundation

typealias AlertResult = Result<String, Error>

extension AlertResult: Identifiable {
    public var id: Int {
        switch self {
        case let .success(text): return text.hashValue << 0
        case let .failure(error): return error.localizedDescription.hashValue << 1
        }
    }
}

enum AlertInfo: Identifiable, Equatable {
    static func == (lhs: AlertInfo, rhs: AlertInfo) -> Bool {
        lhs.id == rhs.id
    }

    var id: Int {
        switch self {
        case .error: return 0
        case .message: return 1
        }
    }

    case error(Error)
    case message(String)
}
