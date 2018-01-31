//
//  InjectableBaseURL.swift
//  GithubKit
//
//  Created by marty-suzuki on 2017/11/06.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

struct InjectableBaseURL {
    let url: URL

    init(string: String) throws {
        self.url = try URL(string: string) ?? { throw ApiSession.Error.generateBaseURLFaild }()
    }
}
