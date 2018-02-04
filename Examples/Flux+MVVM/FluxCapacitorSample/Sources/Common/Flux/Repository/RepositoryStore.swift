//
//  RepositoryStore.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit
import RxSwift

final class RepositoryStore: Storable {

    typealias DispatchStateType = Dispatcher.Repository

    let isRepositoryFetching: Constant<Bool>
    private let _isRepositoryFetching = FluxCapacitor.Variable<Bool>(false)

    let favorites: Constant<[Repository]>
    private let _favorites = FluxCapacitor.Variable<[Repository]>([])

    let repositories: Constant<[Repository]>
    private let _repositories = FluxCapacitor.Variable<[Repository]>([])

    let selectedRepository: Constant<Repository?>
    private let _selectedRepository = FluxCapacitor.Variable<Repository?>(nil)

    let lastPageInfo: Constant<PageInfo?>
    private let _lastPageInfo = FluxCapacitor.Variable<PageInfo?>(nil)

    let lastTask: Constant<URLSessionTask?>
    private let _lastTask = FluxCapacitor.Variable<URLSessionTask?>(nil)

    let repositoryTotalCount: Constant<Int>
    private let _repositoryTotalCount = FluxCapacitor.Variable<Int>(0)

    init() {
        self.isRepositoryFetching = Constant(_isRepositoryFetching)
        self.favorites = Constant(_favorites)
        self.repositories = Constant(_repositories)
        self.selectedRepository = Constant(_selectedRepository)
        self.lastPageInfo = Constant(_lastPageInfo)
        self.lastTask = Constant(_lastTask)
        self.repositoryTotalCount = Constant(_repositoryTotalCount)
    }

    func reduce(with state: Dispatcher.Repository) {
        switch state {
        case .isRepositoryFetching(let value):
            _isRepositoryFetching.value = value

        case .addRepositories(let value):
            _repositories.value.append(contentsOf: value)

        case .removeAllRepositories:
            _repositories.value.removeAll()

        case .selectedRepository(let value):
            _selectedRepository.value = value

        case .lastPageInfo(let value):
            _lastPageInfo.value = value

        case .lastTask(let value):
            _lastTask.value?.cancel()
            _lastTask.value = value

        case .repositoryTotalCount(let value):
            _repositoryTotalCount.value = value

        case .addFavorite(let value):
            if _favorites.value.index(where: { $0.url == value.url }) == nil {
                _favorites.value.append(value)
            }
        case .removeFavorite(let value):
            if let index = _favorites.value.index(where: { $0.url == value.url }) {
                _favorites.value.remove(at: index)
            }
        case .removeAllFavorites:
            _favorites.value.removeAll()
        }
    }
}

extension PrimitiveValue where Trait == ImmutableTrait {
    func asObservable() -> Observable<Element> {
        return Observable.create { [weak self] observer in
            let dust = self?.observe { observer.onNext($0) }
            return Disposables.create { dust?.clean() }
        }
    }
}
