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
    private let dustBuster = DustBuster()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite"
        
        observeStoreChanges()
    }
    
    private func observeStoreChanges() {
        store.subscribe { [weak self] value in
            DispatchQueue.main.async {
                switch value {
                case .addBookmark, .removeBookmark, .removeAllBookmarks:
                    self?.tableView.reloadData()
                default:
                    break
                }
            }
        }
        .cleaned(by: dustBuster)
    }
}
