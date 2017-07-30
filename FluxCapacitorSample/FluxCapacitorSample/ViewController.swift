//
//  ViewController.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/07/29.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor

class ViewController: UIViewController {

    var store: SearchStore? = SearchStore()
    let action = SearchAction()
    
    var dustBuster = DustBuster()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let store = SearchStore.instantiate()
        
        store.subscribe { type in
            switch type {
            case .isLoading:
                print("isLoading changed")
            case .query:
                print("query changed")
            }
        }
        .cleaned(by: dustBuster)
        
        self.store = store
        
        action.invoke(.isLoading(true))
        
        print("\(store.isLoading)")
        
        let store2 = SearchStore.instantiate()
        
        print("\(store2.isLoading)")
        
        print("\(store.query as String?)")
        
        action.invoke(.query("hogehoge"))
        
        print("\(store.query as String?)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dustBuster = DustBuster()
        
        action.invoke(.query("hogehogehoge"))
        
        print("\(store?.query as String?)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Dispatcher {
    enum Search: DispatchValue {
        case isLoading(Bool)
        case query(String?)
    }
}

final class SearchAction: Actionable {
    typealias DispatchValueType = Dispatcher.Search
}

final class SearchStore: Storable {
    typealias DispatchValueType = Dispatcher.Search
    
    private(set) var isLoading = false
    private(set) var query: String? = nil
    
    deinit {
        unregister()
    }
    
    required init() {
        register { [weak self] dispatchValue in
            switch dispatchValue {
            case .isLoading(let value):
                self?.isLoading = value
            case .query(let value):
                self?.query = value
            }
        }
    }
}
