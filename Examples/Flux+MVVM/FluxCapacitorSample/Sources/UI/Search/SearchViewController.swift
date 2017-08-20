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
import NoticeObserveKit

final class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var counterLabel: UILabel!
    
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)

    private let disposeBag = DisposeBag()
    private let selectUserRowAt = PublishSubject<IndexPath>()
    private let fetchMoreUsers = PublishSubject<Void>()
    
    private(set) lazy var dataSource: SearchViewDataSource = .init(viewModel: self.viewModel)
    private(set) lazy var viewModel: SearchViewModel = {
        let viewWillAppear = self.rx
            .methodInvoked(#selector(SearchViewController.viewWillAppear(_:)))
            .map { _ in }
        let viewWillDisappear = self.rx
            .methodInvoked(#selector(SearchViewController.viewWillDisappear(_:)))
            .map { _ in }
        return .init(viewWillAppear: viewWillAppear,
                     viewWillDisappear: viewWillDisappear,
                     searchText: self.searchBar.rx.text.orEmpty,
                     selectUserRowAt: self.selectUserRowAt,
                     fetchMoreUsers: self.fetchMoreUsers)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        searchBar.placeholder = "Input user name"
        tableView.contentInset.top = 44
        
        configureDataSource()
        observeUI()
        observeViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    private func configureDataSource() {
        dataSource.selectUserRowAt
            .bind(to: selectUserRowAt)
            .disposed(by: disposeBag)
        dataSource.fetchMoreUsers
            .bind(to: fetchMoreUsers)
            .disposed(by: disposeBag)
        dataSource.configure(with: tableView)
    }

    private func observeViewModel() {
        viewModel.keyboardWillShow
            .bind(to: keyboardWillShow)
            .disposed(by: disposeBag)

        viewModel.keyboardWillHide
            .bind(to: keyboardWillHide)
            .disposed(by: disposeBag)
        
        viewModel.showUserRepository
            .bind(to: showUserRepository)
            .disposed(by: disposeBag)
        
        viewModel.counterText
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.reloadData
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func observeUI() {
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
    
    private var keyboardWillShow: AnyObserver<UIKeyboardInfo> {
        return UIBindingObserver(UIElement: self) { me, keyboardInfo in
            me.view.layoutIfNeeded()
            let extra = me.tabBarController?.tabBar.bounds.height ?? 0
            me.tableViewBottomConstraint.constant = keyboardInfo.frame.size.height - extra
            UIView.animate(withDuration: keyboardInfo.animationDuration,
                           delay: 0,
                           options: keyboardInfo.animationCurve,
                           animations: {
                me.view.layoutIfNeeded()
            }, completion: nil)
        }.asObserver()
    }
    
    private var keyboardWillHide: AnyObserver<UIKeyboardInfo> {
        return UIBindingObserver(UIElement: self) { me, keyboardInfo in
            me.view.layoutIfNeeded()
            me.tableViewBottomConstraint.constant = 0
            UIView.animate(withDuration: keyboardInfo.animationDuration,
                           delay: 0,
                           options: keyboardInfo.animationCurve,
                           animations: {
                me.view.layoutIfNeeded()
            }, completion: nil)
        }.asObserver()
    }

    private var showUserRepository: AnyObserver<Void> {
        return UIBindingObserver(UIElement: self) { me, _ in
            let vc = UserRepositoryViewController()
            me.navigationController?.pushViewController(vc, animated: true)
        }.asObserver()
    }
}
