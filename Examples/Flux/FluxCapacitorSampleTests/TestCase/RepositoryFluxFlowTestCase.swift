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
import FluxCapacitor

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
        store.unregister()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectedRepository() {
        let expectation = self.expectation(description: "wait for observe")
        
        let repository = Repository.mock()
        
        let dust = store.subscribe { [weak self] in
            guard
                case .selectedRepository = $0,
                let selectedRepository = self?.store.selectedRepository
            else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(repository.name, selectedRepository.name)
            XCTAssertEqual(repository.stargazerCount, selectedRepository.stargazerCount)
            XCTAssertEqual(repository.forkCount, selectedRepository.forkCount)
            XCTAssertEqual(repository.url, selectedRepository.url)
            XCTAssertEqual(repository.updatedAt, selectedRepository.updatedAt)
            
            expectation.fulfill()
        }
        
        action.invoke(.selectedRepository(repository))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dust.clean()
    }
    
    func testAddFavorite() {
        let expectation = self.expectation(description: "wait for observe")
        
        let repository = Repository.mock()
        
        let dust = store.subscribe { [weak self] in
            guard
                case .addFavorite = $0,
                let favorite = self?.store.favorites.first
            else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(repository.name, favorite.name)
            XCTAssertEqual(repository.stargazerCount, favorite.stargazerCount)
            XCTAssertEqual(repository.forkCount, favorite.forkCount)
            XCTAssertEqual(repository.url, favorite.url)
            XCTAssertEqual(repository.updatedAt, favorite.updatedAt)
            
            expectation.fulfill()
        }
        
        action.invoke(.addFavorite(repository))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dust.clean()
    }
    
    func testFetchRepository() {
        let expectation = self.expectation(description: "wait for observe")
        
        let repository = Repository.mock()
        let pageInfo = PageInfo.mock()
        let totalCount = 10
        session.result = .success(Response<Repository>(nodes: [repository], pageInfo: pageInfo, totalCount: totalCount))
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        group.notify(queue: .global()) {
            expectation.fulfill()
        }
        
        let dust = store.subscribe { [weak self] in
            switch $0 {
            case .addRepositories:
                guard let firstRepository = self?.store.repositories.first else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(repository.name, firstRepository.name)
                XCTAssertEqual(repository.stargazerCount, firstRepository.stargazerCount)
                XCTAssertEqual(repository.forkCount, firstRepository.forkCount)
                XCTAssertEqual(repository.url, firstRepository.url)
                XCTAssertEqual(repository.updatedAt, firstRepository.updatedAt)
                
                group.leave()
            case .lastPageInfo:
                guard let lastPageInfo = self?.store.lastPageInfo else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(lastPageInfo.hasNextPage, pageInfo.hasNextPage)
                XCTAssertEqual(lastPageInfo.hasPreviousPage, pageInfo.hasPreviousPage)
                
                group.leave()
            case .repositoryTotalCount:
                guard let repositoryTotalCount = self?.store.repositoryTotalCount else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(repositoryTotalCount, totalCount)
                
                group.leave()
            default:
                break
            }
        }

        action.fetchRepositories(withUserId: "abcd", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dust.clean()
    }
}
