//
//  RepositoryViewModel.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import GithubKit
import RxSwift
import RxCocoa

final class RepositoryViewModel {
    private let action: RepositoryAction
    private let store: RepositoryStore
    private let disposeBag = DisposeBag()

    let buttonTitle: Observable<String>
    private let _buttonTitle = BehaviorSubject<String>(value: "")
    
    init(action: RepositoryAction = .init(),
         store: RepositoryStore = .instantiate(),
         viewDidDisappear: Observable<Void>,
         favoriteButtonItemTap: ControlEvent<Void>) {
        self.action = action
        self.store = store
        self.buttonTitle = _buttonTitle
        
        let selectedRepository = store.selectedRepository
            .filter { $0 != nil }
            .map { $0! }
        
        favoriteButtonItemTap
            .withLatestFrom(selectedRepository)
            .subscribe(onNext: { [weak self] repository in
                guard let me = self else { return }
                if me.store.favoritesValue.contains(where: { $0.url == repository.url }) {
                    me.action.invoke(.removeFavorite(repository))
                } else {
                    me.action.invoke(.addFavorite(repository))
                }
            })
            .disposed(by: disposeBag)
        
        viewDidDisappear
            .subscribe(onNext: { [weak self] in
                self?.action.invoke(.selectedRepository(nil))
            })
            .disposed(by: disposeBag)
        
        store.favorites
            .withLatestFrom(selectedRepository) { $0 }
            .map { favorites, repository in
                let contains = favorites.contains(where: { $0.url == repository.url })
                return contains ? "Remove" : "Add"
            }
            .bind(to: _buttonTitle)
            .disposed(by: disposeBag)
    }
    
    static func selectedURL(from store: RepositoryStore = .instantiate()) -> URL? {
        return store.selectedRepositoryValue?.url
    }
}
