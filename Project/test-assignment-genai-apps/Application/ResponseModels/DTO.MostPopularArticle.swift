import Foundation

extension DTO {
    struct MostPopularArticle: Decodable {
        let copyright: String?
    }
}

extension DTO.MostPopularArticle: ToDomainMappingType {
    typealias DomainType = MostPopularArticle
    
    func toDomain() throws -> DomainType {
        .init(
            id: UUID().uuidString,
            copyright: copyright ?? ""
        )
    }
}
