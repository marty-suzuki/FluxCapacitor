//
//  FavoriteViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import GithubKit

final class FavoriteViewDataSource: NSObject {
    fileprivate let viewModel: FavoriteViewModel

    let selectRepositoryRowAt: Observable<IndexPath>
    fileprivate let _selectRepositoryRowAt = PublishSubject<IndexPath>()
    
    init(viewModel: FavoriteViewModel) {
        self.viewModel = viewModel
        self.selectRepositoryRowAt = _selectRepositoryRowAt
        super.init()
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(RepositoryViewCell.self)
    }
}

extension FavoriteViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RepositoryViewCell.self, for: indexPath)
        cell.configure(with: viewModel.favorites.value[indexPath.row])
        return cell
    }
}

extension FavoriteViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        _selectRepositoryRowAt.onNext(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RepositoryViewCell.calculateHeight(with: viewModel.favorites.value[indexPath.row], and: tableView)
    }
}
