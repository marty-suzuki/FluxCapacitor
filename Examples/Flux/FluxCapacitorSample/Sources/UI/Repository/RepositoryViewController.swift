//
//  RepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by 鈴木大貴 on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import SafariServices
import GithubKit

final class RepositoryViewController: SFSafariViewController {
    private(set) lazy var favoriteButtonItem: UIBarButtonItem = {
        let title = self.store.favorites.value.contains(where: { $0.url == self.repository.url }) ? "Remove" : "Add"
        return UIBarButtonItem(title: title,
                               style: .plain,
                               target: self,
                               action: #selector(RepositoryViewController.favoriteButtonTap(_:)))
    }()

    private let action: RepositoryAction
    private let store: RepositoryStore
    private let repository: Repository

    init?(action: RepositoryAction = .init(),
          store: RepositoryStore = .instantiate(),
          entersReaderIfAvailable: Bool = true) {
        guard let repository = store.selectedRepository.value else { return nil }
        self.repository = repository
        self.action = action
        self.store = store
        
        super.init(url: repository.url, entersReaderIfAvailable: entersReaderIfAvailable)
        hidesBottomBarWhenPushed = true 
    }

    deinit {
        action.invoke(.selectedRepository(nil))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = favoriteButtonItem
    }

    @objc private func favoriteButtonTap(_ sender: UIBarButtonItem) {
        if store.favorites.value.contains(where: { $0.url == repository.url }) {
            action.invoke(.removeFavorite(repository))
            favoriteButtonItem.title = "Add"
        } else {
            action.invoke(.addFavorite(repository))
            favoriteButtonItem.title = "Remove"
        }
    }
}
