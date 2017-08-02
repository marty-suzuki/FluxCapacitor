//
//  SearchViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let action = UserAction()
    private let store = UserStore.instantiate()
    private let disposeBag = DisposeBag()
    private let dataSource = SearchViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar

        dataSource.configure(with: tableView)
        observeUI()
        observeStore()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    private func observeUI() {
        searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.action.invoke(.removeAllUsers)
                self?.action.invoke(.lastPageInfo(nil))
                self?.action.invoke(.lastSearchQuery(""))
                self?.action.fetchUsers(withQuery: text, after: nil)
            })
            .disposed(by: disposeBag)

        Observable.merge(searchBar.rx.cancelButtonClicked.asObservable(),
                         searchBar.rx.searchButtonClicked.asObservable())
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] in
                self?.searchBar.showsCancelButton = true
            })
            .disposed(by: disposeBag)

        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { [weak self] in
                self?.searchBar.showsCancelButton = false
            })
            .disposed(by: disposeBag)
    }

    private func observeStore() {
        store.users
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        store.isUserFetching
            .subscribe(onNext: {
                _ = $0
            })
            .disposed(by: disposeBag)

        store.selectedUesr
            .filter { $0 != nil }
            .map { _ in  }
            .bind(to: showUserRepository)
            .disposed(by: disposeBag)
    }

    private var showUserRepository: AnyObserver<Void> {
        return UIBindingObserver(UIElement: self) { me, _ in
            let vc = UserRepositoryViewController()
            me.navigationController?.pushViewController(vc, animated: true)
        }.asObserver()
    }
}
