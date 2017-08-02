//
//  UserRepositoryViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

final class UserRepositoryViewDataSource: NSObject {
    fileprivate let action: RepositoryAction
    fileprivate let store: RepositoryStore

    init(action: RepositoryAction = .init(), store: RepositoryStore = .instantiate()) {
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

extension UserRepositoryViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
    }
}

extension UserRepositoryViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
