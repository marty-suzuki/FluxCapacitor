//
//  UserFluxFlowTestCase.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import FluxCapacitorSample

import GithubKit
import FluxCapacitor

class UserFluxFlowTestCase: XCTestCase {
    var action: UserAction!
    var store: UserStore!
    var session: ApiSessionMock!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.session = ApiSessionMock()
        self.action = UserAction(session: session)
        self.store = UserStore.instantiate()
    }
    
    override func tearDown() {
        store.clear()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLastSearchQuery() {
        let expectation = self.expectation(description: "wait for observe")
        
        XCTAssertEqual(store.lastSearchQuery.value, "")
        
        let dust = store.lastSearchQuery
            .observe { value in
                if value != "marty-suzuki" { return }
                XCTAssertEqual(value, "marty-suzuki")
                expectation.fulfill()
            }
        
        action.fetchUsers(withQuery: "marty-suzuki", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dust.clean()
    }
    
    func testSelectedUser() {
        let expectation = self.expectation(description: "wait for observe")
        
        let user = User.mock()
        
        let dust = store.selectedUser
            .observe { selectedUser in
                guard let selectedUser = selectedUser else { return }
                
                XCTAssertEqual(selectedUser.id, user.id)
                XCTAssertEqual(selectedUser.avatarURL, user.avatarURL)
                XCTAssertEqual(selectedUser.followerCount, user.followerCount)
                XCTAssertEqual(selectedUser.followingCount, user.followingCount)
                XCTAssertEqual(selectedUser.login, user.login)
                XCTAssertEqual(selectedUser.repositoryCount, user.repositoryCount)
                XCTAssertEqual(selectedUser.url, user.url)
                
                expectation.fulfill()
            }
        
        action.invoke(.selectedUser(user))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dust.clean()
    }
    
    func testFetchUser() {
        let expectation = self.expectation(description: "wait for observe")
        
        let user = User.mock()
        let pageInfo = PageInfo.mock()
        let totalCount = 10
        session.result = .success(Response<User>(nodes: [user], pageInfo: pageInfo, totalCount: totalCount))

        let group = DispatchGroup()

        group.enter()
        group.enter()
        group.enter()

        group.notify(queue: .global()) {
            expectation.fulfill()
        }

        let dustBuster = DustBuster()

        var _user: User!
        store.users
            .observe {
                guard let firstUser = $0.first else { return }

                XCTAssertEqual(firstUser.id, user.id)
                XCTAssertEqual(firstUser.avatarURL, user.avatarURL)
                XCTAssertEqual(firstUser.followerCount, user.followerCount)
                XCTAssertEqual(firstUser.followingCount, user.followingCount)
                XCTAssertEqual(firstUser.login, user.login)
                XCTAssertEqual(firstUser.repositoryCount, user.repositoryCount)
                XCTAssertEqual(firstUser.url, user.url)

                _user = firstUser

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

        store.userTotalCount
            .observe {
                if _user == nil || _pageInfo == nil { return }

                XCTAssertEqual(totalCount, $0)

                group.leave()
            }
            .cleaned(by: dustBuster)
        
        action.fetchUsers(withQuery: "marty-su", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        dustBuster.clean()
    }
}
