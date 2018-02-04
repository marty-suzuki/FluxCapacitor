//
//  FavoriteViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor

final class FavoriteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let aciont = RepositoryAction()
    private let store = RepositoryStore.instantiate()
    private let dataSource = FavoriteViewDataSource()
    private let dustBuster = DustBuster()
    private var selectedRepositoryDustBuster = DustBuster()
    
    deinit {
        store.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "On Memory Favorite"

        dataSource.configure(with: tableView)
        observeBookmarkChanges()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeSelectedRepositoryChanges()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedRepositoryDustBuster = DustBuster()
    }
    
    private func observeBookmarkChanges() {
        store.favorites
            .observe(on: .main, changes: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .cleaned(by: dustBuster)
    }

    private func observeSelectedRepositoryChanges() {
        store.selectedRepository
            .observe(on: .main, changes: { [weak self] _ in
                self?.showRepository()
            })
            .cleaned(by: selectedRepositoryDustBuster)
    }

    private func showRepository() {
        guard let webview = RepositoryViewController() else { return }
        navigationController?.pushViewController(webview, animated: true)
    }
}
