//
//  UserRepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor

final class UserRepositoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let userAction: UserAction
    private let userStore: UserStore
    private let repositoryAction: RepositoryAction
    private let repositoryStore: RepositoryStore
    private let dustBuster = DustBuster()
    private let dataSource = UserRepositoryViewDataSource()

    init(userAction: UserAction = .init(),
         userStore: UserStore = .instantiate(),
         repositoryAction: RepositoryAction = .init(),
         repositoryStore: RepositoryStore = .instantiate()) {
        self.userAction = userAction
        self.userStore = userStore
        self.repositoryAction = repositoryAction
        self.repositoryStore = repositoryStore

        super.init(nibName: "UserRepositoryViewController", bundle: nil)
    }

    deinit {
        userAction.invoke(.selectedUser(nil))
        repositoryAction.invoke(.removeAllRepositories)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configure(with: tableView)
        observeStore()

        if let user = userStore.selectedUserValue {
            repositoryAction.fetchRepositories(withUserId: user.id, after: nil)
        }
    }

    private func observeStore() {
        repositoryStore.subscribe { [weak self] changes in
            DispatchQueue.main.async {
                switch changes {
                case .addRepositories:
                    print(self?.repositoryStore.repositories ?? [])
                    break
                case .removeAllRepositories:
                    break
                default:
                    return
                }
                self?.tableView.reloadData()
            }
        }
        .cleaned(by: dustBuster)
    }
}
