//
//  FavoriteViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/20.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import RxSwift
import GithubKit

final class FavoriteViewModel {
    private let action: RepositoryAction
    private let store: RepositoryStore
    private let disposeBag = DisposeBag()
    
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    let showRepository: Observable<Void>
    private let _showRepository = PublishSubject<Void>()
    
    var favorites: [Repository] {
        return store.favoritesValue
    }
    
    init(action: RepositoryAction = .init(),
         store: RepositoryStore = .instantiate(),
         viewDidAppear: Observable<Void>,
         viewDidDisappear: Observable<Void>,
         selectRepositoryRowAt: Observable<IndexPath>) {
        self.store = store
        self.action = action
        
        self.reloadData = _reloadData
        self.showRepository = _showRepository
        
        Observable.merge(viewDidAppear.map { _ in true },
                         viewDidDisappear.map { _ in false })
            .flatMapLatest { [weak self] shouldSubscribe -> Observable<Void> in
                guard shouldSubscribe, let me = self else { return .empty() }
                return me.store.selectedRepository
                    .map { _ in }
            }
            .bind(to: _showRepository)
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                let repository = me.store.favoritesValue[$0.row]
                me.action.invoke(.selectedRepository(repository))
            })
            .disposed(by: disposeBag)
        
        store.favorites
            .map { _ in }
            .bind(to: _reloadData)
            .disposed(by: disposeBag)
    }
}
