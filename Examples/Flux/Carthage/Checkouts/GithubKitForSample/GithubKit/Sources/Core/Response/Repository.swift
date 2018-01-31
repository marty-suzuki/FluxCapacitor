//
//  Repository.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct Repository {
    public struct Language {
        let name: String
        let color: String
    }
    
    public let name: String
    public let introduction: String?
    public let language: Language?
    public let stargazerCount: Int
    public let forkCount: Int
    public let url: URL
    public let updatedAt: Date
}

extension Repository.Language: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.color = try container.decode(String.self, forKey: .color)
    }
}

extension Repository: JSONDecodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case introduction = "description"
        case language = "languages"
        case stargazerCount = "stargazers"
        case forkCount = "forks"
        case url
        case updatedAt
    }

    private enum LanguagesCodingKeys: String, CodingKey {
        case nodes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.introduction = try container.decodeIfPresent(String.self, forKey: .introduction)
        self.stargazerCount = try container.decode(TotalCountWrapper.self, forKey: .stargazerCount).value
        self.forkCount = try container.decode(TotalCountWrapper.self, forKey: .forkCount).value
        self.url = try container.decode(URL.self, forKey: .url)
        let languages = try container.nestedContainer(keyedBy: LanguagesCodingKeys.self, forKey: .language)
        self.language = try languages.decode([Language].self, forKey: .nodes).first
        self.updatedAt = try container.decode(ISO8601DateWrapper.self, forKey: .updatedAt).value
    }
}

extension Repository {
    public enum ResponseDecoder: ResponseDecoderProtocol {
        public static let totalCount = TotalCountCodingKey("totalCount")

        private enum DataCodingKeys: String, CodingKey {
            case data
        }

        private enum NodeCodingKeys: String, CodingKey {
            case node
        }

        private enum RepositoriesCodingKeys: String, CodingKey {
            case repositories
        }

        public static func containers(from decoder: Decoder) throws -> (common: CommonContainer, count: CountContainer) {
            let data = try decoder.container(keyedBy: DataCodingKeys.self)
            let node = try data.nestedContainer(keyedBy: NodeCodingKeys.self, forKey: .data)
            let repositories = try node.nestedContainer(keyedBy: RepositoriesCodingKeys.self, forKey: .node)
            return try (repositories.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .repositories),
                        repositories.nestedContainer(keyedBy: TotalCountCodingKey.self, forKey: .repositories))
        }
    }
}
