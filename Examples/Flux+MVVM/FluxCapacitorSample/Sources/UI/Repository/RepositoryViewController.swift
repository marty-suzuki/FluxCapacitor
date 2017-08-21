//
//  RepositoryViewController.swift
//  FluxCapacitorSample
//
//  Created by 鈴木大貴 on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

final class RepositoryViewController: SFSafariViewController {
    private let favoriteButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    private let disposeBag = DisposeBag()
    private(set) lazy var viewModel: RepositoryViewModel = {
        let viewDidDisappear = self.rx
            .methodInvoked(#selector(RepositoryViewController.viewDidDisappear(_:)))
            .map { _ in }
        return .init(viewDidDisappear: viewDidDisappear,
                     favoriteButtonItemTap: self.favoriteButtonItem.rx.tap)
    }()
    
    init?(entersReaderIfAvailable: Bool = true) {
        guard let url = RepositoryViewModel.selectedURL() else { return nil }
        super.init(url: url, entersReaderIfAvailable: entersReaderIfAvailable)
        hidesBottomBarWhenPushed = true 
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = favoriteButtonItem
        observeViewModel()
    }
    
    private func observeViewModel() {
        viewModel.buttonTitle
            .bind(to: favoriteButtonItem.rx.title)
            .disposed(by: disposeBag)
    }
}
