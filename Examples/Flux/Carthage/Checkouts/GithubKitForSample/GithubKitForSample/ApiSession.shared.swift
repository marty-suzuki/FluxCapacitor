//
//  ApiSession.shared.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/11/06.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import GithubKit

extension ApiSession {
    static let shared = ApiSession(injectToken: {
        let token = ""
        guard !token.isEmpty else {
            fatalError("use Personal User Token to request")
        }
        return InjectableToken(token: token)
    })
}
