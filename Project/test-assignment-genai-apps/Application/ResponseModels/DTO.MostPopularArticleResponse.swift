//
//  DTO.MostPopularArticleResponse.swift
//  test-assignment-genai-apps
//
//  Created by Valery Kavaleuski on 4.07.24.
//

import Foundation

extension DTO {
    struct MostPopularArticleResponse: Decodable {
        let status: String?
        let copyright: String?
        let resultsCount: Int?
        let results: [DTO.MostPopularArticle]?
        
        enum CodingKeys: String, CodingKey {
            case status
            case copyright
            case resultsCount = "num_results"
            case results
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try container.decodeIfPresent(String.self, forKey: .status)
            self.copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
            self.resultsCount = try container.decodeIfPresent(Int.self, forKey: .resultsCount)
            self.results = try container.decodeIfPresent([DTO.MostPopularArticle].self, forKey: .results)
        }
    }
}
