//
//  InjectableToken.swift
//  GithubKit
//
//  Created by marty-suzuki on 2017/11/06.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

public protocol Status {}
public enum Ready: Status {}
public enum NotReady: Status {}
public typealias InjectableToken = InjectableToken_<NotReady>

public struct InjectableToken_<T: Status> {
    private let _token: String

    public static func `init`(token: String) -> InjectableToken {
        return .init(_token: token)
    }
}

extension InjectableToken_ where T == NotReady {
    func readify() throws -> InjectableToken_<Ready> {
        if _token.isEmpty {
            throw ApiSession.Error.emptyToken
        }
        return .init(_token: _token)
    }
}

extension InjectableToken_ where T == Ready {
    var token: String {
        return _token
    }
}
