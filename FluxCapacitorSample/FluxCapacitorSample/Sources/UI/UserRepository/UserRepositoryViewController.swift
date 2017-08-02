//
//  UserRepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

final class UserRepositoryViewController: UIViewController {
    
    private let userStore: UserStore
    private let repositoryAction: RepositoryAction
    private let repositoryStore: RepositoryStore

    init(userStore: UserStore = .instantiate(),
         repositoryAction: RepositoryAction = .init(),
        repositoryStore: RepositoryStore = .instantiate()) {
        self.userStore = userStore
        self.repositoryAction = repositoryAction
        self.repositoryStore = repositoryStore

        super.init(nibName: "UserRepositoryViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observeStore()

        if let user = userStore.selectedUserValue {
            repositoryAction.fetchRepositories(withUserId: user.id, after: nil)
        }
    }

    private func observeStore() {
    }
}
