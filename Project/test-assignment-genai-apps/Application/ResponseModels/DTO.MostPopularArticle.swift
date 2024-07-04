import Foundation

extension DTO {
    struct MostPopularArticle: Decodable {
        let url: String?
        let id: Int?
        let source: String?
        let publishedDate: String?
        let byline: String?
        let type: String?
        let title: String?
        let abstract: String?
        let media: [Media]?
        
        enum CodingKeys: String, CodingKey {
            case url
            case id
            case source
            case publishedDate = "published_date"
            case byline
            case type
            case title
            case abstract
            case media
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id)
            self.source = try container.decodeIfPresent(String.self, forKey: .source)
            self.publishedDate = try container.decodeIfPresent(String.self, forKey: .publishedDate)
            self.byline = try container.decodeIfPresent(String.self, forKey: .byline)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.abstract = try container.decodeIfPresent(String.self, forKey: .abstract)
            self.media = try container.decodeIfPresent([Media].self, forKey: .media)
        }
    }
}

extension DTO.MostPopularArticle {
    struct Media: Decodable {
        let metadata: [Metadata]?
        
        enum CodingKeys: String, CodingKey {
            case metadata = "media-metadata"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.metadata = try container.decodeIfPresent([Metadata].self, forKey: .metadata)
        }
    }
}

extension DTO.MostPopularArticle.Media {
    struct Metadata: Decodable {
        let url: String?
        let format: Format?
        let height: CGFloat?
        let width: CGFloat?
    }
}

extension DTO.MostPopularArticle.Media.Metadata {
    enum Format: String, Decodable {
        case thumbnail = "Standard Thumbnail"
        case threeByTwo210 = "mediumThreeByTwo210"
        case threeByTwo440 = "mediumThreeByTwo440"
    }
}

private extension Array where Element == DTO.MostPopularArticle.Media {
    var thumbnailMetadata: DTO.MostPopularArticle.Media.Metadata? {
        first?.metadata?.first(where: { $0.format == .thumbnail })
    }
}

extension DTO.MostPopularArticle: ToDomainMappingType {
    typealias DomainType = MostPopularArticle
    
    func toDomain() throws -> DomainType {
        let byline = byline ?? ""
        let author = byline.isEmpty ? source : byline
        let thumbnail: MostPopularArticle.Image? = media?.thumbnailMetadata.map { .init(
            url: URL(string: $0.url ?? ""),
            width: $0.width ?? 0,
            height: $0.height ?? 0
        )}
        
        return .init(
            id: id ?? Int.random(in: 0...100_000_000),
            url: URL(string: url ?? ""),
            author: author,
            publishedAt: publishedDate,
            title: title ?? "Some default title",
            description: abstract,
            type: type ?? "",
            thumbnail: thumbnail
        )
    }
}
