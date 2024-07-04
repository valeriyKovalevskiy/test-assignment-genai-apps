import Foundation
import Moya

extension API { enum MostPopular {} }
extension API.MostPopular {
    
    private static let categoryPath = "/mostpopular/v2/"

    struct Viewed: ModelTargetType {
        typealias Response = DTO.MostPopularArticle

        let period: Int
        var path: String { categoryPath + "viewed/\(period).json" }
        var method: TargetMethod { .get }
        var task: Task {
            .requestParameters(
                parameters: ["api-key": ApplicationSecrets.mostPopularKey],
                encoding: URLEncoding.queryString)
        }
        var sampleData: Data { .init(jsonFileName: "MostPopularArticleResponse") }
    }
    
    struct Emailed: SuccessTargetType {
        // Test assignment won't require Emailed endpoint but there's
        // just an example how to scale API layer
        let period: Int
        var path: String { categoryPath + "emailed/\(period).json" }
        var method: TargetMethod { .get }
        var sampleData: Data { .init(jsonFileName: "somethingThatIsNotExist") }
    }
}
