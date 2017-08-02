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
        store.subscribe { [weak self] value in
            DispatchQueue.main.async {
                switch value {
                case .addBookmark,
                     .removeBookmark,
                     .removeAllBookmarks:
                    self?.tableView.reloadData()
                default:
                    break
                }
            }
        }
        .cleaned(by: dustBuster)
    }

    private func observeSelectedRepositoryChanges() {
        store.subscribe { [weak self] value in
            DispatchQueue.main.async {
                switch value {
                case .selectedRepository:
                    self?.showRepository()
                default:
                    break
                }
            }
        }
        .cleaned(by: selectedRepositoryDustBuster)
    }

    private func showRepository() {
        guard let webview = RepositoryViewController() else { return }
        navigationController?.pushViewController(webview, animated: true)
    }
}
