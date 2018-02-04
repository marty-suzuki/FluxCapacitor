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
        store.clear()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectedRepository() {
        let expectation = self.expectation(description: "wait for observe")
        
        let repository = Repository.mock()
        
        let dust = store.selectedRepository
            .observe {
                guard let selectedRepository = $0 else { return }

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
        
        let dust = store.favorites
            .observe {
                guard let favorite = $0.first else { return }

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

        let dustBuster = DustBuster()

        var _repository: Repository!
        store.repositories
            .observe {
                guard let firstRepository = $0.first else { return }

                XCTAssertEqual(repository.name, firstRepository.name)
                XCTAssertEqual(repository.stargazerCount, firstRepository.stargazerCount)
                XCTAssertEqual(repository.forkCount, firstRepository.forkCount)
                XCTAssertEqual(repository.url, firstRepository.url)
                XCTAssertEqual(repository.updatedAt, firstRepository.updatedAt)

                _repository = firstRepository

                group.leave()
            }
            .cleaned(by: dustBuster)

        var _pageInfo: PageInfo!
        store.lastPageInfo
            .observe {
                guard let lastPageInfo = $0 else { return }

                XCTAssertEqual(lastPageInfo.hasNextPage, pageInfo.hasNextPage)
                XCTAssertEqual(lastPageInfo.hasPreviousPage, pageInfo.hasPreviousPage)

                _pageInfo = lastPageInfo

                group.leave()
            }
            .cleaned(by: dustBuster)

        store.repositoryTotalCount
            .observe {
                if _repository == nil || _pageInfo == nil { return }

                XCTAssertEqual($0, totalCount)

                group.leave()
            }
            .cleaned(by: dustBuster)

        action.fetchRepositories(withUserId: "abcd", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dustBuster.clean()
    }
}
