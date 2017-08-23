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
}
