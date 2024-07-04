import Foundation

enum Target: String, Codable, CaseIterable {
    case staging
    case production

    static var current: Target = .init()

    var host: String {
        switch self {
        case .staging: return "https://api.nytimes.com"
        case .production: return "https://api.nytimes.com"
        }
    }

    var baseURL: URL {
        URL(string: "\(host)/svc/")!
    }

    init() {
        /// Depends on project config / target or whatewer
        /// set staging / prod / rc or any other environment flag
        self = .production
    }
}
