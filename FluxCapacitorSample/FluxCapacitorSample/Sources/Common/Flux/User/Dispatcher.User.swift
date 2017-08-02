//
//  Dispatcher.User.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubApiSession

extension Dispatcher {
    enum User: DispatchValue {
        case isUserFetching(Bool)
        case addUsers([GithubApiSession.User])
        case userTotalCount(Int)
        case removeAllUsers
        case selectedUser(GithubApiSession.User?)
        case lastPageInfo(PageInfo?)
        case lastSearchQuery(String)
    }
}
