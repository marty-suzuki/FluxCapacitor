//
//  RepositoryStore.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubApiSession

final class RepositoryStore: Storable {
    typealias DispatchValueType = Dispatcher.Repository
    
    private(set) var isRepositoryFetching = false
    private(set) var bookmarks: [Repository] = []
    private(set) var repositories: [Repository] = []
    private(set) var selectedRepository: Repository? = nil
    
    init(dispatcher: Dispatcher) {
        register { [weak self] in
            switch $0 {
            case .isRepositoryFetching(let value):
                self?.isRepositoryFetching = value
            case .addBookmark(let value):
                self?.bookmarks.append(value)
            case .removeBookmark(let value):
                if let index = self?.bookmarks.index(where: { $0.url == value.url }) {
                    self?.bookmarks.remove(at: index)
                }
            case .selectedRepository(let value):
                self?.selectedRepository = value

            case .removeAllBookmarks:
                self?.bookmarks.removeAll()
            case .addRepositories(let value):
                self?.repositories.append(contentsOf: value)
            case .removeAllRepositories:
                self?.repositories.removeAll()
            }
        }
    }
}