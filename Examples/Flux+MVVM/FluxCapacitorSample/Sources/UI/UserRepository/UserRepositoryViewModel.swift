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
    private let repositoryTotalCount = PublishSubject<Void>()
    let counterText: Observable<String>
    private let _counterText = PublishSubject<String>()
    
    let isRepositoryFetching: Observable<Bool>
    var isRepositoryFetchingValue: Bool {
        return repositoryStore.isRepositoryFetchingValue
    }
    var username: String {
        return userStore.selectedUserValue?.login ?? ""
    }
    var repositories: [Repository] {
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
        
        fetchMoreRepositories
            .subscribe(onNext: { [weak self] in
                guard
                    let me = self,
                    let user = me.userStore.selectedUserValue,
                    let pageInfo = me.repositoryStore.lastPageInfoValue,
                    pageInfo.hasNextPage,
                    let after = pageInfo.endCursor
                else { return }
                me.repositoryAction.fetchRepositories(withUserId: user.id, after: after)
            })
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                let repository = me.repositoryStore.repositoriesValue[$0.row]
                me.repositoryAction.invoke(.selectedRepository(repository))
            })
            .disposed(by: disposeBag)

        if let userId = userStore.selectedUserValue?.id {
            repositoryAction.fetchRepositories(withUserId: userId, after: nil)
        }
    }
    
    deinit {
        userAction.invoke(.selectedUser(nil))
        repositoryAction.invoke(.removeAllRepositories)
    }
}
