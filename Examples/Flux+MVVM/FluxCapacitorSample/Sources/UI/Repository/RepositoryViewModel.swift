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
        
        let selectedRepository = store.selectedRepository.asObservable()
            .filter { $0 != nil }
            .map { $0! }
        let containsAndRepository = Observable<(Bool, Repository)>.combineLatest(selectedRepository, store.favorites.asObservable())
            { repo, favs in (favs.contains { $0.url == repo.url }, repo) }
        favoriteButtonItemTap
            .withLatestFrom(containsAndRepository)
            .subscribe(onNext: { [weak self] contains, repository in
                guard let me = self else { return }
                if contains {
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
        
        store.favorites.asObservable()
            .withLatestFrom(selectedRepository) { ($0, $1) }
            .map { favorites, repository in
                let contains = favorites.contains(where: { $0.url == repository.url })
                return contains ? "Remove" : "Add"
            }
            .bind(to: _buttonTitle)
            .disposed(by: disposeBag)
    }
    
    static func selectedURL(from store: RepositoryStore = .instantiate()) -> URL? {
        return store.selectedRepository.value?.url
    }
}
