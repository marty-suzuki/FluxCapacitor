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
        XCTAssertTrue(store.numbers.value.isEmpty)
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

    func testClear() {
        dispatcher.dispatch(Dispatcher.Test.addNumber(3))
        store.clear()
        
        dispatcher.dispatch(Dispatcher.Test.removeAllNumbers)
        
        XCTAssertEqual(store.numbers.value.count, 1)
        XCTAssertEqual(store.numbers.value.first, 3)
    }
}
