//
//  SearchViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift

final class SearchViewController: UIViewController {
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)
    private let action = UserAction()
    private let store = UserStore.instantiate()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        
        observeStore()
        
        action.fetchUsers(withQuery: "marty-suzuki", after: nil)
    }
    
    private func observeStore() {
        store.users
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        store.isUserFetching
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
}
