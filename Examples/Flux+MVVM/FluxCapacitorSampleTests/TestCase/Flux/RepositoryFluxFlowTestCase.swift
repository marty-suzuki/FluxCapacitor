//
//  RepositoryFluxFlowTestCase.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/22.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import FluxCapacitorSample
import RxSwift
import GithubKit

class RepositoryFluxFlowTestCase: XCTestCase {
    
    var action: RepositoryAction!
    var store: RepositoryStore!
    var session: ApiSessionMock!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.session = ApiSessionMock()
        self.action = RepositoryAction(session: session)
        self.store = RepositoryStore.instantiate()
    }
    
    override func tearDown() {
        store.clear()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectedRepository() {
        let expectation = self.expectation(description: "testSelectedRepository expectation")
        
        let repository = Repository.mock()
        
        let disposable = store.selectedRepository.asObservable()
            .skip(1)
            .subscribe(onNext: {
                guard let selectedRepository = $0 else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(repository.name, selectedRepository.name)
                XCTAssertEqual(repository.stargazerCount, selectedRepository.stargazerCount)
                XCTAssertEqual(repository.forkCount, selectedRepository.forkCount)
                XCTAssertEqual(repository.url, selectedRepository.url)
                XCTAssertEqual(repository.updatedAt, selectedRepository.updatedAt)
                
                expectation.fulfill()
            })
        
        action.invoke(.selectedRepository(repository))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testAddFavorite() {
        let expectation = self.expectation(description: "testAddFavorite expectation")
        
        action.invoke(.removeAllFavorites)
        let repository = Repository.mock()
        
        let disposable = store.favorites.asObservable()
            .skip(1)
            .map { $0.first }
            .subscribe(onNext: {
                guard let favorite = $0 else {
                    XCTFail()
                    return
                }
            
                XCTAssertEqual(repository.name, favorite.name)
                XCTAssertEqual(repository.stargazerCount, favorite.stargazerCount)
                XCTAssertEqual(repository.forkCount, favorite.forkCount)
                XCTAssertEqual(repository.url, favorite.url)
                XCTAssertEqual(repository.updatedAt, favorite.updatedAt)
                
                expectation.fulfill()
            })
        
        action.invoke(.addFavorite(repository))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testFetchUser() {
        let expectation = self.expectation(description: "testFetchUser expectation")
        
        let repository = Repository.mock()
        let pageInfo = PageInfo.mock()
        let totalCount = 10
        session.result = .success(Response<Repository>(nodes: [repository], pageInfo: pageInfo, totalCount: totalCount))
        
        let disposable =
            Observable.combineLatest(store.repositories.asObservable().skip(1),
                                     store.lastPageInfo.asObservable().skip(1),
                                     store.repositoryTotalCount.asObservable().skip(1))
                .subscribe(onNext: { repositories, lastPageInfo, repositoryTotalCount in
                    guard let firstRepository = repositories.first, let lastPageInfo = lastPageInfo else {
                        XCTFail()
                        return
                    }
                    
                    XCTAssertEqual(repository.name, firstRepository.name)
                    XCTAssertEqual(repository.stargazerCount, firstRepository.stargazerCount)
                    XCTAssertEqual(repository.forkCount, firstRepository.forkCount)
                    XCTAssertEqual(repository.url, firstRepository.url)
                    XCTAssertEqual(repository.updatedAt, firstRepository.updatedAt)
                    
                    XCTAssertEqual(lastPageInfo.hasNextPage, pageInfo.hasNextPage)
                    XCTAssertEqual(lastPageInfo.hasPreviousPage, pageInfo.hasPreviousPage)
                    
                    XCTAssertEqual(repositoryTotalCount, totalCount)
                    
                    expectation.fulfill()
                })
        
        action.fetchRepositories(withUserId: "abcd", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
}
