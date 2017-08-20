//
//  Request.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public enum HttpMethod {
    case post

    var value: String {
        switch self {
        case .post: return "POST"
        }
    }
}

final class RequestConfig {
    static let shared = RequestConfig()
    var token: String?
}

public protocol Request {
    associatedtype ResponseType: JsonDecodable
    static var keys: [String] { get }
    static var totalCountKey: String { get }

    var baseURL: URL { get }
    var allHTTPHeaderFields: [String : String]? { get }

    var method: HttpMethod { get }
    var graphQLQuery: String { get }
}

extension Request {
    static func decode(with data: Data) throws -> Response<ResponseType> {
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = object as? [AnyHashable: Any] else {
            throw JsonDecodeError.castError(object: object, expectedType: [AnyHashable: Any].self)
        }
        return try .init(forKeys: keys, totalCountKey: totalCountKey, json: json)
    }
    
    public var method: HttpMethod {
        return .post
    }

    public var baseURL: URL {
        return URL(string: "https://api.github.com/graphql")!
    }

    public var allHTTPHeaderFields: [String : String]? {
        guard let token = RequestConfig.shared.token else { return nil }
        return ["Authorization" : "bearer \(token)"]
    }
}
