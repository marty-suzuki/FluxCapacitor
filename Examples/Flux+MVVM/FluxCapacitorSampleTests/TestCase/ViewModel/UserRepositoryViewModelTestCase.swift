//
//  UserRepositoryViewModelTestCase.swift
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

class UserRepositoryViewModelTestCase: XCTestCase {
    var userAction: UserAction!
    var userStore: UserStore!
    var repositoryAction: RepositoryAction!
    var repositoryStore: RepositoryStore!
    var mock: ApiSessionMock!
    var viewModel: UserRepositoryViewModel!
    var fetchMoreRepositories = PublishSubject<Void>()
    var selectRepositoryRowAt = PublishSubject<IndexPath>()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mock = ApiSessionMock()
        userAction = UserAction(session: mock)
        userAction.invoke(.selectedUser(User.mock()))
        userStore = UserStore.instantiate()
        repositoryAction = RepositoryAction(session: mock)
        repositoryStore = RepositoryStore.instantiate()
        viewModel = UserRepositoryViewModel(userAction: userAction,
                                            userStore: userStore,
                                            repositoryAction: repositoryAction,
                                            repositoryStore: repositoryStore,
                                            fetchMoreRepositories: fetchMoreRepositories,
                                            selectRepositoryRowAt: selectRepositoryRowAt)
    }
    
    func testCounterText() {
        let expectation = self.expectation(description: "testCounterText expectation")
        
        repositoryAction.invoke(.removeAllRepositories)
        let response = Response<Repository>(nodes: [Repository.mock(), Repository.mock()],
                                      pageInfo: PageInfo.mock(),
                                      totalCount: 10)
        mock.result = .success(response)
        
        let disposable = viewModel.counterText
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "2 / 10")
                expectation.fulfill()
            })
        
        repositoryAction.fetchRepositories(withUserId: "marty-suzuki", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testShowRespository() {
        let expectation = self.expectation(description: "testShowRespository expectation")
        
        repositoryAction.invoke(.removeAllRepositories)
        let respository = Repository.mock()
        repositoryAction.invoke(.addRepositories([respository]))
        
        let selectedRepository = repositoryStore.selectedRepository.asObservable()
            .filter { $0 != nil }
            .map { $0! }
        let disposable = viewModel.showRepository
            .flatMap { selectedRepository }
            .subscribe(onNext: { selectedRepository in
                
                XCTAssertEqual(selectedRepository.url, respository.url)
                
                expectation.fulfill()
            })
        
        selectRepositoryRowAt.onNext(IndexPath(row: 0, section: 0))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testFetchMoreRepositories() {
        let expectation = self.expectation(description: "testFetchMoreRepositories expectation")
        
        let pageInfo = PageInfo.mock(hasNextPage: true, endCursor: "hogehoge")
        repositoryAction.invoke(.lastPageInfo(pageInfo))
        
        let repository = Repository.mock()
        let response = Response<Repository>(nodes: [repository, repository],
                                            pageInfo: PageInfo.mock(),
                                            totalCount: 55)
        mock.result = .success(response)
        
        let disposable = viewModel.isRepositoryFetching.asObservable()
            .filter { !$0 }
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let lastRepository = self?.viewModel.repositories.value.last else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(lastRepository.url, repository.url)
                
                expectation.fulfill()
            })
        
        fetchMoreRepositories.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testReloadData() {
        let expectation = self.expectation(description: "testReloadData expectation")
        
        let disposable = viewModel.reloadData
            .subscribe(onNext: {
                expectation.fulfill()
            })
        
        repositoryAction.invoke(.addRepositories([Repository.mock()]))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "testReloadData expectation2")
        
        let disposable2 = viewModel.reloadData
            .subscribe(onNext: {
                expectation2.fulfill()
            })
        
        repositoryAction.invoke(.isRepositoryFetching(true))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
    
    func testIsRepositoryFetching() {
        let expectation = self.expectation(description: "isRepositoryFetching expectation")
        
        let disposable = viewModel.isRepositoryFetching.asObservable()
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            })
        
        repositoryAction.invoke(.isRepositoryFetching(false))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
        
        let expectation2 = self.expectation(description: "isRepositoryFetching expectation2")
        
        let disposable2 = viewModel.isRepositoryFetching.asObservable()
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertTrue(value)
                expectation2.fulfill()
            })
        
        repositoryAction.invoke(.isRepositoryFetching(true))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable2.dispose()
    }
}
