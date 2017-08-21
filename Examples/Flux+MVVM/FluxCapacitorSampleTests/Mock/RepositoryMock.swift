//
//  RepositoryMock.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

@testable import FluxCapacitorSample
import GithubKit

extension Repository {
    static func mock(name: String = "FluxCapacitor",
                     stargazerCount: Int = 100,
                     forkCount: Int = 10,
                     url: String = "https://github.com/marty-suzuki/FluxCapacitor") -> Repository {
        return try! Repository(json: [
            "name" : name,
            "stargazers" : ["totalCount" : stargazerCount],
            "forks" : ["totalCount" : forkCount],
            "url" : url,
            "updatedAt" : "2015-02-07T18:51:47Z"
        ])
    }
}
