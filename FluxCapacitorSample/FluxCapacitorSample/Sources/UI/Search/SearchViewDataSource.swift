//
//  SearchViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

final class SearchViewDataSource: NSObject {
    fileprivate let action: UserAction
    fileprivate let store: UserStore

    fileprivate var isReachedBottom: Bool = false {
        didSet {
            if isReachedBottom && isReachedBottom != oldValue {
                let query = store.lastSearchQueryValue
                guard
                    !query.isEmpty,
                    let pageInfo = store.lastPageInfoValue,
                    pageInfo.hasNextPage,
                    let after = pageInfo.endCursor
                else { return }
                action.fetchUsers(withQuery: query, after: after)
            }
        }
    }

    init(action: UserAction = .init(), store: UserStore = .instantiate()) {
        self.action = action
        self.store = store

        super.init()
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
}

extension SearchViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.usersValue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = store.usersValue[indexPath.row].login
        return cell
    }
}

extension SearchViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let user = store.usersValue[indexPath.row]
        action.invoke(.selectedUser(user))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        isReachedBottom = maxScrollDistance <= scrollView.contentOffset.y
    }
}
