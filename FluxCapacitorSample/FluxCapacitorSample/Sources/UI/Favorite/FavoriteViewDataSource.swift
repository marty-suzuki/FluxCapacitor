//
//  FavoriteViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import UIKit

final class FavoriteViewDataSource: NSObject {
    fileprivate let store: RepositoryStore
    fileprivate let action: RepositoryAction

    init(action: RepositoryAction = .init(), store: RepositoryStore = .instantiate()) {
        self.action = action
        self.store = store
        super.init()
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(RepositoryViewCell.nib, forCellReuseIdentifier: RepositoryViewCell.className)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
}

extension FavoriteViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.bookmarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryViewCell.className, for: indexPath) as? RepositoryViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        }
        cell.configure(with: store.bookmarks[indexPath.row])
        return cell
    }
}

extension FavoriteViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let repository = store.bookmarks[indexPath.row]
        action.invoke(.selectedRepository(repository))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RepositoryViewCell.defaultHeight
    }
}
