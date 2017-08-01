//
//  UserAction.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubApiSession
import RxSwift

final class UserAction: Actionable {
    typealias DispatchValueType = Dispatcher.User
    
    private let session: ApiSession
    private var disposeBag = DisposeBag()
    
    init(session: ApiSession = .shared) {
        self.session = session
    }
    
    func fetchUsers(withQuery query: String, after: String?) {
        disposeBag = DisposeBag()
        invoke(.isUserFetching(true))
        let request = SearchUserRequest(query: query, after: after)
        session.rx.send(request)
            .map { $0.nodes }
            .subscribe(onNext: { [weak self] in
                self?.invoke(.addUsers($0))
            }, onDisposed: { [weak self] in
                self?.invoke(.isUserFetching(false))
            })
            .disposed(by: disposeBag)
    }
}
