//
//  UserRepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor
import SafariServices

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

        super.init(nibName: String(describing: UserRepositoryViewController.self), bundle: nil)
        hidesBottomBarWhenPushed = true
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

        title = "Repositories"

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
                case .selectedRepository:
                    self?.showRepository()
                case .addRepositories, .removeAllRepositories:
                    self?.tableView.reloadData()
                default:
                    break
                }
            }
        }
        .cleaned(by: dustBuster)
    }

    private func showRepository() {
        guard let webview = RepositoryViewController() else { return }
        navigationController?.pushViewController(webview, animated: true)
    }
}
