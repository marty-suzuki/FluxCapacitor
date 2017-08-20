//
//  Repository.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct Repository: JsonDecodable {
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
    
    public init(json: [AnyHashable : Any]) throws {
        guard let name = json["name"] as? String else {
            throw JsonDecodeError.parseError(object: json, key: "name", expectedType: String.self)
        }
        self.name = name
        
        if
            let languages = json["languages"] as? [AnyHashable: Any],
            let nodes = languages["nodes"] as? [[AnyHashable: Any]],
            let name = nodes.first?["name"] as? String,
            let color = nodes.first?["color"] as? String
        {
            self.language = Language(name: name, color: color)
        } else {
            self.language = nil
        }
        
        self.stargazerCount = try TotalCountWrapper(forKey: "stargazers", json: json).value
        self.forkCount = try TotalCountWrapper(forKey: "forks", json: json).value
        self.url = try URLWrapper(forKey: "url", json: json).value
        
        self.introduction = json["description"] as? String
        
        guard let rawUpdatedAt = json["updatedAt"] as? String else {
            throw JsonDecodeError.parseError(object: json, key: "updatedAt", expectedType: String.self)
        }
        guard let updatedAt = DateFormatter.ISO8601.date(from: rawUpdatedAt) else {
            throw JsonDecodeError.parseError(object: json, key: "updatedAt", expectedType: Date.self)
        }
        self.updatedAt = updatedAt
    }
}
