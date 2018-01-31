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
        
        store.numbers.value.removeAll()
    }
    
    func testRemoveAll() {
        dispatcher.dispatch(Dispatcher.Test.removeAllNumbers)
        XCTAssert(store.numbers.value.isEmpty)
    }
    
    func testAddNumberIs1() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(1))
        XCTAssertEqual(store.numbers.value.first, 1)
    }
    
    func testAddAndRemoveFinally2() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(1))
        dispatcher.dispatch(Dispatcher.Test.addNumber(2))
        dispatcher.dispatch(Dispatcher.Test.addNumber(3))

        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        XCTAssertEqual(store.numbers.value.first, 2)
    }
    
    func testStoreIsSameReference() {
        let store2 = TestStore.instantiate()
        XCTAssert(store === store2)
    }
    
    func testReceiveRemoveNumber() {
        let expectation = self.expectation(description: "wait for observe")
        
        let dustBuster = DustBuster()
        store.numbers
            .oberve { _ in expectation.fulfill() }
            .cleaned(by: dustBuster)
        
        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCleanedAndNotReceiveChanges() {
        var dustBuster: DustBuster? = DustBuster()
        let dust = store.numbers.oberve { _ in XCTFail() }
        dust.cleaned(by: dustBuster!)
        dustBuster = nil
        
        dispatcher.dispatch(Dispatcher.Test.removeNumber(1))
        
        XCTAssert(dust.isCleaned)
    }
    
    func testUnregister() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(3))
        store.clear()
        
        dispatcher.dispatch(Dispatcher.Test.removeAllNumbers)
        
        XCTAssertEqual(store.numbers.value.count, 1)
    }
}
