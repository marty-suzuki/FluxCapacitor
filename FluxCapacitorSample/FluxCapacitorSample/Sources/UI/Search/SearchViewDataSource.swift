//
//  SearchViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift

final class SearchViewDataSource: NSObject {
    fileprivate let action: UserAction
    fileprivate let store: UserStore

    fileprivate let loadingView = LoadingView.instantiate()
    private let disposeBag = DisposeBag()
    
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
        
        store.isUserFetching
            .bind(to: loadingView.rx.isLoading)
            .disposed(by: disposeBag)
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UserViewCell.nib , forCellReuseIdentifier: UserViewCell.className)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: UITableViewHeaderFooterView.className)
    }
}

extension SearchViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.usersValue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserViewCell.className, for: indexPath) as? UserViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        }
        cell.configure(with: store.usersValue[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: UITableViewHeaderFooterView.className) else {
            return nil
        }
        loadingView.removeFromSuperview()
        loadingView.add(to: view)
        return view
    }
}

extension SearchViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let user = store.usersValue[indexPath.row]
        action.invoke(.selectedUser(user))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserViewCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return store.isUserFetchingValue ? LoadingView.defaultHeight : .leastNormalMagnitude
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        isReachedBottom = maxScrollDistance <= scrollView.contentOffset.y
    }
}
