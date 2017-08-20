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
    private let dustBuster = DustBuster()
    private var selectedRepositoryDustBuster = DustBuster()
    
    let reloadData: Observable<Void>
    private let _reloadData = PublishSubject<Void>()
    let showRepository: Observable<Void>
    private let _showRepository = PublishSubject<Void>()
    
    var favorites: [Repository] {
        return store.favorites
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
        
        viewDidAppear
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                me.store.subscribe { [weak self] in
                    switch $0 {
                    case .selectedRepository:
                        self?._showRepository.onNext()
                    default:
                        break
                    }
                }
                .cleaned(by: me.selectedRepositoryDustBuster)
            })
            .disposed(by: disposeBag)
        
        viewDidDisappear
            .subscribe(onNext: { [weak self] in
                self?.selectedRepositoryDustBuster = DustBuster()
            })
            .disposed(by: disposeBag)
        
        selectRepositoryRowAt
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                let repository = me.store.favorites[$0.row]
                me.action.invoke(.selectedRepository(repository))
            })
            .disposed(by: disposeBag)
        
        store.subscribe { [weak self] value in
                switch value {
                case .addFavorite,
                     .removeFavorite,
                     .removeAllFavorites:
                    self?._reloadData.onNext()
                default:
                    break
                }
            }
            .cleaned(by: dustBuster)
    }
}
