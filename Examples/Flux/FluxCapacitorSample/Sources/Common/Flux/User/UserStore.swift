//
//  UserStore.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit

final class UserStore: Storable {

    typealias DispatchStateType = Dispatcher.User
    
    let isUserFetching: Constant<Bool>
    fileprivate let _isUserFetching = Variable<Bool>(false)
    
    let users: Constant<[User]>
    fileprivate let _users = Variable<[User]>([])

    let selectedUser: Constant<User?>
    fileprivate let _selectedUser = Variable<User?>(nil)

    let lastPageInfo: Constant<PageInfo?>
    fileprivate let _lastPageInfo = Variable<PageInfo?>(nil)

    let lastSearchQuery: Constant<String>
    fileprivate let _lastSearchQuery = Variable<String>("")
    
    let userTotalCount: Constant<Int>
    fileprivate let _userTotalCount = Variable<Int>(0)
    
    init() {
        self.isUserFetching = Constant(_isUserFetching)
        self.users = Constant(_users)
        self.selectedUser = Constant(_selectedUser)
        self.lastPageInfo = Constant(_lastPageInfo)
        self.lastSearchQuery = Constant(_lastSearchQuery)
        self.userTotalCount = Constant(_userTotalCount)
    }

    func reduce(with state: Dispatcher.User) {
        switch state {
        case .isUserFetching(let value):
            _isUserFetching.value = value
        case .addUsers(let value):
            _users.value.append(contentsOf: value)
        case .removeAllUsers:
            _users.value.removeAll()
        case .selectedUser(let value):
            _selectedUser.value = value
        case .lastPageInfo(let value):
            _lastPageInfo.value = value
        case .lastSearchQuery(let value):
            _lastSearchQuery.value = value
        case .userTotalCount(let value):
            _userTotalCount.value = value
        }
    }
}
