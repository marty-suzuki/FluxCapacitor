//
//  UserFluxFlowTestCase.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/21.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import FluxCapacitorSample
import RxSwift
import GithubKit

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
        let expectation = self.expectation(description: "testLastSearchQuery expectation")
        
        XCTAssertEqual(store.value.lastSearchQuery, "")
        
        let disposable = store.lastSearchQuery
            .skip(1)
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "marty-suzuki")
                
                expectation.fulfill()
            })
        
        action.fetchUsers(withQuery: "marty-suzuki", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testSelectedUser() {
        let expectation = self.expectation(description: "testSelectedUser expectation")
        
        let user = User.mock()
        
        let disposable = store.selectedUser
            .skip(1)
            .subscribe(onNext: { selectedUser in
                guard let selectedUser = selectedUser else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(selectedUser.id, user.id)
                XCTAssertEqual(selectedUser.avatarURL, user.avatarURL)
                XCTAssertEqual(selectedUser.followerCount, user.followerCount)
                XCTAssertEqual(selectedUser.followingCount, user.followingCount)
                XCTAssertEqual(selectedUser.login, user.login)
                XCTAssertEqual(selectedUser.repositoryCount, user.repositoryCount)
                XCTAssertEqual(selectedUser.url, user.url)
                
                expectation.fulfill()
            })
        
        action.invoke(.selectedUser(user))
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testFetchUser() {
        let expectation = self.expectation(description: "testFetchUser expectation")
        
        let user = User.mock()
        let pageInfo = PageInfo.mock()
        let totalCount = 10
        session.result = .success(Response<User>(nodes: [user], pageInfo: pageInfo, totalCount: totalCount))
        
        let disposable =
            Observable.combineLatest(store.users.skip(1),
                                     store.lastPageInfo.skip(1),
                                     store.userTotalCount.skip(1))
            .subscribe(onNext: { users, lastPageInfo, userTotalCount in
                guard let firstUser = users.first, let lastPageInfo = lastPageInfo else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(firstUser.id, user.id)
                XCTAssertEqual(firstUser.avatarURL, user.avatarURL)
                XCTAssertEqual(firstUser.followerCount, user.followerCount)
                XCTAssertEqual(firstUser.followingCount, user.followingCount)
                XCTAssertEqual(firstUser.login, user.login)
                XCTAssertEqual(firstUser.repositoryCount, user.repositoryCount)
                XCTAssertEqual(firstUser.url, user.url)
                
                XCTAssertEqual(lastPageInfo.hasNextPage, pageInfo.hasNextPage)
                XCTAssertEqual(lastPageInfo.hasPreviousPage, pageInfo.hasPreviousPage)
                
                XCTAssertEqual(userTotalCount, totalCount)
                
                expectation.fulfill()
            })
        
        action.fetchUsers(withQuery: "marty-su", after: nil)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
}
