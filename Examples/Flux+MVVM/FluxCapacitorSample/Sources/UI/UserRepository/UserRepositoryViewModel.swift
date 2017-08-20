//
//  UserRepositoryViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit
import RxSwift

final class UserRepositoryViewModel {
    private let userAction: UserAction
    private let userStore: UserStore
    private let repositoryAction: RepositoryAction
    private let repositoryStore: RepositoryStore
    private let dustBuster = DustBuster()
    private let disposeBag = DisposeBag()
    private let user: User?
    
    let showRepository: Observable<Void>
    private let _showRepository = PublishSubject<Void>()
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    private let repositoryTotalCount = PublishSubject<Void>()
    let counterText: Observable<String>
    private let _counterText = PublishSubject<String>()
    private let isRepositoryFetchingChanged = PublishSubject<Void>()
    let isRepositoryFetching: Observable<Bool>
    private let _isRepositoryFetching = PublishSubject<Bool>()

    var username: String {
        return user?.login ?? ""
    }
    var repositories: [Repository] {
        return repositoryStore.repositories
    }
    var isRepositoryFetchingValue: Bool {
        return repositoryStore.isRepositoryFetching
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
        self.user = userStore.selectedUserValue
        
        self.showRepository = _showRepository
        self.reloadData = _reloadData
        self.counterText = _counterText
        self.isRepositoryFetching = _isRepositoryFetching
        
        repositoryStore.subscribe { [weak self] in
                switch $0 {
                case .selectedRepository:
                    self?._showRepository.onNext()
                case .isRepositoryFetching:
                    self?.isRepositoryFetchingChanged.onNext()
                    fallthrough
                case .addRepositories,
                     .removeAllRepositories:
                    self?._reloadData.onNext()
                case .repositoryTotalCount:
                    self?.repositoryTotalCount.onNext()
                default:
                    break
                }
            }
            .cleaned(by: dustBuster)
        
        repositoryTotalCount
            .flatMap { [weak self] _ -> Observable<String> in
                guard let store = self?.repositoryStore else { return .empty() }
                return .just("\(store.repositories.count) / \(store.repositoryTotalCount)")
            }
            .bind(to: _counterText)
            .disposed(by: disposeBag)
        
        fetchMoreRepositories
            .subscribe(onNext: { [weak self] in
                guard
                    let me = self,
                    let user = me.user,
                    let pageInfo = me.repositoryStore.lastPageInfo,
                    pageInfo.hasNextPage,
                    let after = pageInfo.endCursor
                else { return }
                me.repositoryAction.fetchRepositories(withUserId: user.id, after: after)
            })
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                let repository = me.repositoryStore.repositories[$0.row]
                me.repositoryAction.invoke(.selectedRepository(repository))
            })
            .disposed(by: disposeBag)
        
        isRepositoryFetchingChanged
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                me._isRepositoryFetching.onNext(me.repositoryStore.isRepositoryFetching)
            })
            .disposed(by: disposeBag)
        
        if let userId = user?.id {
            repositoryAction.fetchRepositories(withUserId: userId, after: nil)
        }
    }
    
    deinit {
        userAction.invoke(.selectedUser(nil))
        repositoryAction.invoke(.removeAllRepositories)
    }
}
