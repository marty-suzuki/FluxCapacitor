//
//  User.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct User {
    public let id: String
    public let avatarURL: URL
    public let followerCount: Int
    public let followingCount: Int
    public let login: String
    public let repositoryCount: Int
    public let url: URL
    public let websiteURL: URL?
    public let location: String?
    public let bio: String?
}

extension User: JSONDecodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case avatarURL = "avatarUrl"
        case followerCount = "followers"
        case followingCount = "following"
        case repositoryCount = "repositories"
        case login
        case url
        case websiteURL = "websiteUrl"
        case location
        case bio
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.avatarURL = try container.decode(URL.self, forKey: .avatarURL)
        self.followerCount = try container.decode(TotalCountWrapper.self, forKey: .followerCount).value
        self.followingCount = try container.decode(TotalCountWrapper.self, forKey: .followingCount).value
        self.repositoryCount = try container.decode(TotalCountWrapper.self, forKey: .repositoryCount).value
        self.login = try container.decode(String.self, forKey: .login)
        self.url = try container.decode(URL.self, forKey: .url)
        let rawWebsiteURL = try container.decodeIfPresent(String.self, forKey: .websiteURL)
        self.websiteURL = rawWebsiteURL.flatMap { $0.isEmpty ? nil : URL(string: $0) }
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
    }
}

extension User {
    public enum ResponseDecoder: ResponseDecoderProtocol {
        public static let totalCount = TotalCountCodingKey("userCount")

        private enum DataCodingKeys: String, CodingKey {
            case data
        }

        private enum SearchCodingKeys: String, CodingKey {
            case search
        }

        public static func containers(from decoder: Swift.Decoder) throws -> (common: CommonContainer, count: CountContainer) {
            let data = try decoder.container(keyedBy: DataCodingKeys.self)
            let search = try data.nestedContainer(keyedBy: SearchCodingKeys.self, forKey: .data)
            return try (search.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .search),
                        search.nestedContainer(keyedBy: TotalCountCodingKey.self, forKey: .search))
        }
    }
}
