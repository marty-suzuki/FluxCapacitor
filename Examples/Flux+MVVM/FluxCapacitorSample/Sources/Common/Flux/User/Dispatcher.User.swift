//
//  Dispatcher.User.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit

extension Dispatcher {
    enum User: DispatchState {
        typealias RelatedStoreType = UserStore
        typealias RelatedActionType = UserAction

        case isUserFetching(Bool)
        case addUsers([GithubKit.User])
        case userTotalCount(Int)
        case removeAllUsers
        case selectedUser(GithubKit.User?)
        case lastPageInfo(PageInfo?)
        case lastSearchQuery(String)
    }
}
