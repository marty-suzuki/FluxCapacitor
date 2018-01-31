//
//  SearchUserRequest.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct SearchUserRequest: Request {
    public typealias ResponseType = Response<User>

    public var graphQLQuery: String {
        let afterString: String
        if let after = after {
            afterString = ", after: \\\"\(after)\\\""
        } else {
            afterString = ""
        }
        return "{ \"query\": \"{ search(query: \\\"\(query)\\\", type: USER, first: \(limit)\(afterString)) { pageInfo { hasNextPage hasPreviousPage endCursor startCursor } userCount nodes { ...on User { id bio location avatarUrl login url websiteUrl followers { totalCount } repositories { totalCount } following { totalCount } } } } }\" }"
    }

    public let query: String
    public let limit: Int
    public let after: String?

    public init(query: String, after: String?, limit: Int = 10) {
        self.query = query
        self.limit = limit
        self.after = after
    }
}
