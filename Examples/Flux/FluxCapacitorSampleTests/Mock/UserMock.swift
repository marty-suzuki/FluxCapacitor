//
//  UserMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

@testable import FluxCapacitorSample
import GithubKit

extension User {
    static func mock(id: String = "abcdef",
                     avatarUrl: String = "https://github.com/marty-suzuki",
                     followerCount: Int = 100,
                     followingCount: Int = 50,
                     repositoryCount: Int = 10,
                     login: String = "marty-suzuki",
                     url: String = "https://github.com/marty-suzuki") -> User {

        let json: [AnyHashable: Any] = [
            "id" : id,
            "avatarUrl" : avatarUrl,
            "followers" : ["totalCount" : followerCount],
            "following" : ["totalCount" : followingCount],
            "repositories" : ["totalCount" : repositoryCount],
            "login" : login,
            "url" : url,
            ]

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try JSONDecoder().decode(User.self, from: data)
        } catch let e {
            fatalError(e.localizedDescription)
        }
    }
}
