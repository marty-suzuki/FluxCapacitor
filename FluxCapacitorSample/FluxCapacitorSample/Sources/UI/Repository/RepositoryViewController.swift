//
//  RepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by 鈴木大貴 on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import SafariServices
import GithubApiSession

final class RepositoryViewController: SFSafariViewController {
    private let action: RepositoryAction
    private let store: RepositoryStore
    private let repository: Repository

    init?(action: RepositoryAction = .init(),
         store: RepositoryStore = .instantiate(),
         entersReaderIfAvailable: Bool = true) {
        guard let repository = store.selectedRepository else { return nil }
        self.repository = repository
        self.action = action
        self.store = store
        
        super.init(url: repository.url, entersReaderIfAvailable: entersReaderIfAvailable)
        hidesBottomBarWhenPushed = true 
    }

    deinit {
        action.invoke(.selectedRepository(nil))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bookmarkItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = bookmarkItem
    }
}
