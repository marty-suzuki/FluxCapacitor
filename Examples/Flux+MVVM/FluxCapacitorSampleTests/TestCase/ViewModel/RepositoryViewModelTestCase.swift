//
//  RepositoryViewModelTestCase.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import FluxCapacitorSample
import RxSwift
import RxCocoa
import GithubKit

class RepositoryViewModelTestCase: XCTestCase {
    
    var action: RepositoryAction!
    var store: RepositoryStore!
    var viewModel: RepositoryViewModel!
    var favoriteButtonItemTap = PublishSubject<Void>()
    var viewDidDisappear = PublishSubject<Void>()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.action = RepositoryAction()
        self.store = RepositoryStore.instantiate()
        action.invoke(.selectedRepository(Repository.mock()))
        self.viewModel = RepositoryViewModel(action: action,
                                             store: store,
                                             viewDidDisappear: viewDidDisappear,
                                             favoriteButtonItemTap: ControlEvent(events: favoriteButtonItemTap))
    }
    
    func testButtonTitleTurnsAddToRemove() {
        let expectation = self.expectation(description: "testButtonTitleTurnsAddToRemove expectation")
        
        action.invoke(.removeAllFavorites)
        
        let disposable = viewModel.buttonTitle
            .subscribe(onNext: { title in
                XCTAssertEqual(title, "Add")
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testButtonTitleTurnsAddToRemove expectation2")
        
        let disposable2 = viewModel.buttonTitle
            .skip(1)
            .subscribe(onNext: { title in
                XCTAssertEqual(title, "Remove")
                expectation2.fulfill()
            })
        
        let repository = Repository.mock()
        action.invoke(.selectedRepository(repository))
        favoriteButtonItemTap.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
    
    func testButtonTitleTurnsRemoveToAdd() {
        let expectation = self.expectation(description: "testButtonTitleTurnsRemoveToAdd expectation")
        
        action.invoke(.removeAllFavorites)
        
        let disposable = viewModel.buttonTitle
            .skip(1)
            .subscribe(onNext: { title in
                XCTAssertEqual(title, "Remove")
                expectation.fulfill()
            })
        
        let repository = Repository.mock()
        action.invoke(.selectedRepository(repository))
        action.invoke(.addFavorite(repository))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testButtonTitleTurnsRemoveToAdd expectation2")
        
        let disposable2 = viewModel.buttonTitle
            .skip(1)
            .subscribe(onNext: { title in
                XCTAssertEqual(title, "Add")
                expectation2.fulfill()
            })
        
        favoriteButtonItemTap.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
    
    func testViewDidDisappear() {
        let expectation = self.expectation(description: "testViewDidDisappear expectation")
        
        let repository = Repository.mock()
        action.invoke(.selectedRepository(repository))
        
        let disposable = store.selectedRepository.asObservable()
            .subscribe(onNext: { selectedRepository in
                XCTAssertEqual(repository.url, selectedRepository?.url)
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testViewDidDisappear expectation2")
        
        let disposable2 = store.selectedRepository.asObservable()
            .skip(1)
            .subscribe(onNext: { selectedRepository in
                XCTAssertNil(selectedRepository)
                expectation2.fulfill()
            })
        
        viewDidDisappear.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
}
