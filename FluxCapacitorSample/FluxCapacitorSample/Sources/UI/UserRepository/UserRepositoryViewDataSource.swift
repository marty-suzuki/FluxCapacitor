//
//  UserRepositoryViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

final class UserRepositoryViewDataSource: NSObject {
    private let userStore: UserStore
    fileprivate let repositoryAction: RepositoryAction
    fileprivate let repositoryStore: RepositoryStore

    fileprivate var isReachedBottom: Bool = false {
        didSet {
            if isReachedBottom && isReachedBottom != oldValue {
                guard
                    let user = userStore.selectedUserValue,
                    let pageInfo = repositoryStore.lastPageInfo,
                    pageInfo.hasNextPage,
                    let after = pageInfo.endCursor
                else { return }
                repositoryAction.fetchRepositories(withUserId: user.id, after: after)
            }
        }
    }

    init(userStore: UserStore = .instantiate(),
         repositoryAction: RepositoryAction = .init(),
         repositoryStore: RepositoryStore = .instantiate()) {
        self.userStore = userStore
        self.repositoryAction = repositoryAction
        self.repositoryStore = repositoryStore

        super.init()
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(RepositoryViewCell.nib, forCellReuseIdentifier: RepositoryViewCell.className)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
}

extension UserRepositoryViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryStore.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryViewCell.className, for: indexPath) as? RepositoryViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        }
        cell.configure(with: repositoryStore.repositories[indexPath.row])
        return cell
    }
}

extension UserRepositoryViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let repository = repositoryStore.repositories[indexPath.row]
        repositoryAction.invoke(.selectedRepository(repository))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RepositoryViewCell.defaultHeight
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        isReachedBottom = maxScrollDistance <= scrollView.contentOffset.y
    }
}
