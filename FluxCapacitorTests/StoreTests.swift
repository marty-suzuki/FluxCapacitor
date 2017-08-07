//
//  StoreTests.swift
//  FluxCapacitorTests
//
//  Created by marty-suzuki on 2017/08/07.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import FluxCapacitor

class StoreTests: XCTestCase {
    var store: TestStore!
    var dispatcher: Dispatcher!
    
    override func setUp() {
        super.setUp()

        dispatcher = Dispatcher.shared
        store = TestStore.instantiate()
    }
    
    override func tearDown() {
        super.tearDown()
        
        store.numbers.removeAll()
    }
    
    func testRemoveAll() {
        dispatcher.dispatch(Dispatcher.Test.removeAllNumbers)
        XCTAssert(store.numbers.isEmpty)
    }
    
    func testAddNumberIs1() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(1))
        XCTAssertEqual(store.numbers.first, 1)
    }
    
    func testAddAndRemoveFinally2() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(1))
        dispatcher.dispatch(Dispatcher.Test.addNumber(2))
        dispatcher.dispatch(Dispatcher.Test.addNumber(3))

        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        XCTAssertEqual(store.numbers.first, 2)
    }
    
    func testStoreIsSameReference() {
        let store2 = TestStore.instantiate()
        XCTAssert(store === store2)
    }
    
    func testReceiveRemoveNumber() {
        let expectation = self.expectation(description: "wait for observe")
        
        let dustBuster = DustBuster()
        store.subscribe {
            switch $0 {
            case .addNumber, .removeAllNumbers:
                XCTFail()
            case.removeNumber:
                break
            }
            expectation.fulfill()
        }
        .cleaned(by: dustBuster)
        
        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCleanedAndNotReceiveChanges() {
        var dustBuster: DustBuster? = DustBuster()
        let dust = store.subscribe { _ in
            XCTFail()
        }
        dust.cleaned(by: dustBuster!)
        dustBuster = nil
        
        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        
        XCTAssert(dust.isCleaned)
    }
    
    func testUnregister() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(3))
        store.unregister()
        
        dispatcher.dispatch(Dispatcher.Test.removeAllNumbers)
        
        XCTAssertEqual(store.numbers.count, 1)
    }
}
