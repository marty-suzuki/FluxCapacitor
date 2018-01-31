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
    associatedtype ResponseType: ResponseDecodable

    var baseURL: URL { get }
    var allHTTPHeaderFields: [String : String]? { get }

    var method: HttpMethod { get }
    var graphQLQuery: String { get }

    static func decode(with data: Data) throws -> ResponseType
}

extension Request {
    public static func decode(with data: Data) throws -> ResponseType {
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }

    public var method: HttpMethod {
        return .post
    }

    public var baseURL: URL {
        fatalError("must use RequestProxy")
    }

    public var allHTTPHeaderFields: [String : String]? {
        return nil
    }
}


