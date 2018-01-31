//
//  SearchViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/20.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NoticeObserveKit
import GithubKit

final class SearchViewModel {
    private let disposeBag = DisposeBag()
    private var pool = NoticeObserverPool()
    private let action: UserAction
    private let store: UserStore
    
    let isUserFetching: Observable<Bool>
    var isUserFetchingValue: Bool {
        return store.value.isUserFetching
    }
    
    let keyboardWillShow: Observable<UIKeyboardInfo>
    private let _keyboardWillShow = PublishSubject<UIKeyboardInfo>()
    let keyboardWillHide: Observable<UIKeyboardInfo>
    private let _keyboardWillHide = PublishSubject<UIKeyboardInfo>()
    
    let showUserRepository: Observable<Void>
    private let _showUserRepository = PublishSubject<Void>()
    let counterText: Observable<String>
    private let _counterText = PublishSubject<String>()
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    
    var usersValue: [User] {
        return store.value.users
    }
    
    init(action: UserAction = .init(),
         store: UserStore = .instantiate(),
         viewWillAppear: Observable<Void>,
         viewWillDisappear: Observable<Void>,
         searchText: ControlProperty<String>,
         selectUserRowAt: Observable<IndexPath>,
         fetchMoreUsers: Observable<Void>) {
        self.action = action
        self.store = store
        
        self.isUserFetching = store.isUserFetching
        self.keyboardWillShow = _keyboardWillShow
        self.keyboardWillHide = _keyboardWillHide
        self.showUserRepository = _showUserRepository
        self.counterText = _counterText
        self.reloadData = _reloadData
        
        viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                UIKeyboardWillShow.observe { [weak self] in
                    self?._keyboardWillShow.onNext($0)
                }
                .disposed(by: me.pool)
                
                UIKeyboardWillHide.observe { [weak self] in
                    self?._keyboardWillHide.onNext($0)
                }
                .disposed(by: me.pool)
            })
            .disposed(by: disposeBag)
        
        viewWillDisappear
            .subscribe(onNext: { [weak self] in
                self?.pool = NoticeObserverPool()
            })
            .disposed(by: disposeBag)
        
        searchText
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.action.invoke(.removeAllUsers)
                self?.action.invoke(.lastPageInfo(nil))
                self?.action.invoke(.lastSearchQuery(""))
                self?.action.invoke(.userTotalCount(0))
                self?.action.fetchUsers(withQuery: text, after: nil)
            })
            .disposed(by: disposeBag)
        
        selectUserRowAt
            .withLatestFrom(store.users) { $1[$0.row] }
            .subscribe(onNext: { [weak self] in
                self?.action.invoke(.selectedUser($0))
            })
            .disposed(by: disposeBag)
        
        let lastSearchQuery = store.lastSearchQuery
            .filter { !$0.isEmpty }
        let lastPageInfo = store.lastPageInfo
            .filter { $0 != nil }
            .map { $0! }
        fetchMoreUsers
            .withLatestFrom(Observable.combineLatest(lastSearchQuery, lastPageInfo))
            .subscribe(onNext: { [weak self] query, pageInfo in
                guard pageInfo.hasNextPage, let after = pageInfo.endCursor else { return }
                self?.action.fetchUsers(withQuery: query, after: after)
            })
            .disposed(by: disposeBag)
        
        store.selectedUser
            .filter { $0 != nil }
            .map { _ in }
            .bind(to: _showUserRepository)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(store.users, store.userTotalCount)
            .map { "\($0.count) / \($1)" }
            .bind(to: _counterText)
            .disposed(by: disposeBag)
        
        Observable.merge(store.users.map { _ in },
                         store.isUserFetching.map { _ in })
            .bind(to: _reloadData)
            .disposed(by: disposeBag)
    }
}
