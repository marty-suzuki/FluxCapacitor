//
//  UserRepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UserRepositoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var counterLabel: UILabel!

    private let disposeBag = DisposeBag()
    private let fetchMoreRepositories = PublishSubject<Void>()
    private let selectRepositoryRowAt = PublishSubject<IndexPath>()
    
    private(set) lazy var dataSource: UserRepositoryViewDataSource = .init(viewModel: self.viewModel)
    private(set) lazy var viewModel: UserRepositoryViewModel = {
        return .init(fetchMoreRepositories: self.fetchMoreRepositories,
                     selectRepositoryRowAt: self.selectRepositoryRowAt)
    }()

    init() {
        super.init(nibName: String(describing: UserRepositoryViewController.self), bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(viewModel.usernameValue)'s Repositories"
        edgesForExtendedLayout = []

        configureDataSource()
        observeViewModel()
    }
    
    private func configureDataSource() {
        dataSource.fetchMoreRepositories
            .bind(to: fetchMoreRepositories)
            .disposed(by: disposeBag)
        dataSource.selectRepositoryRowAt
            .bind(to: selectRepositoryRowAt)
            .disposed(by: disposeBag)
        dataSource.configure(with: tableView)
    }
    
    private func observeViewModel() {
        viewModel.counterText
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.showRepository
            .bind(to: showRepository)
            .disposed(by: disposeBag)
        
        viewModel.reloadData
            .bind(to: reloadData)
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
