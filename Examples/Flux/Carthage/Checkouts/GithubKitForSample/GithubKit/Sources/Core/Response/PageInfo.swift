//
//  PageInfo.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct PageInfo: JsonDecodable {
    public let hasNextPage: Bool
    public let endCursor: String?
    public let hasPreviousPage: Bool
    public let startCursor: String?
    
    public init(json: [AnyHashable : Any]) throws {
        guard let hasNextPage = json["hasNextPage"] as? Bool else {
            throw JsonDecodeError.parseError(object: json, key: "hasNextPage", expectedType: Bool.self)
        }
        self.hasNextPage = hasNextPage
        
        guard let hasPreviousPage = json["hasPreviousPage"] as? Bool else {
            throw JsonDecodeError.parseError(object: json, key: "hasPreviousPage", expectedType: Bool.self)
        }
        self.hasPreviousPage = hasPreviousPage
        
        self.startCursor = json["startCursor"] as? String
        self.endCursor = json["endCursor"] as? String
    }
}
