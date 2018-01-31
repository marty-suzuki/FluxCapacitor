//
//  PageInfo.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct PageInfo {
    public let hasNextPage: Bool
    public let endCursor: String?
    public let hasPreviousPage: Bool
    public let startCursor: String?
}

extension PageInfo: Decodable {
    private enum CodingKeys: String, CodingKey {
        case hasNextPage
        case endCursor
        case hasPreviousPage
        case startCursor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hasNextPage = try container.decode(Bool.self, forKey: .hasNextPage)
        self.endCursor = try container.decodeIfPresent(String.self, forKey: .endCursor)
        self.hasPreviousPage = try container.decode(Bool.self, forKey: .hasPreviousPage)
        self.startCursor = try container.decodeIfPresent(String.self, forKey: .startCursor)
    }
}
