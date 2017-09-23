//
//  UserRepositoryViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import GithubKit
import RxSwift

final class UserRepositoryViewModel {
    private let userAction: UserAction
    private let userStore: UserStore
    private let repositoryAction: RepositoryAction
    private let repositoryStore: RepositoryStore
    private let disposeBag = DisposeBag()
    
    let showRepository: Observable<Void>
    private let _showRepository = PublishSubject<Void>()
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    let counterText: Observable<String>
    private let _counterText = PublishSubject<String>()
    
    let isRepositoryFetching: Observable<Bool>
    var isRepositoryFetchingValue: Bool {
        return repositoryStore.isRepositoryFetchingValue
    }
    var usernameValue: String {
        return userStore.selectedUserValue?.login ?? ""
    }
    var repositoriesValue: [Repository] {
        return repositoryStore.repositoriesValue
    }
    
    init(userAction: UserAction = .init(),
         userStore: UserStore = .instantiate(),
         repositoryAction: RepositoryAction = .init(),
         repositoryStore: RepositoryStore = .instantiate(),
         fetchMoreRepositories: Observable<Void>,
         selectRepositoryRowAt: Observable<IndexPath>) {
        self.userAction = userAction
        self.userStore = userStore
        self.repositoryAction = repositoryAction
        self.repositoryStore = repositoryStore
        
        self.showRepository = _showRepository
        self.reloadData = _reloadData
        self.counterText = _counterText
        self.isRepositoryFetching = repositoryStore.isRepositoryFetching
        
        Observable.merge(repositoryStore.repositories.map { _ in },
                         repositoryStore.isRepositoryFetching.map { _ in })
            .bind(to: _reloadData)
            .disposed(by: disposeBag)
        
        
        repositoryStore.selectedRepository
            .filter { $0 != nil }
            .map { _ in }
            .bind(to: _showRepository)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(repositoryStore.repositories,
                                 repositoryStore.repositoryTotalCount)
            { "\($0.count) / \($1)" }
            .bind(to: _counterText)
            .disposed(by: disposeBag)
        
        let selectedUser = userStore.selectedUser
            .filter { $0 != nil }
            .map { $0! }
        let lastPageInfo = repositoryStore.lastPageInfo
            .filter { $0 != nil }
            .map { $0! }
        fetchMoreRepositories
            .withLatestFrom(Observable.combineLatest(selectedUser, lastPageInfo))
            .subscribe(onNext: { [weak self] user, pageInfo in
                guard pageInfo.hasNextPage, let after = pageInfo.endCursor else { return }
                self?.repositoryAction.fetchRepositories(withUserId: user.id, after: after)
            })
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .withLatestFrom(repositoryStore.repositories) { $1[$0.row] }
            .subscribe(onNext: { [weak self] in
                self?.repositoryAction.invoke(.selectedRepository($0))
            })
            .disposed(by: disposeBag)

        if let userId = userStore.selectedUserValue?.id {
            repositoryAction.fetchRepositories(withUserId: userId, after: nil)
        }
    }
    
    deinit {
        userAction.invoke(.selectedUser(nil))
        repositoryAction.invoke(.removeAllRepositories)
        repositoryAction.invoke(.lastPageInfo(nil))
    }
}
