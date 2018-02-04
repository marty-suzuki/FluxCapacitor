//
//  SearchViewModelTestCase.swift
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

class SearchViewModelTestCase: XCTestCase {
    
    var action: UserAction!
    var store: UserStore!
    var mock: ApiSessionMock!
    var viewModel: SearchViewModel!
    var viewWillAppear = PublishSubject<Void>()
    var viewWillDisappear = PublishSubject<Void>()
    var searchText = PublishSubject<String>()
    var selectUserRowAt = PublishSubject<IndexPath>()
    var fetchMoreUsers = PublishSubject<Void>()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.mock = ApiSessionMock()
        self.action = UserAction(session: mock)
        self.store = UserStore.instantiate()
        self.viewModel = SearchViewModel(action: action,
                                         store: store,
                                         viewWillAppear: viewWillAppear,
                                         viewWillDisappear: viewWillDisappear,
                                         searchText: ControlProperty(values: searchText, valueSink: searchText),
                                         selectUserRowAt: selectUserRowAt,
                                         fetchMoreUsers: fetchMoreUsers)
    }
 
    func testReloadData() {
        let expectation = self.expectation(description: "testReloadData expectation")
        
        let disposable = viewModel.reloadData
            .subscribe(onNext: {
                expectation.fulfill()
            })
        
        action.invoke(.addUsers([User.mock()]))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testReloadData expectation2")
        
        let disposable2 = viewModel.reloadData
            .subscribe(onNext: {
                expectation2.fulfill()
            })
        
        action.invoke(.isUserFetching(true))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
    
    func testIsUserFetching() {
        let expectation = self.expectation(description: "testIsUserFetching expectation")
        
        let disposable = viewModel.isUserFetching
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            })
        
        action.invoke(.isUserFetching(false))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testIsUserFetching expectation2")
        
        let disposable2 = viewModel.isUserFetching
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertTrue(value)
                expectation2.fulfill()
            })
        
        action.invoke(.isUserFetching(true))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
    
    func testCounterText() {
        let expectation = self.expectation(description: "testCounterText expectation")
        
        let response = Response<User>(nodes: [User.mock()],
                                      pageInfo: PageInfo.mock(),
                                      totalCount: 10)
        mock.result = .success(response)
        
        let disposable = viewModel.counterText
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "1 / 10")
                expectation.fulfill()
            })
        
        action.fetchUsers(withQuery: "marty-s", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testShowUserRepository() {
        let expectation = self.expectation(description: "testShowUserRepository expectation")
        
        let user = User.mock()
        action.invoke(.selectedUser(nil))
        action.invoke(.removeAllUsers)
        action.invoke(.addUsers([user]))
        
        let selectedUser = store.selectedUser
            .filter { $0 != nil }
            .map { $0! }
        let disposable = viewModel.showUserRepository
            .flatMap { selectedUser }
            .subscribe(onNext: { selectedUser in
                
                XCTAssertEqual(selectedUser.id, user.id)
                XCTAssertEqual(selectedUser.url, user.url)
                
                expectation.fulfill()
            })
        
        selectUserRowAt.onNext(IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testFetchMoreUsers() {
        let expectation = self.expectation(description: "testFetchMoreUsers expectation")
        
        let pageInfo = PageInfo.mock(hasNextPage: true, endCursor: "abcd")
        action.invoke(.lastPageInfo(pageInfo))
        
        let user = User.mock()
        let response = Response<User>(nodes: [user],
                                      pageInfo: PageInfo.mock(),
                                      totalCount: 10)
        mock.result = .success(response)
        
        let disposable = viewModel.isUserFetching
            .filter { !$0 }
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let lastUser = self?.viewModel.usersValue.last else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(lastUser.id, user.id)
                XCTAssertEqual(lastUser.url, user.url)
                
                expectation.fulfill()
            })
        
        fetchMoreUsers.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testSearchText() {
        let expectation = self.expectation(description: "testSearchText expectation")
        
        action.invoke(.lastSearchQuery("back to the future"))
        
        let user = User.mock()
        let pageInfo = PageInfo.mock()
        let totalCount = 100
        let response = Response<User>(nodes: [user],
                                      pageInfo: pageInfo,
                                      totalCount: totalCount)
        mock.result = .success(response)
        
        let disposable = Observable.zip(store.lastSearchQuery.skip(1).filter { !$0.isEmpty },
                                        store.users.skip(1).filter { !$0.isEmpty },
                                        store.userTotalCount.skip(1).filter { $0 != 0 })
            .subscribe(onNext: { query, users, userTotalCount in
                guard let lastUser = users.last, !query.isEmpty else {
                    XCTFail()
                    return
                }
                
                XCTAssertNotEqual(query, "back to the future")
                XCTAssertEqual(query, "great scott")
                XCTAssertEqual(lastUser.id, user.id)
                XCTAssertEqual(lastUser.url, user.url)
                XCTAssertEqual(userTotalCount, totalCount)
                
                expectation.fulfill()
            })
        
        searchText.onNext("great scott")
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
}
