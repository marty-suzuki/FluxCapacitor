//
//  FavoriteViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoriteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let selectRepositoryRowAt = PublishSubject<IndexPath>()
    private let disposeBag = DisposeBag()
    
    private(set) lazy var dataSource: FavoriteViewDataSource = .init(viewModel: self.viewModel)
    private(set) lazy var viewModel: FavoriteViewModel = {
        let viewDidAppear = self.rx
            .methodInvoked(#selector(SearchViewController.viewDidAppear(_:)))
            .map { _ in }
        let viewDidDisappear = self.rx
            .methodInvoked(#selector(SearchViewController.viewDidDisappear(_:)))
            .map { _ in }
       return FavoriteViewModel(viewDidAppear: viewDidAppear,
                                viewDidDisappear: viewDidDisappear,
                                selectRepositoryRowAt: self.selectRepositoryRowAt)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "On Memory Favorite"

        configureDataSource()
        observeViewModel()
    }

    private func configureDataSource() {
        dataSource.selectRepositoryRowAt
            .bind(to: selectRepositoryRowAt)
            .disposed(by: disposeBag)
        dataSource.configure(with: tableView)
    }
    
    private func observeViewModel() {
        viewModel.reloadData
            .bind(to: reloadData)
            .disposed(by: disposeBag)
        
        viewModel.showRepository
            .bind(to: showRepository)
            .disposed(by: disposeBag)
    }
    
    private var reloadData: AnyObserver<Void> {
        return Binder(self) { me, _ in
            me.tableView.reloadData()
        }.asObserver()
    }
    
    private var showRepository: AnyObserver<Void> {
        return Binder(self) { me, _ in
            guard let webview = RepositoryViewController() else { return }
            me.navigationController?.pushViewController(webview, animated: true)
        }.asObserver()
    }
}
