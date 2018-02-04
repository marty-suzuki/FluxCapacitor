//
//  FavoriteViewModelTestCase.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/23.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import FluxCapacitorSample
import RxSwift
import RxCocoa
import GithubKit

class FavoriteViewModelTestCase: XCTestCase {
    
    var action: RepositoryAction!
    var store: RepositoryStore!
    var mock: ApiSessionMock!
    var viewModel: FavoriteViewModel!
    var viewDidAppear = PublishSubject<Void>()
    var viewDidDisappear = PublishSubject<Void>()
    var selectRepositoryRowAt = PublishSubject<IndexPath>()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.mock = ApiSessionMock()
        self.action = RepositoryAction(session: mock)
        self.store = RepositoryStore.instantiate()
        self.viewModel = FavoriteViewModel(action: action,
                                           store: store,
                                           viewDidAppear: viewDidAppear,
                                           viewDidDisappear: viewDidDisappear,
                                           selectRepositoryRowAt: selectRepositoryRowAt)
    }

    func testReloadData() {
        let expectation = self.expectation(description: "testReloadData expectation")
        
        let disposable = viewModel.reloadData
            .subscribe(onNext: {
                expectation.fulfill()
            })
        
        action.invoke(.addFavorite(Repository.mock()))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testShowRepository() {
        let expectation = self.expectation(description: "testShowRepository expectation")
        
        let repository = Repository.mock(name: "hogehoge")
        action.invoke(.removeAllFavorites)
        action.invoke(.addFavorite(repository))
        
        let selectedRepository = store.selectedRepository.asObservable()
            .filter { $0 != nil }
            .map { $0! }
        let disposable = viewModel.showRepository
            .flatMap { selectedRepository }
            .subscribe(onNext: { selectedRepository in
                
                XCTAssertEqual(selectedRepository.url, repository.url)
                
                expectation.fulfill()
            })
        
        viewDidAppear.onNext(())
        selectRepositoryRowAt.onNext(IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
}
