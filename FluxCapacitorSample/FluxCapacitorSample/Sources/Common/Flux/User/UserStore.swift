//
//  UserStore.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubApiSession
import RxSwift

final class UserStore: Storable {
    typealias DispatchValueType = Dispatcher.User
    
    let isUserFetching: Observable<Bool>
    var isUserFetchingValue: Bool {
        return _isUserFetching.value
    }
    private let _isUserFetching = Variable<Bool>(false)
    
    let users: Observable<[User]>
    var usersValue: [User] {
        return _users.value
    }
    private let _users = Variable<[User]>([])
    
    init(dispatcher: Dispatcher) {
        self.isUserFetching = _isUserFetching.asObservable()
        self.users = _users.asObservable()
        
        register { [weak self] in
            switch $0 {
            case .isUserFetching(let value):
                self?._isUserFetching.value = value
            case .addUsers(let value):
                self?._users.value.append(contentsOf: value)
            case .removeAllUsers:
                self?._users.value.removeAll()
            }
        }
    }
}
