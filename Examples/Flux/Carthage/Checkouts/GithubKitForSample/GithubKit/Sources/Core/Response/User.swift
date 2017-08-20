//
//  User.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct User: JsonDecodable {
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

    public init(json: [AnyHashable: Any]) throws {
        guard let id = json["id"] as? String else {
            throw JsonDecodeError.parseError(object: json, key: "id", expectedType: String.self)
        }
        self.id = id

        self.avatarURL = try URLWrapper(forKey: "avatarUrl", json: json).value
        self.followerCount = try TotalCountWrapper(forKey: "followers", json: json).value
        self.followingCount = try TotalCountWrapper(forKey: "following", json: json).value
        self.repositoryCount = try TotalCountWrapper(forKey: "repositories", json: json).value
        guard let login = json["login"] as? String else {
            throw JsonDecodeError.parseError(object: json, key: "login", expectedType: String.self)
        }
        self.login = login
        self.url = try URLWrapper(forKey: "url", json: json).value
        
        self.websiteURL = (json["websiteUrl"] as? String).flatMap(URL.init)
        self.location = json["location"] as? String
        self.bio = json["bio"] as? String
    }
}
