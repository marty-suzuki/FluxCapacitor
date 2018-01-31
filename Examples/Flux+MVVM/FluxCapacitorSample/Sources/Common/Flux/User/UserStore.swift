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
import RxSwift
import RxCocoa

final class UserStore: Storable {

    typealias DispatchStateType = Dispatcher.User

    let isUserFetching: Observable<Bool>
    fileprivate let _isUserFetching = BehaviorRelay<Bool>(value: false)

    let users: Observable<[User]>
    fileprivate let _users = BehaviorRelay<[User]>(value: [])

    let selectedUser: Observable<User?>
    fileprivate let _selectedUser = BehaviorRelay<User?>(value: nil)

    let lastPageInfo: Observable<PageInfo?>
    fileprivate let _lastPageInfo = BehaviorRelay<PageInfo?>(value: nil)

    let lastSearchQuery: Observable<String>
    fileprivate let _lastSearchQuery = BehaviorRelay<String>(value: "")

    let userTotalCount: Observable<Int>
    fileprivate let _userTotalCount = BehaviorRelay<Int>(value: 0)

    init() {
        self.isUserFetching = _isUserFetching.asObservable()
        self.users = _users.asObservable()
        self.selectedUser = _selectedUser.asObservable()
        self.lastPageInfo = _lastPageInfo.asObservable()
        self.lastSearchQuery = _lastSearchQuery.asObservable()
        self.userTotalCount = _userTotalCount.asObservable()
    }

    func reduce(with state: Dispatcher.User) {
        switch state {
        case .isUserFetching(let value):
            _isUserFetching.accept(value)
        case .addUsers(let value):
            let users = _users.value
            _users.accept(users + value)
        case .removeAllUsers:
            _users.accept([])
        case .selectedUser(let value):
            _selectedUser.accept(value)
        case .lastPageInfo(let value):
            _lastPageInfo.accept(value)
        case .lastSearchQuery(let value):
            _lastSearchQuery.accept(value)
        case .userTotalCount(let value):
            _userTotalCount.accept(value)
        }
    }
}

extension UserStore {
    struct Value {
        fileprivate let base: UserStore
    }

    var value: Value {
        return Value(base: self)
    }
}

extension UserStore.Value {
    var isUserFetching: Bool {
        return base._isUserFetching.value
    }

    var users: [User] {
        return base._users.value
    }

    var selectedUser: User? {
        return base._selectedUser.value
    }

    var lastPageInfo: PageInfo? {
        return base._lastPageInfo.value
    }

    var lastSearchQuery: String {
        return base._lastSearchQuery.value
    }

    var userTotalCount: Int {
        return base._userTotalCount.value
    }
}
