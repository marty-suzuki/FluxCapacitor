//
//  UserRepositoryViewDataSource.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import GithubKit
import FluxCapacitor
import Foundation
import RxSwift

final class UserRepositoryViewDataSource: NSObject {
    fileprivate let loadingView = LoadingView.makeFromNib()
    private let dustBuster = DustBuster()
    
    fileprivate var isReachedBottom: Bool = false {
        didSet {
            if isReachedBottom && isReachedBottom != oldValue {
                _fetchMoreRepositories.onNext(())
            }
        }
    }
    
    let fetchMoreRepositories: Observable<Void>
    private let _fetchMoreRepositories = PublishSubject<Void>()
    let selectRepositoryRowAt: Observable<IndexPath>
    fileprivate let _selectRepositoryRowAt = PublishSubject<IndexPath>()

    fileprivate let viewModel: UserRepositoryViewModel
    
    init(viewModel: UserRepositoryViewModel) {
        self.viewModel = viewModel
        self.fetchMoreRepositories = _fetchMoreRepositories
        self.selectRepositoryRowAt = _selectRepositoryRowAt
        
        super.init()
        
        viewModel.isRepositoryFetching
            .observe(on: .main) { [weak self] in
                self?.loadingView.isLoading = $0
            }
            .cleaned(by: dustBuster)
    }

    func configure(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(RepositoryViewCell.self)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: UITableViewHeaderFooterView.className)
    }
}

extension UserRepositoryViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RepositoryViewCell.self, for: indexPath)
        cell.configure(with: viewModel.repositories.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: UITableViewHeaderFooterView.className) else {
            return nil
        }
        loadingView.removeFromSuperview()
        loadingView.add(to: view)
        return view
    }
}

extension UserRepositoryViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        _selectRepositoryRowAt.onNext(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RepositoryViewCell.calculateHeight(with: viewModel.repositories.value[indexPath.row], and: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.isRepositoryFetching.value ? LoadingView.defaultHeight : .leastNormalMagnitude
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        isReachedBottom = maxScrollDistance <= scrollView.contentOffset.y
    }
}
