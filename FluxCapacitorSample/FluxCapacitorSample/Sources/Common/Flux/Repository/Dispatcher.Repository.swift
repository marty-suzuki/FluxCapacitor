//
//  Dispatcher.Repository.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubApiSession

extension Dispatcher {
    enum Repository: DispatchValue {
        case isRepositoryFetching(Bool)
        case addRepositories([GithubApiSession.Repository])
        case removeAllRepositories
        case selectedRepository(GithubApiSession.Repository?)
        
        case addBookmark(GithubApiSession.Repository)
        case removeBookmark(GithubApiSession.Repository)
        case removeAllBookmarks
    }
}
