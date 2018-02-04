//
//  FavoriteViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/20.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import FluxCapacitor
import GithubKit

final class FavoriteViewModel {
    private let action: RepositoryAction
    private let store: RepositoryStore
    private let disposeBag = DisposeBag()
    
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    let showRepository: Observable<Void>
    private let _showRepository = PublishSubject<Void>()
    
    let favorites: Constant<[Repository]>
    
    init(action: RepositoryAction = .init(),
         store: RepositoryStore = .instantiate(),
         viewDidAppear: Observable<Void>,
         viewDidDisappear: Observable<Void>,
         selectRepositoryRowAt: Observable<IndexPath>) {
        self.store = store
        self.action = action
        self.favorites = store.favorites

        self.reloadData = _reloadData
        self.showRepository = _showRepository
        
        let selectedRepository = store.selectedRepository.asObservable()
            .filter { $0 != nil }
            .map { _ in }
        Observable.merge(viewDidAppear.map { _ in true },
                         viewDidDisappear.map { _ in false })
            .flatMapLatest { $0 ? selectedRepository : .empty() }
            .bind(to: _showRepository)
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .withLatestFrom(store.favorites.asObservable()) { $1[$0.row] }
            .subscribe(onNext: { [weak self] in
                self?.action.invoke(.selectedRepository($0))
            })
            .disposed(by: disposeBag)
        
        store.favorites.asObservable()
            .map { _ in }
            .bind(to: _reloadData)
            .disposed(by: disposeBag)
    }
    
    deinit {
        store.clear()
    }
}
