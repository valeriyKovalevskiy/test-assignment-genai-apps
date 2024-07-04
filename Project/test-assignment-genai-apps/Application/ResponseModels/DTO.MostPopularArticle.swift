import Foundation

extension DTO {
    struct MostPopularArticle: Decodable {
        let url: String?
        let id: Int?
        let source: String?
        
        /// date format: "2024-07-03"
        let publishedDate: String?
        
        /// date format: "2024-07-04 10:29:00"
        let updatedDate: String?
        let byline: String?
        let type: String?
        let title: String?
        let abstract: String?
        
        enum CodingKeys: String, CodingKey {
            case url
            case id
            case source
            case publishedDate = "published_date"
            case updatedDate = "updated"
            case byline
            case type
            case title
            case abstract
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id)
            self.source = try container.decodeIfPresent(String.self, forKey: .source)
            self.publishedDate = try container.decodeIfPresent(String.self, forKey: .publishedDate)
            self.updatedDate = try container.decodeIfPresent(String.self, forKey: .updatedDate)
            self.byline = try container.decodeIfPresent(String.self, forKey: .byline)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.abstract = try container.decodeIfPresent(String.self, forKey: .abstract)
        }
    }
}

extension DTO.MostPopularArticle: ToDomainMappingType {
    typealias DomainType = MostPopularArticle
    
    func toDomain() throws -> DomainType {
        .init(
            id: id ?? Int.random(in: 0...100_000_000),
            url: URL(string: url ?? ""),
            author: byline ?? source,
            publishedAt: Date(),
            updatedAt: Date(),
            title: title ?? "Some default title",
            description: abstract,
            type: type ?? ""
        )
    }
}
