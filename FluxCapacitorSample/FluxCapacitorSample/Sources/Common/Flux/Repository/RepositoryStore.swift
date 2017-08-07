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

final class RepositoryStore: Storable {
    typealias DispatchValueType = Dispatcher.Repository
    
    private(set) var isRepositoryFetching = false
    private(set) var favorites: [Repository] = []
    private(set) var repositories: [Repository] = []
    private(set) var selectedRepository: Repository? = nil
    private(set) var lastPageInfo: PageInfo? = nil
    private(set) var lastTask: URLSessionTask? = nil
    private(set) var repositoryTotalCount: Int = 0

    init(dispatcher: Dispatcher) {
        register { [weak self] in
            switch $0 {
            case .isRepositoryFetching(let value):
                self?.isRepositoryFetching = value
            case .addRepositories(let value):
                self?.repositories.append(contentsOf: value)
            case .removeAllRepositories:
                self?.repositories.removeAll()
            case .selectedRepository(let value):
                self?.selectedRepository = value
            case .lastPageInfo(let value):
                self?.lastPageInfo = value
            case .lastTask(let value):
                self?.lastTask?.cancel()
                self?.lastTask = value
            case .repositoryTotalCount(let value):
                self?.repositoryTotalCount = value

            case .addFavorite(let value):
                if self?.favorites.index(where: { $0.url == value.url }) == nil {
                    self?.favorites.append(value)
                }
            case .removeFavorite(let value):
                if let index = self?.favorites.index(where: { $0.url == value.url }) {
                    self?.favorites.remove(at: index)
                }
            case .removeAllFavorites:
                self?.favorites.removeAll()
            }
        }
    }
}
