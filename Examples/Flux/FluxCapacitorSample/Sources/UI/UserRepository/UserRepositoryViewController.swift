//
//  UserRepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor
import GithubKit

final class UserRepositoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var counterLabel: UILabel!

    private let userAction: UserAction
    private let repositoryAction: RepositoryAction
    private let repositoryStore: RepositoryStore
    private let dustBuster = DustBuster()
    private let dataSource = UserRepositoryViewDataSource()
    private let user: User

    init?(userAction: UserAction = .init(),
          userStore: UserStore = .instantiate(),
          repositoryAction: RepositoryAction = .init(),
          repositoryStore: RepositoryStore = .instantiate()) {
        guard let user = userStore.selectedUser.value else { return nil }
        self.user = user
        self.userAction = userAction
        self.repositoryAction = repositoryAction
        self.repositoryStore = repositoryStore

        super.init(nibName: String(describing: UserRepositoryViewController.self), bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    deinit {
        userAction.invoke(.selectedUser(nil))
        repositoryAction.invoke(.removeAllRepositories)
        repositoryAction.invoke(.lastPageInfo(nil))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(user.login)'s Repositories"
        edgesForExtendedLayout = []

        dataSource.configure(with: tableView)
        observeStore()

        repositoryAction.fetchRepositories(withUserId: user.id, after: nil)
    }

    private func observeStore() {
        repositoryStore.selectedRepository
            .observe(on: .main, changes: { [weak self] _ in
                self?.showRepository()
            })
            .cleaned(by: dustBuster)

        repositoryStore.repositories
            .observe(on: .main, changes: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .cleaned(by: dustBuster)

        repositoryStore.repositoryTotalCount
            .observe(on: .main, changes: { [weak self] _ in
                self?.setTotalCount()
            })
            .cleaned(by: dustBuster)
    }
    
    private func setTotalCount() {
        counterLabel.text = "\(repositoryStore.repositories.value.count) / \(repositoryStore.repositoryTotalCount.value)"
    }

    private func showRepository() {
        guard let webview = RepositoryViewController() else { return }
        navigationController?.pushViewController(webview, animated: true)
    }
}
