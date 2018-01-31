//
//  RequestProxy.swift
//  GithubKit
//
//  Created by marty-suzuki on 2017/11/06.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public struct RequestProxy<T: Request>: Request {
    private let request: T
    private let token: String
    
    public let baseURL: URL

    init(request: T, injectableBaseURL: InjectableBaseURL, injectableToken: InjectableToken_<Ready>) {
        self.request = request
        self.token = injectableToken.token
        self.baseURL = injectableBaseURL.url
    }

    func buildURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = method.value
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields
        urlRequest.httpBody = graphQLQuery.data(using: .utf8)
        return urlRequest
    }
}

extension RequestProxy {
    public typealias ResponseType = T.ResponseType
    
    public var method: HttpMethod {
        return request.method
    }

    public var graphQLQuery: String {
        return request.graphQLQuery
    }

    public var allHTTPHeaderFields: [String : String]? {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields["Authorization"] = "bearer \(token)"
        return headerFields
    }

    public static func decode(with data: Data) throws -> ResponseType {
        return try T.decode(with: data)
    }
}
