//
//  Response.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

enum JsonDecodeError: Error {
    case parseError(object: Any, key: String, expectedType: Any.Type)
    case castError(object: Any, expectedType: Any.Type)
}

public protocol JsonDecodable {
    init(json: [AnyHashable: Any]) throws
}

public struct Response<T: JsonDecodable> {
    public let nodes: [T]
    public let pageInfo: PageInfo
    public let totalCount: Int

    init(forKeys keys: [String], totalCountKey: String, json: [AnyHashable: Any]) throws {
        guard let dataJson = json["data"] as? [AnyHashable: Any] else {
            throw JsonDecodeError.parseError(object: json, key: "data", expectedType: [[AnyHashable: Any]].self)
        }
        let innerJson = try keys.reduce(dataJson) { result, key in
            guard let dict = result[key] as? [AnyHashable : Any] else {
                throw JsonDecodeError.parseError(object: result, key: key, expectedType: [AnyHashable: Any].self)
            }
            return dict
        }
        guard let rawNodes = innerJson["nodes"] as? [[AnyHashable: Any]] else {
            throw JsonDecodeError.parseError(object: innerJson, key: "nodes", expectedType: [[AnyHashable: Any]].self)
        }
        self.nodes = rawNodes.flatMap { try? T(json: $0) }
        guard let rawPageInfo = innerJson["pageInfo"] as? [AnyHashable: Any] else {
            throw JsonDecodeError.parseError(object: innerJson, key: "pageInfo", expectedType: [AnyHashable: Any].self)
        }
        self.pageInfo = try PageInfo(json: rawPageInfo)
        guard let totalCount = innerJson[totalCountKey] as? Int else {
            throw JsonDecodeError.parseError(object: innerJson, key: totalCountKey, expectedType: Int.self)
        }
        self.totalCount = totalCount
    }
}
