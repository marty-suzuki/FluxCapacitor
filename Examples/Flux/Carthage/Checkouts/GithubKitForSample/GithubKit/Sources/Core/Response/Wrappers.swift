//
//  Wrappers.swift
//  GithubApiSession
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

struct URLWrapper {
    let value: URL

    init(forKey key: String, json: [AnyHashable: Any]) throws {
        guard let value = (json[key] as? String).flatMap(URL.init) else {
            throw JsonDecodeError.parseError(object: json, key: key, expectedType: URL.self)
        }
        self.value = value
    }
}

struct TotalCountWrapper {
    let value: Int

    init(forKey key: String, json: [AnyHashable: Any]) throws {
        guard
            let value = (json[key] as? [AnyHashable: Any]).flatMap({ $0["totalCount"] as? Int })
        else {
            throw JsonDecodeError.parseError(object: json, key: key, expectedType: Int.self)
        }
        self.value = value
    }
}
