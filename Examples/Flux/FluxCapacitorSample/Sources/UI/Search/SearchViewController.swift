//
//  SearchViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import NoticeObserveKit
import FluxCapacitor
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var counterLabel: UILabel!
    
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let action = UserAction()
    private let store = UserStore.instantiate()
    private let dataSource = SearchViewDataSource()
    private let dustBuster = DustBuster()
    private let disposeBag = DisposeBag()
    private var pool = NoticeObserverPool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        searchBar.placeholder = "Input user name"
        tableView.contentInset.top = 44
        
        dataSource.configure(with: tableView)
        observeUI()
        observeStore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        pool = NoticeObserverPool()
    }

    private func observeKeyboard() {
        UIKeyboardWillShow.observe { [weak self] in
            self?.view.layoutIfNeeded()
            let extra = self?.tabBarController?.tabBar.bounds.height ?? 0
            self?.tableViewBottomConstraint.constant = $0.frame.size.height - extra
            UIView.animate(withDuration: $0.animationDuration, delay: 0, options: $0.animationCurve, animations: {
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        .disposed(by: pool)

        UIKeyboardWillHide.observe { [weak self] in
            self?.view.layoutIfNeeded()
            self?.tableViewBottomConstraint.constant = 0
            UIView.animate(withDuration: $0.animationDuration, delay: 0, options: $0.animationCurve, animations: {
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        .disposed(by: pool)
    }

    private func observeUI() {
        searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.action.invoke(.removeAllUsers)
                self?.action.invoke(.lastPageInfo(nil))
                self?.action.invoke(.lastSearchQuery(""))
                self?.action.invoke(.userTotalCount(0))
                self?.action.fetchUsers(withQuery: text, after: nil)
            })
            .disposed(by: disposeBag)

        Observable.merge(searchBar.rx.cancelButtonClicked.asObservable(),
                         searchBar.rx.searchButtonClicked.asObservable())
            .bind(to: resignFirstResponder)
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing
            .map { true }
            .bind(to: showsCancelButton)
            .disposed(by: disposeBag)

        searchBar.rx.textDidEndEditing
            .map { false }
            .bind(to: showsCancelButton)
            .disposed(by: disposeBag)
    }

    private func observeStore() {
        store.users
            .observe(on: .main) { [weak self] _ in
                self?.tableView.reloadData()
            }
            .cleaned(by: dustBuster)

        store.isUserFetching
            .observe(on: .main) { [weak self] _ in
                self?.tableView.reloadData()
            }
            .cleaned(by: dustBuster)

        store.selectedUser
            .observe(on: .main) { [weak self] in
                guard let me = self, $0 != nil else { return }
                guard let vc = UserRepositoryViewController() else { return }
                me.navigationController?.pushViewController(vc, animated: true)
            }
            .cleaned(by: dustBuster)

        store.users
            .observe(on: .main) { [weak self] _ in
                self?.updateCountLabel()
            }
            .cleaned(by: dustBuster)

        store.userTotalCount
            .observe(on: .main) { [weak self] _ in
                self?.updateCountLabel()
            }
            .cleaned(by: dustBuster)
    }

    private func updateCountLabel() {
        counterLabel.text = "\(store.users.value.count) / \(store.userTotalCount.value)"
    }
    
    private var resignFirstResponder: AnyObserver<Void> {
        return Binder(self) { me, _ in
            me.searchBar.resignFirstResponder()
        }.asObserver()
    }
    
    private var showsCancelButton: AnyObserver<Bool> {
        return Binder(self) { me, showsCancelButton in
            me.searchBar.showsScopeBar = showsCancelButton
        }.asObserver()
    }
}
